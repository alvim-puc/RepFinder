import { AppError } from '@/lib/errors'
import { assertExists, assertIsOwner } from '@/lib/helpers'
import userRepo from '../users/user.repo'
import applicationRepo from '../applications/application.repo'
import repo from './vacancy.repo'
import type { CreateVacancyDTO, UpdateVacancyDTO, Vacancy } from './vacancy.types'

const service = {
  create: createVacancy,
  list: listVacancies,
  listMine: listMyVacancies,
  getById: getVacancyById,
  update: updateVacancy,
  remove: removeVacancy,
}

async function createVacancy(
  userId: string,
  data: CreateVacancyDTO
): Promise<Vacancy> {
  const user = assertExists(
    await userRepo.findUserById(userId),
    'User not found'
  )

  if (user.role !== 'representative') {
    throw new AppError('Only representatives can create vacancies', 403)
  }

  return repo.createVacancy({
    ...data,
    providerId: userId
  })
}

async function listVacancies(): Promise<Vacancy[]> {
  return repo.listVacancies()
}

async function listMyVacancies(userId: string): Promise<Vacancy[]> {
  assertExists(
    await userRepo.findUserById(userId),
    'User not found'
  )

  return repo.listVacanciesByProviderId(userId)
}

async function getVacancyById(vacancyId: string): Promise<Vacancy> {
  return assertExists(
    await repo.findVacancyById(vacancyId),
    'Vacancy not found'
  )
}

async function updateVacancy(
  userId: string,
  vacancyId: string,
  data: UpdateVacancyDTO
): Promise<Vacancy> {
  const vacancy = assertExists(
    await repo.findVacancyById(vacancyId),
    'Vacancy not found'
  )

  assertIsOwner(userId, vacancy.providerId)

  const updatedVacancy = assertExists(
    await repo.updateVacancy(vacancyId, data),
    'Vacancy not found'
  )

  return updatedVacancy
}

async function removeVacancy(userId: string, vacancyId: string): Promise<void> {
  const vacancy = assertExists(
    await repo.findVacancyById(vacancyId),
    'Vacancy not found'
  )

  assertIsOwner(userId, vacancy.providerId)

  const applicationCount = await applicationRepo.countApplicationsByVacancyId(vacancyId)

  if (applicationCount > 0) {
    throw new AppError('Vacancy has applications and cannot be deleted', 409)
  }

  await repo.deleteVacancy(vacancyId)
}

export default service
