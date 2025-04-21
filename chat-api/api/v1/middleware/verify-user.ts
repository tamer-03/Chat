import databasePool from "../../../service/database";
import errorCodes from "../common/error-codes";
import { genericFunc } from "../common/generic-func";
import ResponseModel from "../model/error-model";
import IUser from "../model/interface/iuser";


export const verifyUser = genericFunc(async (req,res,next) => {
    const {email} = res.locals
    if(!email)
        throw new ResponseModel(errorCodes.EMAIL_NOT_VALIDATED, 400)

    const user = await databasePool.query("SELECT `user_id`,`email`,`phone`,`username` FROM users WHERE email = ?", [email])
    
    if(user.length < 0)
        throw new ResponseModel(errorCodes.USER_NOT_FOUND, 400)

    const convertType = user[0] as IUser[]
  
    res.locals.user = {
        user_id : convertType[0].user_id
    }


    next()
})