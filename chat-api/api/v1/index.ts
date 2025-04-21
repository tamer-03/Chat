import { Router } from "express";
import authRouter from "./router/auth-router";
import errorHandler from "./middleware/error-handler";
import profileRouter from "./router/profile-router";
const v1Router = Router()

v1Router.use("/auth", authRouter)
v1Router.use("/profile", profileRouter)

v1Router.use(errorHandler)

export default v1Router
