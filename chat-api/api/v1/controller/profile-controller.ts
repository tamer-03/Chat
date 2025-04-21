import databasePool from "../../../service/database";
import errorCodes from "../common/error-codes";
import { genericFunc, genericProfilePhotoCompleter } from "../common/generic-func";
import ResponseModel from "../model/error-model";
import IUser from "../model/interface/iuser";
import path from "path"

export const getProfile = genericFunc(async (req, res, next) => {
  const { user_id } = res.locals.user;

  const user = await databasePool.query(
    "SELECT user_id,username,email,phone,photo FROM `users` where user_id = ?",
    [user_id]
  );
  if (user.length < 0) {
    throw new ResponseModel(errorCodes.USER_NOT_FOUND, 400);
  }

  const dto = genericProfilePhotoCompleter(user[0] as IUser[]);
  

  res.json(new ResponseModel(errorCodes.SUCCESS, 200, dto));
});

export const updateProfile = genericFunc(async (req, res, next) => {
  const { user_id } = res.locals.user;
  const { username, email, phone } = req.body;


  await databasePool.query(
    `update users set username = ? , email = ? , phone = ? where user_id = ?`,
    [username, email, phone ,user_id]
  );

  res.json(new ResponseModel("Profile updated", 200));
});


export const updateProfilePhoto = genericFunc(async (req,res,next) => {
  const {user_id} = res.locals.user
  const file = req.file


  const user = (await databasePool.query(
    "SELECT photo FROM `users` where user_id = ?",
    [user_id]
  ))[0] as IUser[];

  if(user[0].photo){
    const fs = require('fs');
    const path = require('path');
    const filePath = path.join(__dirname, '../../../storage', user_id.toString(), user[0].photo);
    if (fs.existsSync(filePath)) {
      fs.unlinkSync(filePath);
    }
  }

  await databasePool.query(
    `update users set photo = ? where users_id = ?`,
    [file?.filename ,user_id]
  );

  res.json(new ResponseModel('Profile Updated', 200))
})

export const deleteProfile = genericFunc(async (req,res,next) => {
  const { user_id } = res.locals.user
  await databasePool.query(`update users set username = ?, email = '', password = '', is_active = ? where user_id = ?`, ['deleted_account', 'DEACTIVE' ,user_id])

  res.json({ message : "Profile deleted", status : 200 } as ResponseModel)
})