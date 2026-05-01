import { AppError } from './errors'

export function assertIsOwner(authUserId: string, resourceUserId: string): void {
  if (authUserId !== resourceUserId) {
    throw new AppError('Forbidden', 403)
  }
}

export function assertExists<T>(value: T | null | undefined, message: string): T {
  if (value === null || value === undefined) {
    throw new AppError(message, 404)
  }
  return value
}
