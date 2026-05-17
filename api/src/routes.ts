import { Hono } from 'hono'
import applicationRoutes from '@/modules/applications/application.routes'
import userRoutes from '@/modules/users/user.routes'
import vacancyRoutes from '@/modules/vacancies/vacancy.routes'
import notificationRoutes from './modules/notifications/notifications.routes'

const routes = new Hono()

routes.get('/', (c) => c.json({ ok: true }))

routes.route('/applications', applicationRoutes)
routes.route('/users', userRoutes)
routes.route('/vacancies', vacancyRoutes)
routes.route('/notifications', notificationRoutes)

export default routes