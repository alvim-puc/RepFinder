import { SignJWT, jwtVerify } from 'jose'
import { pbkdf2Sync, randomBytes, timingSafeEqual } from 'crypto'
import type { Context, Next } from 'hono'
import { env } from './env'
import { AppError } from './errors'

export type AuthUser = {
  userId: string
  email?: string
}

declare module 'hono' {
  interface ContextVariableMap {
    authUser: AuthUser
  }
}

const PASSWORD_ITERATIONS = 100000
const PASSWORD_KEY_LENGTH = 64
const PASSWORD_DIGEST = 'sha512'
const JWT_EXPIRY_DAYS = 7

const secret = new TextEncoder().encode(env.JWT_SECRET)

export function hashPassword(password: string) {
  const salt = randomBytes(16).toString('hex')
  const hash = pbkdf2Sync(
    password,
    salt,
    PASSWORD_ITERATIONS,
    PASSWORD_KEY_LENGTH,
    PASSWORD_DIGEST
  ).toString('hex')

  return `${PASSWORD_ITERATIONS}:${salt}:${hash}`
}

export function verifyPassword(password: string, storedHash: string) {
  const [iterationsText, salt, expectedHash] = storedHash.split(':')
  const iterations = Number(iterationsText)

  if (!iterations || !salt || !expectedHash) {
    return false
  }

  const actualHash = pbkdf2Sync(
    password,
    salt,
    iterations,
    PASSWORD_KEY_LENGTH,
    PASSWORD_DIGEST
  ).toString('hex')

  const actualBuffer = Buffer.from(actualHash, 'hex')
  const expectedBuffer = Buffer.from(expectedHash, 'hex')

  return (
    actualBuffer.length === expectedBuffer.length &&
    timingSafeEqual(actualBuffer, expectedBuffer)
  )
}

export async function createAccessToken(payload: AuthUser): Promise<string> {
  const token = await new SignJWT(payload)
    .setProtectedHeader({ alg: 'HS256' })
    .setIssuedAt()
    .setExpirationTime(`${JWT_EXPIRY_DAYS}d`)
    .sign(secret)

  return token
}

export async function verifyAccessToken(token: string): Promise<AuthUser> {
  try {
    const verified = await jwtVerify(token, secret)
    return {
      userId: verified.payload.userId as string,
      email: verified.payload.email as string | undefined
    }
  } catch (error) {
    throw new AppError('Invalid or expired token', 401)
  }
}

export async function authMiddleware(c: Context, next: Next): Promise<void> {
  const authHeader = c.req.header('Authorization')

  if (!authHeader) {
    throw new AppError('Missing authorization header', 401)
  }

  const [scheme, token] = authHeader.split(' ')

  if (scheme !== 'Bearer' || !token) {
    throw new AppError('Invalid authorization header format', 401)
  }

  const authUser = await verifyAccessToken(token)
  c.set('authUser', authUser)
  await next()
}
