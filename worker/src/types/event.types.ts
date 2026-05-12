type Created = {
    event: 'application.created',
    applicationId: string,
    vacancyId: string,
    applicantId: string,
    providerId: string, // quem precisa ser notificado
    occurredAt: string
}

type StatusUpdated = {
    event: 'application.status.updated',
    applicationId: string,
    vacancyId: string,
    applicantId: string, // quem precisa ser notificado
    status: 'accepted' | 'rejected',
    occurredAt: string
}

export type AppEvent = Created | StatusUpdated

export const EVENTS_CHANNEL = 'repfinder:events'