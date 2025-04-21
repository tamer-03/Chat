import { Request,Response,NextFunction } from "express";
import { genericFunc, genericErrorHandler } from "../common/generic-func";
import ResponseModel from "../model/error-model";


const errorHandler = genericErrorHandler((err,req, res, next) => {

    if(err instanceof ResponseModel){
        return res.status(err.status).json(err)
    }

    res.status(500).json(new ResponseModel(err.message, 500))
})



export default errorHandler