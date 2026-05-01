import { randomUUID } from 'crypto'
import type { RowDataPacket } from 'mysql2/promise'
import { db } from '@/lib/db'
import type { CreateVacancyDTO, UpdateVacancyDTO, Vacancy } from './vacancy.types'

type VacancyRow = RowDataPacket & {
  id: string
  title: string
  description: string
  provider_id: string
  created_at: Date
}

type CountRow = RowDataPacket & {
  total: number
}

const repo = {
  createVacancy,
  listVacancies,
  listVacanciesByProviderId,
  findVacancyById,
  updateVacancy,
  deleteVacancy,
  countApplicationsByVacancyId,
}

function mapVacancy(row: VacancyRow): Vacancy {
  return {
    id: row.id,
    title: row.title,
    description: row.description,
    providerId: row.provider_id,
    createdAt: row.created_at
  }
}

async function createVacancy(
  data: CreateVacancyDTO & { providerId: string }
): Promise<Vacancy> {
  const id = randomUUID()
  const createdAt = new Date()

  await db.execute(
    `INSERT INTO vacancies (id, title, description, provider_id, created_at)
     VALUES (?, ?, ?, ?, ?)`,
    [id, data.title, data.description, data.providerId, createdAt]
  )

  return {
    id,
    title: data.title,
    description: data.description,
    providerId: data.providerId,
    createdAt
  }
}

async function listVacancies(): Promise<Vacancy[]> {
  const [rows] = await db.execute<VacancyRow[]>(`SELECT * FROM vacancies`)

  return rows.map(mapVacancy)
}

async function listVacanciesByProviderId(providerId: string): Promise<Vacancy[]> {
  const [rows] = await db.execute<VacancyRow[]>(
    `SELECT * FROM vacancies WHERE provider_id = ?`,
    [providerId]
  )

  return rows.map(mapVacancy)
}

async function findVacancyById(id: string): Promise<Vacancy | null> {
  const [rows] = await db.execute<VacancyRow[]>(
    `SELECT * FROM vacancies WHERE id = ? LIMIT 1`,
    [id]
  )

  const row = rows[0]

  if (!row) {
    return null
  }

  return mapVacancy(row)
}

async function updateVacancy(
  id: string,
  data: UpdateVacancyDTO
): Promise<Vacancy | null> {
  const fields: string[] = []
  const values: Array<string> = []

  if (data.title !== undefined) {
    fields.push('title = ?')
    values.push(data.title)
  }

  if (data.description !== undefined) {
    fields.push('description = ?')
    values.push(data.description)
  }

  if (fields.length === 0) {
    return findVacancyById(id)
  }

  values.push(id)

  await db.execute(
    `UPDATE vacancies SET ${fields.join(', ')} WHERE id = ?`,
    values
  )

  return findVacancyById(id)
}

async function deleteVacancy(id: string): Promise<void> {
  await db.execute(`DELETE FROM vacancies WHERE id = ?`, [id])
}

async function countApplicationsByVacancyId(vacancyId: string): Promise<number> {
  const [rows] = await db.execute<CountRow[]>(
    `SELECT COUNT(*) AS total FROM applications WHERE vacancy_id = ?`,
    [vacancyId]
  )

  return rows[0]?.total ?? 0
}

export default repo
