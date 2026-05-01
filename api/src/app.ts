import { Hono } from 'hono'
import routes from './routes'
import { AppError } from './lib/errors'

const app = new Hono()

app.notFound((c) => c.json({ error: 'Not Found' }, 404))

app.onError((err, c) => {
  if (err instanceof AppError) {
    return c.json({ error: err.message }, { status: err.statusCode as never })
  }

  console.error(err)
  return c.json({ error: 'Internal Server Error' }, { status: 500 as never })
})

app.route('/api', routes)

export default app