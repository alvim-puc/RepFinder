import { AppError } from '@/lib/errors'
import { createAccessToken, hashPassword, verifyPassword } from '@/lib/auth'
import repo from './user.repo'
import type {
  AuthResponse,
  CreateUserDTO,
  LoginDTO,
  UpdateUserDTO,
  User
} from './user.types'

const service = {
  register: registerUser,
  login: loginUser,
  getMe: getAuthenticatedUser,
  updateMe: updateAuthenticatedUser,
}

async function registerUser(data: CreateUserDTO): Promise<AuthResponse> {
  const existingUser = await repo.findUserByEmail(data.email)

  if (existingUser) {
    throw new AppError('Email already in use', 409)
  }

  const password = hashPassword(data.password)

  const user = await repo.createUser({
    email: data.email,
    name: data.name,
    password,
    role: data.role
  })

  const token = await createAccessToken({
    userId: user.id,
    email: user.email
  })

  return {
    user,
    token
  }
}

async function loginUser(data: LoginDTO): Promise<AuthResponse> {
  const user = await repo.findUserWithPasswordByEmail(data.email)

  const isValid = user && verifyPassword(data.password, user.password)

  if (!isValid) {
    throw new AppError('Invalid credentials', 401)
  }

  const token = await createAccessToken({
    userId: user.id,
    email: user.email
  })

  return {
    user: {
      id: user.id,
      email: user.email,
      name: user.name,
      role: user.role
    },
    token
  }
}

async function getAuthenticatedUser(userId: string): Promise<User> {
  const user = await repo.findUserById(userId)

  if (!user) {
    throw new AppError('User not found', 404)
  }

  return user
}

async function updateAuthenticatedUser(
  userId: string,
  data: UpdateUserDTO
): Promise<User> {
  const currentUser = await repo.findUserById(userId)

  if (!currentUser) {
    throw new AppError('User not found', 404)
  }

  if (data.email !== undefined) {
    const existingUser = await repo.findUserByEmail(data.email)

    if (existingUser && existingUser.id !== userId) {
      throw new AppError('Email already in use', 409)
    }
  }

  const updatedUser = await repo.updateUser(userId, {
    email: data.email,
    name: data.name,
    password: data.password !== undefined ? hashPassword(data.password) : undefined
  })

  if (!updatedUser) {
    throw new AppError('User not found', 404)
  }

  return updatedUser
}

export default service
