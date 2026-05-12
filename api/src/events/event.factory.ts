import type { AppEvent } from "../api/src/events/events.types"


type EventPayload<E extends AppEvent['event']> = Omit<
  Extract<AppEvent, { event: E }>,
  'event' | 'occurredAt'
>

// factory — uma função, cobre todos os eventos atuais e futuros
function createEvent<E extends AppEvent['event']>(
  event: E,
  payload: EventPayload<E>
): Extract<AppEvent, { event: E }> {
  return { event, occurredAt: new Date().toISOString(), ...payload } as Extract<AppEvent, { event: E }>
}

export const eventFactory = {
  applicationCreated:      (p: EventPayload<'application.created'>)        => createEvent('application.created', p),
  applicationStatusUpdated:(p: EventPayload<'application.status.updated'>) => createEvent('application.status.updated', p),
}