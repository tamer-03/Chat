import { Server } from "socket.io";
import { socketVerifyUser } from "./middleware/socket-verify-user";
import { webSocketAccessTokenVerify } from "./middleware/socket-token-verify";
import friendSocket from "./events/friend-socket";
import chatSocket from "./events/chat-socket";
import chatGroupSocket from "./events/chat-group-socket";
import tokenTimeoutHandler from "./handlers/token-timeout-handler";


const appSocket = (io : Server) => {
  io.use(webSocketAccessTokenVerify)
  io.use(socketVerifyUser)

    io.on('connection', (socket) => {
        const {user_id} = socket.data.user
        socket.join(user_id)

        tokenTimeoutHandler(socket)
        friendSocket(socket)
        chatSocket(socket)
        chatGroupSocket(socket)

        socket.on('disconnect', () => {
          socket.leave(user_id)
        });
      });
}

export default appSocket

