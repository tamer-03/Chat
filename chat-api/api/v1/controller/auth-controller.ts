import errorCodes from "../common/error-codes";
import { genericFunc } from "../common/generic-func";
import ResponseModel from "../model/error-model";
import IUser from "../model/interface/iuser";
import bcrypt from "bcrypt"
import jwt from "jsonwebtoken"
import databasePool from "../../../service/database";
import { DeviceTypes } from "../model/types/device-types";
import ProfileStatus from "../model/types/profile-status";
import { NextFunction } from "express";

export const signUp = genericFunc(async(req,res,next) => {
    const {username,email,password,phone} = req.body

    const result = (await databasePool.query("select lower(username) as username , lower(email) as email, lower(phone) as phone from users where email = lower(?) or phone = lower(?)", [email,phone]))[0] as IUser[]
    if(result.length > 0){
        const message = (`${username}`.trim().toLowerCase().match(result[0].username.trim().toLowerCase())) ? errorCodes.USERNAME_ALREADY_USING :
        (`${email}`.trim().toLowerCase().match(result[0].email.trim().toLowerCase())) ? errorCodes.EMAIL_ALREADY_USING : 
        (`${phone}`.trim().toLowerCase().match(result[0].phone.trim().toLowerCase())) ? errorCodes.PHONE_ALREADY_EXISTS : "Something went wrong"

        if(message.length > 0)
          throw new ResponseModel(message, 400)
    }

    const hashPass = await bcrypt.hash(password, parseInt(`${process.env.SALT_ROUND}`))

    await databasePool.query("insert into users (username,email,password,phone,photo) values(?,?,?,?,?)",[username,email,hashPass,phone, 'default_profile_image.png'])
    res.json(new ResponseModel(errorCodes.SUCCESS, 200))
})



export const signIn = genericFunc(async (req,res,next) => {

    const {email,password} = req.body
    const { device,browser,audience } = res.locals
    
    if (!device && !browser) {
        throw new ResponseModel(errorCodes.UNKNOWN_DEVICE, 500);
    }

    const user = (await databasePool.query(`select users.email, users.password from users where email = ?`,[email]))[0] as IUser[]
    
    if(user.length <= 0)
        throw new ResponseModel(errorCodes.USER_NOT_FOUND, 404)

    if(user[0].is_active == ProfileStatus.DEACTIVE){
        throw new ResponseModel(errorCodes.USER_NOT_FOUND, 404)
    }


    const checkPassword = await bcrypt.compare(password, user[0].password)

    if(!checkPassword)
        throw new ResponseModel(errorCodes.WRONG_PASSWORD,400)

    const { JWT_KEY , JWT_ISS} = process.env as { 
        JWT_KEY: string; 
        JWT_ISS : string;
    };

    if(!JWT_KEY || !JWT_ISS){
        throw new ResponseModel(errorCodes.SOMETHING_WENT_WRONG, 500)
    }

    const access_token = jwt.sign({email : user[0].email}, JWT_KEY, { 
        expiresIn : '1d',
        subject : user[0].email,
        issuer : JWT_ISS,
        audience : audience
    })

    const refresh_token = jwt.sign({email : user[0].email, isRefreshToken : true}, JWT_KEY, { 
        expiresIn : '30d',
        subject : user[0].email,
        issuer : JWT_ISS,
        audience : audience
    })

    if (device === DeviceTypes.MOBILE || device === DeviceTypes.TABLET || device === DeviceTypes.DESKTOP){
        res.json(new ResponseModel(errorCodes.SUCCESSFULLY_SIGNED_IN, 200, [{ access_token, refresh_token }]));
        return
    } else if(browser){
        res.cookie("device", audience, { maxAge: 3600 * 1000, httpOnly: true });
        res.cookie("access_token", access_token, { maxAge: 3600 * 1000, httpOnly: true });
        res.cookie("refresh_token", refresh_token, { maxAge: (30 * 24 * 60 * 60 * 1000), httpOnly: true });
        res.json(new ResponseModel(errorCodes.SUCCESSFULLY_SIGNED_IN, 200));
    }else {
        throw new ResponseModel(errorCodes.UNKNOWN_DEVICE, 500)
    }
})
  

export const resetPasssword = genericFunc(async (req,res,next) => {
    const { user_id } = res.locals.user
    const {password} = req.body

    const hashNewPass = await bcrypt.hash(password, parseInt(`${process.env.SALT_ROUND}`))

    await databasePool.query("UPDATE `users` SET `password`= ? where user_id = ?",[hashNewPass, user_id])
    res.json(new ResponseModel(errorCodes.PASSWORD_UPDATED, 200))
})

export const refreshToken = genericFunc(async (req,res,next) => {
    const { audience,device,browser  } = res.locals
    const {user_id} = res.locals.user

   
    const query = await databasePool.query("SELECT `user_id`,`email` FROM `users` WHERE user_id = ?",[user_id])
    const user = query[0] as IUser[]

    if(user.length < 0)
        throw new ResponseModel(errorCodes.USER_NOT_FOUND, 404)

    const { JWT_KEY , JWT_ISS} = process.env as { 
        JWT_KEY: string; 
        JWT_ISS : string;
    };

    if(!JWT_KEY || !JWT_ISS){
        throw new ResponseModel(errorCodes.SOMETHING_WENT_WRONG, 500)
    }

    const access_token = jwt.sign({email : user[0].email}, JWT_KEY, { 
        expiresIn : '1d',
        subject : user[0].email,
        issuer : JWT_ISS,
        audience : audience
    })

    if (device === DeviceTypes.MOBILE || device === DeviceTypes.TABLET || device === DeviceTypes.DESKTOP){
        res.json(new ResponseModel(errorCodes.SUCCESSFULLY_SIGNED_IN, 200, [{ access_token }]));
        return
    } else if(browser){
        res.cookie("access_token", access_token, { maxAge: 3600 * 1000, httpOnly: true });
        res.json(new ResponseModel(errorCodes.SUCCESSFULLY_SIGNED_IN, 200));
    }else {
        throw new ResponseModel(errorCodes.UNKNOWN_DEVICE, 500)
    }

})


export const signOut = genericFunc(async (req ,res ,next) => {
    res.clearCookie("access_token")
    res.clearCookie("refresh_token")
    res.clearCookie("device")
    res.json(new ResponseModel(errorCodes.SUCCESSFULLY_SIGN_OUT, 200))
})
