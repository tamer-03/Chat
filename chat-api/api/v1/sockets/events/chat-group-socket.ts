import { Server, Socket } from "socket.io";
import { createGroupChatHandler, getGroupChatHandler } from "../handlers/chat-group-handlers";

const chatGroupSocket = (socket: Socket) => {

  socket.on("get_group_chats", async () => getGroupChatHandler(undefined, socket));

  socket.on("create_group_chat", async (data) => createGroupChatHandler(data, socket));
}

export default chatGroupSocket