import { Server, Socket } from "socket.io";
import jwt from "jsonwebtoken";
import ResponseModel from "../../model/error-model";
import errorCodes from "../../common/error-codes";

export const socketAuthHandler = (socket: Socket, next: (err?: Error) => void) => {
  const token = socket.handshake.auth.token;

  if (!token) {
    next(new Error(errorCodes.TOKEN_MISS));
    return;
  }

  const { JWT_KEY, JWT_ISS } = process.env as {
    JWT_KEY: string;
    JWT_ISS: string;
  };

  if (!JWT_KEY && !JWT_ISS) {
    next(new Error(errorCodes.SOMETHING_WENT_WRONG));
    return;
  }

  try {
    const decoded = jwt.verify(token, JWT_KEY);
    const decode = JSON.parse(JSON.stringify(decoded));
    socket.data.user = {
      user_id: decode["user_id"],
      username: decode["username"],
    };
    next();
  } catch (e) {
    next(new Error(errorCodes.TOKEN_MISS));
  }
};
