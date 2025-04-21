import {ExtendedError, Socket, } from "socket.io";
import errorCodes from "../../common/error-codes";
import jwt from "jsonwebtoken"

interface Token {
    email : string,
    isRefreshToken : boolean
}

export const webSocketAccessTokenVerify = (socket : Socket, next : (err? : ExtendedError) => void) => {
    try{
        const token = (socket.client.request.headers.cookie ?? "").split("; ").find(cookie => cookie.trim().startsWith("access_token"))?.trim()?.replace("access_token=", "") || socket.handshake.auth.token
        if(!token) {
            next(new Error(errorCodes.TOKEN_MISS))
            return
        }


        const {JWT_KEY} = process.env as {
            JWT_KEY : string
        }

        if(!JWT_KEY){
            next(new Error("Something went wrong"))
            return
        }

        const decode = jwt.verify(token,JWT_KEY) as Token
        socket.data.user_email = decode.email

        next()
    }catch(e){
        if(e instanceof Error){
            next(new Error(e.message))
            return
        }
        next(new Error("Something went wrong"))
    }   
}

