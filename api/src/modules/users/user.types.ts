export type UserRole = 'student' | 'representative'

export type User = {
  id: string
  email: string
  name: string
  role: UserRole
}

export type StoredUser = User & {
  password: string
}

export type CreateUserDTO = {
  email: string
  name: string
  password: string
  role: UserRole
}

export type LoginDTO = {
  email: string
  password: string
}

export type UpdateUserDTO = {
  email?: string
  name?: string
  password?: string
}

export type AuthResponse = {
  user: User
  token: string
}
