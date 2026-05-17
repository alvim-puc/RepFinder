import 'dotenv/config'

export const env = {
  DB_HOST: process.env.DB_HOST!,
  DB_USER: process.env.DB_USER!,
  DB_PASS: process.env.DB_PASS!,
  DB_NAME: process.env.DB_NAME!,
  REDIS_URL: process.env.REDIS_URL!,
  REDIS_PORT: process.env.REDIS_PORT!,
  REDIS_PASSWORD: process.env.REDIS_PASSWORD!,
  JWT_SECRET: process.env.JWT_SECRET ?? 'repfinder-dev-secret'
}