import { randomUUID } from 'crypto'
import type { RowDataPacket } from 'mysql2/promise'
import { db } from '@/lib/db'
import type {
  CreateUserDTO,
  StoredUser,
  UpdateUserDTO,
  User,
  UserRole
} from './user.types'

type UserRow = RowDataPacket & {
  id: string
  email: string
  name: string
  password: string
  role: UserRole
}

const repo = {
  createUser,
  findUserById,
  findUserByEmail,
  findUserWithPasswordByEmail,
  updateUser,
}

function mapUser(row: UserRow): User {
  return {
    id: row.id,
    email: row.email,
    name: row.name,
    role: row.role
  }
}

function mapStoredUser(row: UserRow): StoredUser {
  return {
    id: row.id,
    email: row.email,
    name: row.name,
    role: row.role,
    password: row.password
  }
}

async function createUser(data: CreateUserDTO & { password: string }): Promise<User> {
  const id = randomUUID()

  await db.execute(
    `INSERT INTO users (id, email, name, password, role)
     VALUES (?, ?, ?, ?, ?)`,
    [id, data.email, data.name, data.password, data.role]
  )

  return {
    id,
    email: data.email,
    name: data.name,
    role: data.role
  }
}

async function findUserById(id: string): Promise<User | null> {
  const [rows] = await db.execute<UserRow[]>(
    `SELECT id, email, name, role, password FROM users WHERE id = ? LIMIT 1`,
    [id]
  )

  const row = rows[0]

  if (!row) {
    return null
  }

  return mapUser(row)
}

async function findUserByEmail(email: string): Promise<User | null> {
  const [rows] = await db.execute<UserRow[]>(
    `SELECT id, email, name, role, password FROM users WHERE email = ? LIMIT 1`,
    [email]
  )

  const row = rows[0]

  if (!row) {
    return null
  }

  return mapUser(row)
}

async function findUserWithPasswordByEmail(email: string): Promise<StoredUser | null> {
  const [rows] = await db.execute<UserRow[]>(
    `SELECT id, email, name, role, password FROM users WHERE email = ? LIMIT 1`,
    [email]
  )

  const row = rows[0]

  if (!row) {
    return null
  }

  return mapStoredUser(row)
}

async function updateUser(
  id: string,
  data: UpdateUserDTO & { password?: string }
): Promise<User | null> {
  const fields: string[] = []
  const values: Array<string> = []

  if (data.email !== undefined) {
    fields.push('email = ?')
    values.push(data.email)
  }

  if (data.name !== undefined) {
    fields.push('name = ?')
    values.push(data.name)
  }

  if (data.password !== undefined) {
    fields.push('password = ?')
    values.push(data.password)
  }

  if (fields.length === 0) {
    return findUserById(id)
  }

  values.push(id)

  await db.execute(
    `UPDATE users SET ${fields.join(', ')} WHERE id = ?`,
    values
  )

  return findUserById(id)
}

export default repo
