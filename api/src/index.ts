import { serve } from '@hono/node-server'
import app from './app'
import { initDatabase } from './lib/init-db'
import { startAll, stopAll } from './lib/lifecycle'
import { publisherService } from './events/publisher'
import { register } from './lib/lifecycle'

// registra serviços inicializáveis
// publisher é registrado explicitamente pois vive fora de um módulo
register(publisherService)

// notification.service se auto-registra via import
import './modules/notifications/notifications.service'

async function bootstrap() {
  await initDatabase()
  await startAll()

  serve({
    fetch: app.fetch,
    port: 3030,
  }, (info) => {
    console.log(`Server running on http://localhost:${info.port}`)
  })
}

process.on('SIGTERM', async () => {
  await stopAll()
  process.exit(0)
})

process.on('SIGINT', async () => {
  await stopAll()
  process.exit(0)
})

bootstrap()