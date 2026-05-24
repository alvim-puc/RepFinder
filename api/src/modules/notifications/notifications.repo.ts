import { randomUUID } from 'crypto'
import type { RowDataPacket } from 'mysql2/promise'
import { db } from '@/lib/db'
import type { Notification } from './notifications.types'

type NotificationRow = RowDataPacket & {
  id: string
  user_id: string
  event: string
  data: string | null
  readed_at: Date | null
  created_at: Date
}

async function createNotification(userId: string, event: string, data: unknown): Promise<Notification> {
  const id = randomUUID()
  const createdAt = new Date()

  await db.execute(
    `INSERT INTO notifications (id, user_id, event, data, readed_at, created_at) VALUES (?, ?, ?, ?, ?, ?)`,
    [id, userId, event, JSON.stringify(data ?? {}), null, createdAt]
  )

  return {
    id,
    userId,
    event,
    data,
    readed_at: null,
    createdAt,
  }
}

async function listNotificationsByUser(userId: string): Promise<Notification[]> {
  const [rows] = await db.execute<NotificationRow[]>(`SELECT * FROM notifications WHERE user_id = ? ORDER BY created_at DESC`, [userId])

  return rows.map((r) => ({
    id: r.id,
    userId: r.user_id,
    event: r.event,
    data: (() => {
      try { return JSON.parse(r.data ?? 'null') } catch { return r.data }
    })(),
    readed_at: r.readed_at,
    createdAt: r.created_at,
  }))
}

async function markNotificationRead(userId: string, notificationId: string): Promise<Notification | null> {
  const now = new Date()
  await db.execute(`UPDATE notifications SET readed_at = ? WHERE id = ? AND user_id = ?`, [now, notificationId, userId])

  const [rows] = await db.execute<NotificationRow[]>(`SELECT * FROM notifications WHERE id = ? AND user_id = ? LIMIT 1`, [notificationId, userId])
  const row = rows[0]
  if (!row) return null

  return {
    id: row.id,
    userId: row.user_id,
    event: row.event,
    data: (() => {
      try { return JSON.parse(row.data ?? 'null') } catch { return row.data }
    })(),
    readed_at: row.readed_at,
    createdAt: row.created_at,
  }
}

export default {
  createNotification,
  listNotificationsByUser,
  markNotificationRead,
}
