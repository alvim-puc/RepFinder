import { Hono } from 'hono'
import { authMiddleware } from '@/lib/auth'
import { AppError } from '@/lib/errors'
import { getValidatedBody, validateBody } from '@/lib/validator'
import service from './application.service'
import type {
  CreateApplicationDTO,
  UpdateApplicationStatusDTO
} from './application.types'
import {
  createApplicationValidator,
  updateApplicationStatusValidator
} from './application.validator'

const app = new Hono()

app.get('/mine', authMiddleware, async (c) => {
  const authUser = c.get('authUser')

  if (!authUser) {
    throw new AppError('Missing authorization token', 401)
  }

  const result = await service.listMine(authUser.userId)
  return c.json(result)
})

app.get('/vacancies/:vacancyId', authMiddleware, async (c) => {
  const authUser = c.get('authUser')
  const vacancyId = c.req.param('vacancyId')

  if (!authUser) {
    throw new AppError('Missing authorization token', 401)
  }

  if (!vacancyId) {
    throw new AppError('Vacancy not found', 404)
  }

  const result = await service.listByVacancy(authUser.userId, vacancyId)
  return c.json(result)
})

app.post(
  '/',
  authMiddleware,
  validateBody(createApplicationValidator),
  async (c) => {
    const authUser = c.get('authUser')

    if (!authUser) {
      throw new AppError('Missing authorization token', 401)
    }

    const body = getValidatedBody<CreateApplicationDTO>(c)
    const result = await service.create(authUser.userId, body)
    return c.json(result, 201)
  }
)

app.patch(
  '/:id/status',
  authMiddleware,
  validateBody(updateApplicationStatusValidator),
  async (c) => {
    const authUser = c.get('authUser')
    const applicationId = c.req.param('id')

    if (!authUser) {
      throw new AppError('Missing authorization token', 401)
    }

    if (!applicationId) {
      throw new AppError('Application not found', 404)
    }

    const body = getValidatedBody<UpdateApplicationStatusDTO>(c)
    const result = await service.updateStatus(authUser.userId, applicationId, body)
    return c.json(result)
  }
)

app.delete('/:id', authMiddleware, async (c) => {
  const authUser = c.get('authUser')
  const applicationId = c.req.param('id')

  if (!authUser) {
    throw new AppError('Missing authorization token', 401)
  }

  if (!applicationId) {
    throw new AppError('Application not found', 404)
  }

  await service.remove(authUser.userId, applicationId)
  return c.json({ ok: true })
})

export default app