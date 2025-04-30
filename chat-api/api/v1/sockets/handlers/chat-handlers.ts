import { Socket } from "socket.io";
import {
  checkChat,
  checkOneSeemedMessage,
  createChat,
  deleteChatMessage,
  editChatMessage,
  getChatMembers,
  getChatMessages,
  getChats,
  getSeemedMessages,
  markMessageAsSeen,
  sendChatMessage,
} from "../helpers/chat-query-helpers";
import ResponseModel from "../../model/error-model";
import { getSocketInstanse } from "../socket-instanse";
import errorCodes from "../../common/error-codes";
import { writeFileToFolderAsync } from "../../../../service/file-service";
import databasePool from "../../../../service/database";
import IResponse from "../../model/interface/iresponse";
import { ChatType } from "../../model/types/chat-type";
import { getLastGroupChatMessage } from "../helpers/group-chat-helpers";

export const sendTextMessageHandler = async (data: any, socket: Socket) => {
  try {
    const { user_id } = socket.data.user;
    const { chat_id, message, chat_type } = data;
    console.log("message", message, chat_id, chat_type);
    const io = getSocketInstanse();

    const ifError = await sendChatMessage(message, user_id, chat_id);
    if (ifError) {
      socket.emit("notification_channel", {
        message: "Your message could not be sent. Please try again",
        status: 400,
      } as ResponseModel);
      return;
    }

    const lastMessage = await getChatMessages(
      user_id,
      chat_id,
      undefined,
      1
    );

    io.to(chat_id).emit("get_last_chat_message", {
      message: errorCodes.SUCCESS,
      status: 200,
      value: lastMessage,
    } as ResponseModel);

    switch (chat_type) {
      case ChatType.PERSONAL:
        io.to(chat_id).emit("get_chats_result", {
          message: errorCodes.SUCCESS,
          status: 200,
          value: lastMessage,
        } as ResponseModel);
        break;

      case ChatType.GROUP:
        const lastGroupMessage = await getLastGroupChatMessage(
          chat_id,
          user_id,
          undefined,
          1
        );

        io.to(chat_id).emit("get_group_chats_result", {
          message: errorCodes.SUCCESS,
          status: 200,
          value: lastGroupMessage,
        } as ResponseModel);
        break;

      default:
        break;
    }

    
  } catch (e) {
    if (e instanceof Error) {
      socket.emit("get_last_chat_message", {
        message: e.message,
        status: 500,
      } as ResponseModel);
      return;
    }
    socket.emit("get_last_chat_message", {
      message: errorCodes.SOMETHING_WENT_WRONG,
      status: 500,
    } as ResponseModel);
  }
};

export const sendImageMessageHandler = async (data: any, socket: Socket) => {
  try {
    const io = getSocketInstanse();
    const { chat_id, images } = data;
    const { user_id } = socket.data.user;

    const getMembers = await getChatMembers(chat_id);

    if (getMembers.length <= 0) {
      socket.emit("notification_channel", {
        message: "Chat not founded",
        status: 400,
      } as ResponseModel);
      return;
    }

    const imgs = images as string[];

    const fileNames = await writeFileToFolderAsync(chat_id, imgs);

    await Promise.all(
      fileNames.map(async (e) => {
        await databasePool.query(
          "insert into chat_messages(chat_image,message,user_id, chat_id) values(?,?,?, uuid_to_bin(?))",
          [e, "Image", user_id, chat_id]
        );
      })
    );

    const lastMessage = await getChatMessages(user_id, chat_id, undefined, 1);

    const userIds = getMembers.map((e) => e.user_id);

    io.to(chat_id).emit("get_last_chat_message", {
      message: errorCodes.SUCCESS,
      status: 200,
      value: lastMessage,
    } as ResponseModel);

    io.to(userIds).emit("get_chats_result", {
      message: errorCodes.SUCCESS,
      status: 200,
      value: lastMessage,
    } as ResponseModel);

    socket.emit("notification_channel", {
      message: errorCodes.SUCCESS,
      status: 200,
    } as ResponseModel);
  } catch (e) {
    if (e instanceof Error) {
      socket.emit("notification_channel", {
        message: e.message,
        status: 500,
      } as ResponseModel);
      return;
    }
    socket.emit("notification_channel", {
      message: errorCodes.SOMETHING_WENT_WRONG,
      status: 500,
    } as ResponseModel);
  }
};

export const editChatMessageHandler = async (data: any, socket: Socket) => {
  try {
    const { chat_message_id, chat_id } = data;
    const io = getSocketInstanse();
    const { user_id } = socket.data.user;

    await editChatMessage(chat_id, chat_message_id, data.message);

    io.to(chat_id).emit("get_chat_messages_result", {
      message: errorCodes.SUCCESS,
      status: 200,
      value: await getChatMessages(user_id, chat_id),
    } as ResponseModel);

    socket.emit("edit_chat_message_result", {
      message: "Message updated",
      status: 200,
    } as ResponseModel);
  } catch (e) {
    if (e instanceof Error) {
      socket.emit("edit_chat_message_result", {
        message: e.message,
        status: 500,
      } as IResponse);
      return;
    }

    socket.emit("edit_chat_message_result", {
      message: errorCodes.SOMETHING_WENT_WRONG,
      status: 500,
    } as IResponse);
  }
};

