import { publisher } from '@/lib/redis'
import { EVENTS_CHANNEL, type AppEvent } from './events.types'
import type { Service } from '@/lib/lifecycle'

export async function publish(payload: AppEvent): Promise<void> {
  await publisher.publish(EVENTS_CHANNEL, JSON.stringify(payload))
}

export const publisherService: Service = {
  name: 'redis:publisher',
  async start() {
    await publisher.connect()
  },
  async stop() {
    await publisher.quit()
  },
}