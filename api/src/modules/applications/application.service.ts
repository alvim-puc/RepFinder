import { AppError } from '@/lib/errors'
import { assertExists, assertIsOwner } from '@/lib/helpers'
import userRepo from '../users/user.repo'
import vacancyRepo from '../vacancies/vacancy.repo'
import repo from './application.repo'
import type {
  Application,
  CreateApplicationDTO,
  UpdateApplicationStatusDTO
} from './application.types'

const service = {
  create: createApplication,
  listMine: listMyApplications,
  listByVacancy: listApplicationsByVacancy,
  updateStatus: updateApplicationStatus,
  remove: removeApplication,
}

async function createApplication(
  userId: string,
  data: CreateApplicationDTO
): Promise<Application> {
  assertExists(
    await userRepo.findUserById(userId),
    'User not found'
  )

  assertExists(
    await vacancyRepo.findVacancyById(data.vacancyId),
    'Vacancy not found'
  )

  const existingApplication = await repo.findApplicationByUserAndVacancy(
    userId,
    data.vacancyId
  )

  if (existingApplication) {
    throw new AppError('You already applied for this vacancy', 409)
  }

  return repo.createApplication({
    userId,
    vacancyId: data.vacancyId
  })
}

async function listMyApplications(userId: string): Promise<Application[]> {
  assertExists(
    await userRepo.findUserById(userId),
    'User not found'
  )

  return repo.listApplicationsByUserId(userId)
}

async function listApplicationsByVacancy(
  userId: string,
  vacancyId: string
): Promise<Application[]> {
  const vacancy = assertExists(
    await vacancyRepo.findVacancyById(vacancyId),
    'Vacancy not found'
  )

  assertIsOwner(userId, vacancy.providerId)

  return repo.listApplicationsByVacancyId(vacancyId)
}

async function updateApplicationStatus(
  userId: string,
  applicationId: string,
  data: UpdateApplicationStatusDTO
): Promise<Application> {
  const application = assertExists(
    await repo.findApplicationById(applicationId),
    'Application not found'
  )

  const vacancy = assertExists(
    await vacancyRepo.findVacancyById(application.vacancyId),
    'Vacancy not found'
  )

  assertIsOwner(userId, vacancy.providerId)

  if (application.status !== 'pending') {
    throw new AppError('Application cannot be changed after final status', 409)
  }

  const updatedApplication = assertExists(
    await repo.updateApplicationStatus(applicationId, data),
    'Application not found'
  )

  return updatedApplication
}

async function removeApplication(
  userId: string,
  applicationId: string
): Promise<void> {
  const application = assertExists(
    await repo.findApplicationById(applicationId),
    'Application not found'
  )

  assertIsOwner(userId, application.userId)

  if (application.status !== 'pending') {
    throw new AppError('Only pending applications can be removed', 409)
  }

  await repo.deleteApplication(applicationId)
}

export default service