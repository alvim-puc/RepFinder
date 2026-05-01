import mysql from 'mysql2/promise'
import { env } from './env'

export async function createConnection() {
  return mysql.createConnection({
    host: env.DB_HOST,
    user: env.DB_USER,
    password: env.DB_PASS
  })
}

export async function createPool() {
  return mysql.createPool({
    host: env.DB_HOST,
    user: env.DB_USER,
    password: env.DB_PASS,
    database: env.DB_NAME,
    connectionLimit: 10
  })
}

export const db = await createPool();