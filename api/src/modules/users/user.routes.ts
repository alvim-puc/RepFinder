import { Hono } from "hono";
import { authMiddleware } from "@/lib/auth";
import { getValidatedBody, validateBody } from "@/lib/validator";
import service from "./user.service";
import type { CreateUserDTO, LoginDTO, UpdateUserDTO } from "./user.types";
import {
  createUserValidator,
  loginUserValidator,
  updateUserValidator,
} from "./user.validator";

const app = new Hono();

app.post("/register", validateBody(createUserValidator), async (c) => {
  const body = getValidatedBody<CreateUserDTO>(c);
  const result = await service.register(body);
  return c.json(result, 201);
});

app.post("/login", validateBody(loginUserValidator), async (c) => {
  const body = getValidatedBody<LoginDTO>(c);
  const result = await service.login(body);
  return c.json(result);
});

app.get("/me", authMiddleware, async (c) => {
  const { userId } = c.get("authUser");
  const result = await service.getMe(userId);
  return c.json(result);
});

app.patch(
  "/me",
  authMiddleware,
  validateBody(updateUserValidator),
  async (c) => {
    const { userId } = c.get("authUser");
    const body = getValidatedBody<UpdateUserDTO>(c);
    const result = await service.updateMe(userId, body);
    return c.json(result);
  },
);

// perfil público — sem authMiddleware, sem email
app.get("/:id", async (c) => {
  const userId = c.req.param("id");
  const result = await service.getPublicProfile(userId);
  return c.json(result);
});

export default app;
