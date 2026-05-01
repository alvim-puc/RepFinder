import type { Context, Next } from 'hono'

export type Validator<T> = (data: unknown) => T

// chave interna segura
const VALIDATED_BODY = '__validated_body__'

// helper pra acessar depois
export function getValidatedBody<T>(c: Context): T {
  return c.get(VALIDATED_BODY)
}

// middleware
export function validateBody<T>(validator: Validator<T>) {
  return async (c: Context, next: Next) => {
    try {
      const raw = await c.req.json()
      const parsed = validator(raw)

      c.set(VALIDATED_BODY, parsed)

      await next()
    } catch (err) {
      return c.json(
        { error: (err as Error).message },
        400
      )
    }
  }
}