export const deleteChatMessageHandler = async (data: any, socket: Socket) => {
  try {
    const { chat_message_id, chat_id } = data;
    const io = getSocketInstanse();
    const { user_id } = socket.data.user;

    await deleteChatMessage(chat_id, chat_message_id);

    io.to(chat_id).emit("get_chat_messages_result", {
      message: errorCodes.SUCCESS,
      status: 200,
      value: await getChatMessages(user_id, chat_id),
    } as ResponseModel);

    socket.emit("delete_chat_message_result", {
      message: "Message deleted",
      status: 200,
    } as ResponseModel);
  } catch (e) {
    if (e instanceof Error) {
      socket.emit("delete_chat_message_result", {
        message: e.message,
        status: 500,
      } as IResponse);
      return;
    }

    socket.emit("delete_chat_message_result", {
      message: errorCodes.SOMETHING_WENT_WRONG,
      status: 500,
    } as IResponse);
  }
};

export const messageSeemedHandler = async (data: any, socket: Socket) => {
  try {
    const { chat_message_id, chat_id } = data;
    const { user_id } = socket.data.user;
    const io = getSocketInstanse();

    const lastMessage = await getChatMessages(user_id, chat_id, undefined, 1);

    if (lastMessage[lastMessage.length - 1].user_id == user_id) {
      return;
    }
    await markMessageAsSeen(chat_message_id, user_id, chat_id);

    io.to(chat_id).emit("messages_seemed_result", {
      message: errorCodes.SUCCESS,
      status: 200,
      value: await checkOneSeemedMessage(chat_id, chat_message_id),
    } as ResponseModel);
  } catch (e) {
    if (e instanceof Error) {
      socket.emit("notification_channel", {
        message: e.message,
        status: 500,
      } as IResponse);
      return;
    }

    socket.emit("notification_channel", {
      message: errorCodes.SOMETHING_WENT_WRONG,
      status: 500,
    } as IResponse);
  }
};


export const getChatMessageHandler = async (data: any, socket: Socket) => {
  try {
    const { chat_id } = data;
    const { user_id } = socket.data.user;
    const io = getSocketInstanse();

    const messages = await getChatMessages(user_id, chat_id);

    if (messages.length > 0) {
      await Promise.all(
        messages
          .filter((e) => e.user_id != user_id)
          .map((e) => markMessageAsSeen(e.chat_message_id, user_id, chat_id))
      );
    }

    const seemedMessages = await getSeemedMessages(chat_id);

    socket.emit("get_chat_messages_result", {
      message: errorCodes.SUCCESS,
      status: 200,
      value: messages,
    } as ResponseModel);

    io.to(chat_id).emit("messages_seemed_result", {
      message: errorCodes.SUCCESS,
      status: 200,
      value: seemedMessages,
    });
  } catch (e) {
    if (e instanceof Error) {
      socket.emit("get_chat_messages_result", {
        message: e.message,
        status: 500,
      } as ResponseModel);
      return;
    }
    socket.emit("get_chat_messages_result", {
      message: errorCodes.SOMETHING_WENT_WRONG,
      status: 500,
    } as ResponseModel);
  }
};

export const createChatHandler = async (data: any, socket: Socket) => {
  try {
    // Want to start a chat with this user.
    const { to_user_id } = data;
    const { user_id } = socket.data.user;
    const io = getSocketInstanse();

    const checkChatList = await checkChat(user_id, to_user_id);

    if (checkChatList.length > 0) {
      socket.emit("create_chat_result", {
        message: "Chat already exists",
        status: 400,
      } as ResponseModel);
      return;
    }

    await createChat(user_id, to_user_id);

    socket.emit("create_chat_result", {
      message: errorCodes.SUCCESS,
      status: 200,
    } as ResponseModel);
    

    socket.emit("get_chats_result", {
      message: errorCodes.SUCCESS,
      status: 200,
      value: await getChats(user_id),
    } as ResponseModel);
  } catch (e) {
    if (e instanceof Error) {
      socket.emit("create_chat_result", {
        message: e.message,
        status: 500,
      } as ResponseModel);
    }
    socket.emit("create_chat_result", {
      message: "Something went wrong",
      status: 500,
    } as ResponseModel);
  }
};

export const getChatsHandler = async (data: any, socket: Socket) => {
  try {
    const { user_id } = socket.data.user;

    const getChat = await getChats(user_id);

    socket.emit("get_chats_result", {
      message: errorCodes.SUCCESS,
      status: 200,
      value: getChat,
    } as ResponseModel);
  } catch (e) {
    if (e instanceof Error) {
      socket.emit("get_chats_result", {
        message: e.message,
        status: 500,
      } as ResponseModel);
      return;
    }

    socket.emit("get_chats_result", {
      message: errorCodes.SOMETHING_WENT_WRONG,
      status: 500,
    } as ResponseModel);
  }
};
