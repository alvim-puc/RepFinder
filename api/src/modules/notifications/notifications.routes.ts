// notifications.routes.ts
import { authMiddleware } from '@/lib/auth'
import { registerConnection, removeConnection } from '@/lib/sse'
import { Hono } from 'hono'

const app = new Hono()

app.get('/events', authMiddleware, (c) => {
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
    }
  })
})

export default app