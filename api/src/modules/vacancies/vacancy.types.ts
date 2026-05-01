export type Vacancy = {
  id: string
  title: string
  description: string
  providerId: string
  createdAt: Date
}

export type CreateVacancyDTO = {
  title: string
  description: string
}

export type UpdateVacancyDTO = {
  title?: string
  description?: string
}
