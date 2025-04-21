import {UAParser} from "ua-parser-js";
import { genericFunc } from "../common/generic-func";

const ua = new UAParser()

const uaParserMiddleware = genericFunc(async(req,res,next) => {
    const parse = ua.setUA(req.headers["user-agent"] ?? "").getResult()

    
    const device = parse.device.type || 'unknown';
    const browser = parse.browser.name || 'unknown';

    const audience = `${device}-${browser}`;

    res.locals.device = device;
    res.locals.browser = browser;
    res.locals.audience = audience;

    next()
})


export default uaParserMiddleware