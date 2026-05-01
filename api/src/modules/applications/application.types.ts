export type ApplicationStatus = 'pending' | 'accepted' | 'rejected'

export type Application = {
  id: string
  userId: string
  vacancyId: string
  status: ApplicationStatus
  createdAt: Date
}

export type CreateApplicationDTO = {
  vacancyId: string
}

export type UpdateApplicationStatusDTO = {
  status: Exclude<ApplicationStatus, 'pending'>
}
