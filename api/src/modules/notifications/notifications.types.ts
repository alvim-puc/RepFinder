export type Notification = {
  id: string
  userId: string
  event: string
  data: unknown
  readed_at: Date | null
  createdAt: Date
}

export type CreateNotificationDTO = {
  userId: string
  event: string
  data: unknown
}
