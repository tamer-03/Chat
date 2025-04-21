import { ExtendedError, Socket } from "socket.io";
import databasePool from "../../../../service/database";
import IUser from "../../model/interface/iuser";


export const socketVerifyUser = async(socket : Socket, next : (err?: ExtendedError) => void) => {
    try{
        const email = socket.data.user_email
        if(!email){
            next(new Error("Email not validated"))
            return
        }
    
        const findUser = (await databasePool.query("SELECT user_id,username,email,phone FROM `users` where email = ?", [email]))[0] as IUser[]
        if(findUser.length < 0){
            next(new Error("User not found"))
            return
        }

        socket.data.user = findUser[0]
        next()
    }catch(e){
        if(e instanceof Error){
            next(e)
            return
        }
        next(new Error("Something went wrong"))
        
    }
}