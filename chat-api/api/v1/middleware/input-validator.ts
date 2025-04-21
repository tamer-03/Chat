import validator, {ContextRunner} from "express-validator"
import { Request,Response,NextFunction } from "express";
import ResponseModel from "../model/error-model";


const inputValidator = (validations : ContextRunner[]) => {
    return async(req : Request, res : Response, next : NextFunction) => {
        try{
            for(const valid of validations){
                const res = await valid.run(req)
                if(!res.isEmpty()){
                    throw new ResponseModel(res.array()[0].msg, 400)
                }
            }
            next()
        }catch(e){
            next(e)
        }
    }
}

export default inputValidator