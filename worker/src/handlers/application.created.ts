import { publisher } from '@/lib/redis'
import type { AppEvent } from '@/types/event.types'

type Payload = Extract<AppEvent, { event: 'application.created' }>

export async function handleApplicationCreated(payload: Payload) {
  const sseMessage = `event: application.created\ndata: ${JSON.stringify({
    applicationId: payload.applicationId,
    vacancyId:     payload.vacancyId,
    occurredAt:    payload.occurredAt,
  })}\n\n`

  await publisher.publish(`repfinder:notify:${payload.providerId}`, sseMessage)
}