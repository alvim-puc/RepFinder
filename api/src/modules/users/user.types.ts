export type UserRole = "student" | "representative";

export type Gender = "female" | "male" | "non_binary" | "other";

export type User = {
  id: string;
  email: string;
  name: string;
  role: UserRole;
  avatarUrl: string | null;
  bio: string | null;
  gender: Gender | null;
};

export type StoredUser = User & {
  password: string;
};

export type CreateUserDTO = {
  email: string;
  name: string;
  password: string;
  role: UserRole;
};

export type LoginDTO = {
  email: string;
  password: string;
};

export type UpdateUserDTO = {
  email?: string;
  name?: string;
  password?: string;
  avatarUrl?: string;
  bio?: string;
  gender?: Gender;
};

export type PublicUser = {
  id: string;
  name: string;
  role: UserRole;
  avatarUrl: string | null;
  bio: string | null;
  gender: Gender | null;
};

export type AuthResponse = {
  user: User;
  token: string;
};
