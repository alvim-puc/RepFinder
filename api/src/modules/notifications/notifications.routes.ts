import { Hono } from 'hono'
import { authMiddleware } from '@/lib/auth'
import { registerConnection, removeConnection } from '@/lib/sse'
import notificationsRepo from './notifications.repo'
import { AppError } from '@/lib/errors'

const notificationRoutes = new Hono()

notificationRoutes.get('/events', authMiddleware, (c) => {
  const { userId } = c.get('authUser')

  const { readable, writable } = new TransformStream<Uint8Array>()
  const writer = writable.getWriter()

  registerConnection(userId, writer)

  c.req.raw.signal.addEventListener('abort', () => {
    removeConnection(userId)
    writer.close().catch(() => {})
  })

  return new Response(readable, {
    headers: {
      'Content-Type':  'text/event-stream',
      'Cache-Control': 'no-cache',
      'Connection':    'keep-alive',
    },
  })
})

notificationRoutes.get('/', authMiddleware, async (c) => {
  const authUser = c.get('authUser')

  if (!authUser) {
    throw new AppError('Missing authorization token', 401)
  }

  const list = await notificationsRepo.listNotificationsByUser(authUser.userId)
  return c.json(list)
})

notificationRoutes.patch('/:id/read', authMiddleware, async (c) => {
  const authUser = c.get('authUser')
  const id = c.req.param('id')

  if (!authUser) {
    throw new AppError('Missing authorization token', 401)
  }

  if (!id) {
    throw new AppError('Notification not found', 404)
  }

  const updated = await notificationsRepo.markNotificationRead(authUser.userId, id)

  if (!updated) {
    throw new AppError('Notification not found', 404)
  }

  return c.json(updated)
})

export default notificationRoutes