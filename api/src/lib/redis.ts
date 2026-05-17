import { createClient } from 'redis'
import { env } from './env'

function createRedisClient(label: string) {
  const url = `redis://default:${env.REDIS_PASSWORD}@${env.REDIS_URL}:${env.REDIS_PORT}`
  const client = createClient({ url })

  client.on('error', (err) => {
    console.error(`[redis:${label}]`, err)
  })

  return client
}

export const publisher  = createRedisClient('publisher')
export const subscriber = createRedisClient('subscriber')