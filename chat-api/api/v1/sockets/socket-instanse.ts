import { Server } from "socket.io";

let io : Server

export const setSocketInstanse = (server : Server) => {
    io = server
}

export const getSocketInstanse = () => io