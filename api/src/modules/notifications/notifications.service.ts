import { subscriber } from '@/lib/redis'
import { sendEvent } from '@/lib/sse'
import { EVENTS_CHANNEL, type AppEvent } from '@/events/events.types'
import { register, type Service } from '@/lib/lifecycle'
import notificationsRepo from './notifications.repo'

async function handleEvent(message: string): Promise<void> {
  const payload = JSON.parse(message) as AppEvent

  switch (payload.event) {
    case 'application.created':
      await sendEvent(payload.providerId, payload.event, {
        applicationId: payload.applicationId,
        vacancyId:     payload.vacancyId,
        occurredAt:    payload.occurredAt,
      })
      // persist notification for provider
      try {
        await notificationsRepo.createNotification(payload.providerId, payload.event, {
          applicationId: payload.applicationId,
          vacancyId: payload.vacancyId,
          occurredAt: payload.occurredAt,
        })
      } catch (e) {
        console.warn('[notifications] failed to persist notification', e)
      }
      break

    case 'application.status.updated':
      await sendEvent(payload.applicantId, payload.event, {
        applicationId: payload.applicationId,
        status:        payload.status,
        occurredAt:    payload.occurredAt,
      })
      // persist notification for applicant
      try {
        await notificationsRepo.createNotification(payload.applicantId, payload.event, {
          applicationId: payload.applicationId,
          status: payload.status,
          occurredAt: payload.occurredAt,
        })
      } catch (e) {
        console.warn('[notifications] failed to persist notification', e)
      }
      break

    default:
      console.warn('[notifications] evento desconhecido:', (payload as AppEvent).event)
  }
}

const notificationService: Service = {
  name: 'notifications',
  async start() {
    await subscriber.connect()
    await subscriber.subscribe(EVENTS_CHANNEL, handleEvent)
  },
  async stop() {
    if (subscriber.isOpen) {
      await subscriber.unsubscribe(EVENTS_CHANNEL)
      await subscriber.quit()
    }
  },
}

register(notificationService)