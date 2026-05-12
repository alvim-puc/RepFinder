// api/src/events/publisher.ts
import { redis } from '@/lib/redis'
import type { AppEvent } from './events.types'
import { EVENTS_CHANNEL } from './events.types'

export async function publish(payload: AppEvent): Promise<void> {
  await redis.publish(EVENTS_CHANNEL, JSON.stringify(payload))
}