import { Router } from "express";
import { accessTokenVerify } from "../middleware/token-verify";
import { verifyUser } from "../middleware/verify-user";
import { deleteProfile, getProfile, updateProfile, updateProfilePhoto } from "../controller/profile-controller";
import uaParserMiddleware from "../middleware/ua-parser";
import errorCodes from "../common/error-codes";
import { check } from "express-validator";
import inputValidator from "../middleware/input-validator";
import imageStorage from "../../../service/image-storage";

const profileRouter = Router()

profileRouter.get("/get",[
    uaParserMiddleware,
    accessTokenVerify,
    verifyUser
], getProfile )

profileRouter.put(
    "/update",
    [
        accessTokenVerify,
        verifyUser,
        inputValidator([
            check("username")
                .optional()
                .not()
                .isEmpty()
                .withMessage(errorCodes.USERNAME_EMPTY)
                .escape()
                .trim(),

            check("email")
            .optional()
                .not()
                .isEmpty()
                .withMessage(errorCodes.EMAIL_EMPTY)
                .isEmail()
                .withMessage(errorCodes.EMAIL_NOT_VALIDATED)
                .escape()
                .trim(),

            check("phone")
            .optional()
                .not()
                .isEmpty()
                .withMessage(errorCodes.PHONE_EMPTY)
                .isMobilePhone("tr-TR")
                .withMessage(errorCodes.PHONE_NOT_VALIDATED)
                .escape()
                .trim(),
        ]),
        
    ],
    updateProfile
);

profileRouter.put("/update-photo", [
    accessTokenVerify,
    verifyUser,
    imageStorage.single('photo')
], updateProfilePhoto)

profileRouter.delete("/delete", [
    accessTokenVerify,
    verifyUser
], deleteProfile)


export default profileRouter
