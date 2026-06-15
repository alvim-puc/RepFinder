import { randomUUID } from "crypto";
import type { RowDataPacket } from "mysql2/promise";
import { db } from "@/lib/db";
import type {
  CreateUserDTO,
  Gender,
  PublicUser,
  StoredUser,
  UpdateUserDTO,
  User,
  UserRole,
} from "./user.types";

type UserRow = RowDataPacket & {
  id: string;
  email: string;
  name: string;
  password: string;
  role: UserRole;
  avatar_url: string | null;
  bio: string | null;
  gender: Gender | null;
};

const repo = {
  createUser,
  findUserById,
  findPublicUserById,
  findUserByEmail,
  findUserWithPasswordByEmail,
  updateUser,
};

function mapUser(row: UserRow): User {
  return {
    id: row.id,
    email: row.email,
    name: row.name,
    role: row.role,
    avatarUrl: row.avatar_url,
    bio: row.bio,
    gender: row.gender,
  };
}

function mapPublicUser(row: UserRow): PublicUser {
  return {
    id: row.id,
    name: row.name,
    role: row.role,
    avatarUrl: row.avatar_url,
    bio: row.bio,
    gender: row.gender,
  };
}

function mapStoredUser(row: UserRow): StoredUser {
  return {
    ...mapUser(row),
    password: row.password,
  };
}

async function createUser(
  data: CreateUserDTO & { password: string },
): Promise<User> {
  const id = randomUUID();

  await db.execute(
    `INSERT INTO users (id, email, name, password, role)
     VALUES (?, ?, ?, ?, ?)`,
    [id, data.email, data.name, data.password, data.role],
  );

  return {
    id,
    email: data.email,
    name: data.name,
    role: data.role,
    avatarUrl: null,
    bio: null,
    gender: null,
  };
}

async function findUserById(id: string): Promise<User | null> {
  const [rows] = await db.execute<UserRow[]>(
    `SELECT id, email, name, password, role, avatar_url, bio, gender
     FROM users WHERE id = ? LIMIT 1`,
    [id],
  );

  const row = rows[0];
  return row ? mapUser(row) : null;
}

async function findPublicUserById(id: string): Promise<PublicUser | null> {
  const [rows] = await db.execute<UserRow[]>(
    `SELECT id, name, role, avatar_url, bio, gender
     FROM users WHERE id = ? LIMIT 1`,
    [id],
  );

  const row = rows[0];
  return row ? mapPublicUser(row) : null;
}

async function findUserByEmail(email: string): Promise<User | null> {
  const [rows] = await db.execute<UserRow[]>(
    `SELECT id, email, name, password, role, avatar_url, bio, gender
     FROM users WHERE email = ? LIMIT 1`,
    [email],
  );

  const row = rows[0];
  return row ? mapUser(row) : null;
}

async function findUserWithPasswordByEmail(
  email: string,
): Promise<StoredUser | null> {
  const [rows] = await db.execute<UserRow[]>(
    `SELECT id, email, name, password, role, avatar_url, bio, gender
     FROM users WHERE email = ? LIMIT 1`,
    [email],
  );

  const row = rows[0];
  return row ? mapStoredUser(row) : null;
}

async function updateUser(
  id: string,
  data: UpdateUserDTO & { password?: string },
): Promise<User | null> {
  const fields: string[] = [];
  const values: string[] = [];

  if (data.email !== undefined) {
    fields.push("email = ?");
    values.push(data.email);
  }

  if (data.name !== undefined) {
    fields.push("name = ?");
    values.push(data.name);
  }

  if (data.password !== undefined) {
    fields.push("password = ?");
    values.push(data.password);
  }

  if (data.avatarUrl !== undefined) {
    fields.push("avatar_url = ?");
    values.push(data.avatarUrl);
  }

  if (data.bio !== undefined) {
    fields.push("bio = ?");
    values.push(data.bio);
  }

  if (data.gender !== undefined) {
    fields.push("gender = ?");
    values.push(data.gender);
  }

  if (fields.length === 0) return findUserById(id);

  values.push(id);

  await db.execute(
    `UPDATE users SET ${fields.join(", ")} WHERE id = ?`,
    values,
  );

  return findUserById(id);
}

export default repo;
