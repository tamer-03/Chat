import { genericFunc } from "../common/generic-func";
import jwt from "jsonwebtoken";
import ResponseModel from "../model/error-model";
import errorCodes from "../common/error-codes";
import { Request } from "express";

type TokenType = "access_token" | "refresh_token";

export const accessTokenVerify = genericFunc((req, res, next) => {
    const token = extractToken("access_token", req);

        if (!token) throw new ResponseModel(errorCodes.TOKEN_MISS, 401);
    
        const { JWT_KEY, JWT_ISS } = process.env as {
            JWT_KEY: string;
            JWT_ISS: string;
        };
    
        if (!JWT_KEY && !JWT_ISS)
            throw new ResponseModel(errorCodes.SOMETHING_WENT_WRONG, 500);
    
        const decoded = jwt.verify(token, JWT_KEY);
    
        const decode = JSON.parse(JSON.stringify(decoded));
        res.locals.email = decode["email"];
    
        next();
});

export const refreshTokenVerify = genericFunc((req, res, next) => {

    const token = extractToken("refresh_token", req);
    if (!token) throw new ResponseModel(errorCodes.TOKEN_MISS, 400);

    const { JWT_KEY, JWT_ISS } = process.env as {
        JWT_KEY: string;
        JWT_ISS: string;
    };

    if (!JWT_KEY && !JWT_ISS)
        throw new ResponseModel(errorCodes.SOMETHING_WENT_WRONG, 500);

    const decoded = jwt.verify(token, JWT_KEY);

    const decode = JSON.parse(JSON.stringify(decoded));
    if (
        !decode["isRefreshToken"] ||
        typeof decode["isRefreshToken"] !== "boolean" ||
        !decode["isRefreshToken"]
    ) {
        throw new ResponseModel(errorCodes.TOKEN_MISS, 401);
    }

    res.locals.email = decode["email"];
    next();
});

const extractToken = (
    tokenType: TokenType,
    req: Request
): string | undefined => {
    if (req.cookies[tokenType]) {
        return req.cookies[tokenType];
    }

    const token = req.headers.authorization;

    if (token) {
        const parts = token.replace("Bearer ", "");
        return parts;
    }

    return undefined;
};
