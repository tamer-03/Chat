import { Socket } from "socket.io";
import errorCodes from "../../common/error-codes";
import { createGroupChat, getGroups } from "../helpers/group-chat-helpers";
import IResponse from "../../model/interface/iresponse";

export const getGroupChatHandler = async (data: any, socket: Socket) => {
    try {
        const { user_id } = socket.data.user
        socket.emit("get_group_chats_result", {
            message: errorCodes.SUCCESS,
            value: await getGroups(user_id),
            status: 200,
        } as IResponse);

    } catch (e) {
        if (e instanceof Error) {
            socket.emit("get_group_chats_result", {
                message: e.message,
                status: 500,
            } as IResponse);
            return;
        }

        socket.emit("get_group_chats_result", {
            message: errorCodes.SOMETHING_WENT_WRONG,
            status: 500,
        } as IResponse);
    }
};

export const createGroupChatHandler = async (data: any, socket: Socket) => {
    try {
        const { group_name, members } = data
        const { user_id } = socket.data.user

        await createGroupChat(group_name, user_id, members)

        socket.emit("create_group_chat_result", {
            message: "Group created",
            status: 200,
        } as IResponse);

    } catch (e) {
        if (e instanceof Error) {
            socket.emit("create_group_chat_result", {
                message: e.message,
                status: 500,
            } as IResponse);
        }
        socket.emit("create_group_chat_result", {
            message: "Something went wrong",
            status: 500,
        } as IResponse);
    }
}
