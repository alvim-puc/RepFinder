// worker/src/index.ts
import { connectRedis, subscriber, publisher } from './lib/redis'
import { EVENTS_CHANNEL } from './events.types'
import { handleApplicationCreated } from './handlers/application-created'
import { handleApplicationStatusUpdated } from './handlers/application-status-updated'

await connectRedis()

await subscriber.subscribe(EVENTS_CHANNEL, async (message) => {
  const payload = JSON.parse(message)

  switch (payload.event) {
    case 'application.created':
      await handleApplicationCreated(payload, publisher)
      break
    case 'application.status.updated':
      await handleApplicationStatusUpdated(payload, publisher)
      break
    default:
      console.warn('[worker] evento desconhecido:', payload.event)
  }
})

console.log('[worker] aguardando eventos...')