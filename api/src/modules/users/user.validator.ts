import type { Validator } from "@/lib/validator";
import type {
  CreateUserDTO,
  Gender,
  LoginDTO,
  UpdateUserDTO,
  UserRole,
} from "./user.types";

const validRoles: UserRole[] = ["student", "representative"];
const validGenders: Gender[] = ["female", "male", "non_binary", "other"];

function isValidUrl(value: string): boolean {
  try {
    const url = new URL(value);
    return url.protocol === "http:" || url.protocol === "https:";
  } catch {
    return false;
  }
}

export const createUserValidator: Validator<CreateUserDTO> = (data) => {
  if (typeof data !== "object" || data === null) {
    throw new Error("Payload must be an object");
  }

  const obj = data as Record<string, unknown>;

  if (typeof obj.email !== "string") {
    throw new Error("email must be a string");
  }

  if (typeof obj.name !== "string") {
    throw new Error("name must be a string");
  }

  if (typeof obj.password !== "string") {
    throw new Error("password must be a string");
  }

  if (obj.password.length < 6) {
    throw new Error("password must be at least 6 characters");
  }

  if (
    typeof obj.role !== "string" ||
    !validRoles.includes(obj.role as UserRole)
  ) {
    throw new Error("role must be student or representative");
  }

  return {
    email: obj.email,
    name: obj.name,
    password: obj.password,
    role: obj.role as UserRole,
  };
};

export const loginUserValidator: Validator<LoginDTO> = (data) => {
  if (typeof data !== "object" || data === null) {
    throw new Error("Payload must be an object");
  }

  const obj = data as Record<string, unknown>;

  if (typeof obj.email !== "string") {
    throw new Error("email must be a string");
  }

  if (typeof obj.password !== "string") {
    throw new Error("password must be a string");
  }

  return {
    email: obj.email,
    password: obj.password,
  };
};

export const updateUserValidator: Validator<UpdateUserDTO> = (data) => {
  if (typeof data !== "object" || data === null) {
    throw new Error("Payload must be an object");
  }

  const obj = data as Record<string, unknown>;
  const payload: UpdateUserDTO = {};

  if (obj.email !== undefined) {
    if (typeof obj.email !== "string") {
      throw new Error("email must be a string");
    }
    payload.email = obj.email;
  }

  if (obj.name !== undefined) {
    if (typeof obj.name !== "string") {
      throw new Error("name must be a string");
    }
    payload.name = obj.name;
  }

  if (obj.password !== undefined) {
    if (typeof obj.password !== "string") {
      throw new Error("password must be a string");
    }
    if (obj.password.length < 6) {
      throw new Error("password must be at least 6 characters");
    }
    payload.password = obj.password;
  }

  if (obj.avatarUrl !== undefined) {
    if (typeof obj.avatarUrl !== "string" || !isValidUrl(obj.avatarUrl)) {
      throw new Error("avatarUrl must be a valid http/https URL");
    }
    payload.avatarUrl = obj.avatarUrl;
  }

  if (obj.bio !== undefined) {
    if (typeof obj.bio !== "string") {
      throw new Error("bio must be a string");
    }
    if (obj.bio.length > 500) {
      throw new Error("bio must be at most 500 characters");
    }
    payload.bio = obj.bio;
  }

  if (obj.gender !== undefined) {
    if (
      typeof obj.gender !== "string" ||
      !validGenders.includes(obj.gender as Gender)
    ) {
      throw new Error("gender must be female, male, non_binary or other");
    }
    payload.gender = obj.gender as Gender;
  }

  if (Object.keys(payload).length === 0) {
    throw new Error("At least one field must be provided");
  }

  return payload;
};
