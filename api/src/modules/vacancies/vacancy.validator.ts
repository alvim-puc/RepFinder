import type { Validator } from '@/lib/validator'
import type { CreateVacancyDTO, UpdateVacancyDTO } from './vacancy.types'

export const createVacancyValidator: Validator<CreateVacancyDTO> = (data) => {
  if (typeof data !== 'object' || data === null) {
    throw new Error('Payload must be an object')
  }

  const obj = data as Record<string, unknown>

  if (typeof obj.title !== 'string') {
    throw new Error('title must be a string')
  }

  if (typeof obj.description !== 'string') {
    throw new Error('description must be a string')
  }

  return {
    title: obj.title,
    description: obj.description
  }
}

export const updateVacancyValidator: Validator<UpdateVacancyDTO> = (data) => {
  if (typeof data !== 'object' || data === null) {
    throw new Error('Payload must be an object')
  }

  const obj = data as Record<string, unknown>
  const payload: UpdateVacancyDTO = {}

  if (obj.title !== undefined) {
    if (typeof obj.title !== 'string') {
      throw new Error('title must be a string')
    }

    payload.title = obj.title
  }

  if (obj.description !== undefined) {
    if (typeof obj.description !== 'string') {
      throw new Error('description must be a string')
    }

    payload.description = obj.description
  }

  if (payload.title === undefined && payload.description === undefined) {
    throw new Error('At least one field must be provided')
  }

  return payload
}
