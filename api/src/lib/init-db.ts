import { createConnection, createPool } from "./db";
import { env } from "./env";

export async function initDatabase() {
  const connection = await createConnection();

  await connection.query(`CREATE DATABASE IF NOT EXISTS \`${env.DB_NAME}\``);

  await connection.end();

  const pool = await createPool();

  await pool.query(`
    CREATE TABLE IF NOT EXISTS users (
      id         VARCHAR(36)  PRIMARY KEY,
      email      VARCHAR(255) NOT NULL UNIQUE,
      name       VARCHAR(255) NOT NULL,
      password   VARCHAR(255) NOT NULL,
      role       VARCHAR(20)  NOT NULL,
      avatar_url VARCHAR(500) NULL,
      bio        TEXT         NULL,
      gender     ENUM('female','male','non_binary','other') NULL
    )
  `);

  await pool.query(`
    CREATE TABLE IF NOT EXISTS vacancies (
      id          VARCHAR(36)  PRIMARY KEY,
      title       VARCHAR(255) NOT NULL,
      description TEXT         NOT NULL,
      provider_id VARCHAR(36)  NOT NULL,
      created_at  DATETIME     NOT NULL
    )
  `);

  await pool.query(`
    CREATE TABLE IF NOT EXISTS applications (
      id         VARCHAR(36) PRIMARY KEY,
      user_id    VARCHAR(36) NOT NULL,
      vacancy_id VARCHAR(36) NOT NULL,
      status     VARCHAR(20) NOT NULL,
      created_at DATETIME    NOT NULL
    )
  `);

  await pool.query(`
    CREATE TABLE IF NOT EXISTS notifications (
      id         VARCHAR(36)  PRIMARY KEY,
      user_id    VARCHAR(36)  NOT NULL,
      event      VARCHAR(255) NOT NULL,
      data       TEXT,
      readed_at  DATETIME     NULL,
      created_at DATETIME     NOT NULL
    )
  `);

  // migrations para bancos existentes
  try {
    await pool.query(`
      ALTER TABLE notifications
      CHANGE COLUMN is_read readed_at DATETIME NULL
    `);
  } catch {
    // já migrado ou coluna não existe
  }

  for (const [col, def] of [
    ["avatar_url", "VARCHAR(500) NULL"],
    ["bio", "TEXT NULL"],
    ["gender", "ENUM('female','male','non_binary','other') NULL"],
  ] as const) {
    try {
      await pool.query(`ALTER TABLE users ADD COLUMN ${col} ${def}`);
    } catch {
      // coluna já existe
    }
  }

  console.log("✅ Database inicializado");

  return pool;
}
