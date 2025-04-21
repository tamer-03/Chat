import multer from "multer";
import path from "path";
import fs from "fs"

const storage = multer.diskStorage({
    destination: function (req, file, cb) {

        const {users_id} = req.res?.locals.user
        if (!users_id) {
            cb(new Error('User ID is undefined'), '');
            return
        }

        const uploadPath = path.join('storage', users_id.toString());

        fs.mkdirSync(uploadPath, {recursive : true})

        cb(null, uploadPath)
    },
    filename: function (req, file, cb) {
        const uniqueSuffix = Date.now() + '-' + Math.round(Math.random() * 1E9)
        const splitName = file.originalname.split(".")
        const newName = `.${splitName[splitName.length - 1]}`
        cb(null, uniqueSuffix + newName)
    }
})

const fileFilter = (req: any, file: any, cb: any) => {
    if (file.mimetype === 'image/jpeg' || file.mimetype === 'image/png' || file.mimetype === 'image/jpg') {
        cb(null, true)
    } else {
        cb(null, false)
    }
}

const imageStorage = multer({ storage: storage, fileFilter : fileFilter, limits : { fileSize : 1024 * 1024 * 5 } })

export default imageStorage
