import { serve } from '@hono/node-server'
import app from './app'
import { initDatabase } from './lib/init-db'

async function bootstrap() {
  await initDatabase()

  serve({
    fetch: app.fetch,
    port: 3030
  }, (info) => {
    console.log(`Server running on http://localhost:${info.port}`)
  })
}

bootstrap()