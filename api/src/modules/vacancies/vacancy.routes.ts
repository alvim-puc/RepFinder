import { Hono } from 'hono'
import { authMiddleware } from '@/lib/auth'
import { AppError } from '@/lib/errors'
import { getValidatedBody, validateBody } from '@/lib/validator'
import service from './vacancy.service'
import type { CreateVacancyDTO, UpdateVacancyDTO } from './vacancy.types'
import {
  createVacancyValidator,
  updateVacancyValidator
} from './vacancy.validator'

const app = new Hono()

app.get('/', async (c) => {
  const result = await service.list()
  return c.json(result)
})

app.get('/mine', authMiddleware, async (c) => {
  const authUser = c.get('authUser')

  if (!authUser) {
    throw new AppError('Missing authorization token', 401)
  }

  const result = await service.listMine(authUser.userId)
  return c.json(result)
})

app.get('/:id', async (c) => {
  const vacancyId = c.req.param('id')
  const result = await service.getById(vacancyId)
  return c.json(result)
})

app.post(
  '/',
  authMiddleware,
  validateBody(createVacancyValidator),
  async (c) => {
    const authUser = c.get('authUser')

    if (!authUser) {
      throw new AppError('Missing authorization token', 401)
    }

    const body = getValidatedBody<CreateVacancyDTO>(c)
    const result = await service.create(authUser.userId, body)
    return c.json(result, 201)
  }
)

app.patch(
  '/:id',
  authMiddleware,
  validateBody(updateVacancyValidator),
  async (c) => {
    const authUser = c.get('authUser')
    const vacancyId = c.req.param('id')

    if (!authUser) {
      throw new AppError('Missing authorization token', 401)
    }

    if (!vacancyId) {
      throw new AppError('Vacancy not found', 404)
    }

    const body = getValidatedBody<UpdateVacancyDTO>(c)
    const result = await service.update(authUser.userId, vacancyId, body)
    return c.json(result)
  }
)

app.delete('/:id', authMiddleware, async (c) => {
  const authUser = c.get('authUser')
  const vacancyId = c.req.param('id')

  if (!authUser) {
    throw new AppError('Missing authorization token', 401)
  }

  if (!vacancyId) {
    throw new AppError('Vacancy not found', 404)
  }

  await service.remove(authUser.userId, vacancyId)
  return c.json({ ok: true })
})

export default app
