import * as dotenv from 'dotenv'
dotenv.config()
import express from "express"
import bodyParser from "body-parser"
import cookieParser from "cookie-parser"
import v1Router from "./api/v1"
import http from "http"
import "./service/database"
import { Server } from 'socket.io'
import cors from "cors"
import appSocket from './api/v1/sockets'
import { setSocketInstanse } from './api/v1/sockets/socket-instanse'

const port = 8080
const app = express()

app.use('/storage', express.static('storage'))

const server = http.createServer(app)
const io = new Server(server, {
    cors : {
        origin : process.env.BASE_URL,
        credentials : true,
    }
})
setSocketInstanse(io)

app.use(cors({
    origin : process.env.BASE_URL,
    methods : "GET,HEAD,PUT,PATCH,POST,DELETE",
    credentials : true
}))

app.use(bodyParser.json())
app.use(bodyParser.urlencoded({extended : true}))
app.use(cookieParser())

app.use("/api/v1",v1Router)

appSocket(io)

server.listen(port, () => {
    console.log("Server walking")
})
