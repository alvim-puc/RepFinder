import type { Validator } from '@/lib/validator'
import type {
  CreateApplicationDTO,
  UpdateApplicationStatusDTO
} from './application.types'

export const createApplicationValidator: Validator<CreateApplicationDTO> = (data) => {
  if (typeof data !== 'object' || data === null) {
    throw new Error('Payload must be an object')
  }

  const obj = data as Record<string, unknown>

  if (typeof obj.vacancyId !== 'string') {
    throw new Error('vacancyId must be a string')
  }

  return {
    vacancyId: obj.vacancyId
  }
}

export const updateApplicationStatusValidator: Validator<UpdateApplicationStatusDTO> = (
  data
) => {
  if (typeof data !== 'object' || data === null) {
    throw new Error('Payload must be an object')
  }

  const obj = data as Record<string, unknown>

  if (obj.status !== 'accepted' && obj.status !== 'rejected') {
    throw new Error('status must be accepted or rejected')
  }

  return {
    status: obj.status
  }
}
