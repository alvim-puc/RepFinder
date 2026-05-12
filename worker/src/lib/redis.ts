import { createClient } from 'redis'

const REDIS_URL = process.env.REDIS_URL!;

function createRedisClient(label: string) {
  const client = createClient({ url: REDIS_URL })

  client.on('error', (err) => {
    console.error(`[redis:${label}] erro:`, err)
  })

  return client
}

// consome eventos publicados pela API
export const subscriber = createRedisClient('subscriber')

// publica nos canais individuais de notificação (repfinder:notify:USER_ID)
export const publisher = createRedisClient('publisher')

export async function connectRedis() {
  await Promise.all([
    subscriber.connect(),
    publisher.connect(),
  ])
  console.log('[redis] conectado')
}