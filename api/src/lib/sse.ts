// api/lib/sse.ts
import { createClient } from 'redis'
import { env } from './env'

type SSEWriter = WritableStreamDefaultWriter<Uint8Array>
export const connections = new Map<string, SSEWriter>()

// subscriber interno — escuta canais de notificação individuais
const subscriber = createClient({ url: env.REDIS_URL })
await subscriber.connect()

export async function registerConnection(userId: string, writer: SSEWriter) {
  connections.set(userId, writer)

  // assina o canal pessoal desse usuário
  await subscriber.subscribe(`repfinder:notify:${userId}`, async (message) => {
    const w = connections.get(userId)
    if (!w) return
    const chunk = new TextEncoder().encode(message)
    await w.write(chunk).catch(() => {})
  })
}

export async function removeConnection(userId: string) {
  connections.delete(userId)
  await subscriber.unsubscribe(`repfinder:notify:${userId}`)
}