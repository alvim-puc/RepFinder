import { randomUUID } from 'crypto'
import type { RowDataPacket } from 'mysql2/promise'
import { db } from '@/lib/db'
import type {
  Application,
  ApplicationStatus,
  CreateApplicationDTO,
  UpdateApplicationStatusDTO
} from './application.types'

type ApplicationRow = RowDataPacket & {
  id: string
  user_id: string
  vacancy_id: string
  status: ApplicationStatus
  created_at: Date
}

type CountRow = RowDataPacket & {
  total: number
}

const repo = {
  createApplication,
  listApplications,
  listApplicationsByUserId,
  listApplicationsByVacancyId,
  findApplicationById,
  findApplicationByUserAndVacancy,
  updateApplicationStatus,
  deleteApplication,
  countApplicationsByVacancyId,
}

function mapApplication(row: ApplicationRow): Application {
  return {
    id: row.id,
    userId: row.user_id,
    vacancyId: row.vacancy_id,
    status: row.status,
    createdAt: row.created_at
  }
}

async function createApplication(
  data: CreateApplicationDTO & { userId: string }
): Promise<Application> {
  const id = randomUUID()
  const createdAt = new Date()

  await db.execute(
    `INSERT INTO applications (id, user_id, vacancy_id, status, created_at)
     VALUES (?, ?, ?, ?, ?)`,
    [id, data.userId, data.vacancyId, 'pending', createdAt]
  )

  return {
    id,
    userId: data.userId,
    vacancyId: data.vacancyId,
    status: 'pending',
    createdAt
  }
}

async function listApplications(): Promise<Application[]> {
  const [rows] = await db.execute<ApplicationRow[]>(`SELECT * FROM applications`)

  return rows.map(mapApplication)
}

async function listApplicationsByUserId(userId: string): Promise<Application[]> {
  const [rows] = await db.execute<ApplicationRow[]>(
    `SELECT * FROM applications WHERE user_id = ?`,
    [userId]
  )

  return rows.map(mapApplication)
}

async function listApplicationsByVacancyId(vacancyId: string): Promise<Application[]> {
  const [rows] = await db.execute<ApplicationRow[]>(
    `SELECT * FROM applications WHERE vacancy_id = ?`,
    [vacancyId]
  )

  return rows.map(mapApplication)
}

async function findApplicationById(id: string): Promise<Application | null> {
  const [rows] = await db.execute<ApplicationRow[]>(
    `SELECT * FROM applications WHERE id = ? LIMIT 1`,
    [id]
  )

  const row = rows[0]

  if (!row) {
    return null
  }

  return mapApplication(row)
}

async function findApplicationByUserAndVacancy(
  userId: string,
  vacancyId: string
): Promise<Application | null> {
  const [rows] = await db.execute<ApplicationRow[]>(
    `SELECT * FROM applications WHERE user_id = ? AND vacancy_id = ? LIMIT 1`,
    [userId, vacancyId]
  )

  const row = rows[0]

  if (!row) {
    return null
  }

  return mapApplication(row)
}

async function updateApplicationStatus(
  id: string,
  data: UpdateApplicationStatusDTO
): Promise<Application | null> {
  await db.execute(
    `UPDATE applications SET status = ? WHERE id = ?`,
    [data.status, id]
  )

  return findApplicationById(id)
}

async function deleteApplication(id: string): Promise<void> {
  await db.execute(`DELETE FROM applications WHERE id = ?`, [id])
}

async function countApplicationsByVacancyId(vacancyId: string): Promise<number> {
  const [rows] = await db.execute<CountRow[]>(
    `SELECT COUNT(*) AS total FROM applications WHERE vacancy_id = ?`,
    [vacancyId]
  )

  return rows[0]?.total ?? 0
}

export default repo