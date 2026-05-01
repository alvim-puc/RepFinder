import type { Validator } from '@/lib/validator'
import type { CreateUserDTO, LoginDTO, UpdateUserDTO, UserRole } from './user.types'

const validRoles: UserRole[] = ['student', 'representative']

export const createUserValidator: Validator<CreateUserDTO> = (data) => {
  if (typeof data !== 'object' || data === null) {
    throw new Error('Payload must be an object')
  }

  const obj = data as Record<string, unknown>

  if (typeof obj.email !== 'string') {
    throw new Error('email must be a string')
  }

  if (typeof obj.name !== 'string') {
    throw new Error('name must be a string')
  }

  if (typeof obj.password !== 'string') {
    throw new Error('password must be a string')
  }

  if (obj.password.length < 6) {
    throw new Error('password must be at least 6 characters')
  }

  if (typeof obj.role !== 'string' || !validRoles.includes(obj.role as UserRole)) {
    throw new Error('role must be student or representative')
  }

  return {
    email: obj.email,
    name: obj.name,
    password: obj.password,
    role: obj.role as UserRole
  }
}

export const loginUserValidator: Validator<LoginDTO> = (data) => {
  if (typeof data !== 'object' || data === null) {
    throw new Error('Payload must be an object')
  }

  const obj = data as Record<string, unknown>

  if (typeof obj.email !== 'string') {
    throw new Error('email must be a string')
  }

  if (typeof obj.password !== 'string') {
    throw new Error('password must be a string')
  }

  return {
    email: obj.email,
    password: obj.password
  }
}

export const updateUserValidator: Validator<UpdateUserDTO> = (data) => {
  if (typeof data !== 'object' || data === null) {
    throw new Error('Payload must be an object')
  }

  const obj = data as Record<string, unknown>
  const payload: UpdateUserDTO = {}

  if (obj.email !== undefined) {
    if (typeof obj.email !== 'string') {
      throw new Error('email must be a string')
    }

    payload.email = obj.email
  }

  if (obj.name !== undefined) {
    if (typeof obj.name !== 'string') {
      throw new Error('name must be a string')
    }

    payload.name = obj.name
  }

  if (obj.password !== undefined) {
    if (typeof obj.password !== 'string') {
      throw new Error('password must be a string')
    }

    if (obj.password.length < 6) {
      throw new Error('password must be at least 6 characters')
    }

    payload.password = obj.password
  }

  if (
    payload.email === undefined &&
    payload.name === undefined &&
    payload.password === undefined
  ) {
    throw new Error('At least one field must be provided')
  }

  return payload
}
