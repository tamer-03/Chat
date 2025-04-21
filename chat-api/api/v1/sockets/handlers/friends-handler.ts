import { Socket } from "socket.io";
import errorCodes from "../../common/error-codes";
import IResponse from "../../model/interface/iresponse";
import ResponseModel from "../../model/error-model";
import {
    checkFriendRequest,
    getFriendRequests,
    getFriends,
    searchUser,
    sendFriendRequest,
    updateFriendRequest,
} from "../helpers/friends-query-helper";
import { findUser } from "../helpers/user-query-helpers";
import FriendStatus from "../../model/types/friend-status";

export const getFriendsHandler = async (data: any, socket: Socket) => {
    try {
        const { user_id } = socket.data.user;

        socket.emit("get_friends_result", {
            message: errorCodes.SUCCESS,
            status: 200,
            value: await getFriends(user_id),
        } as ResponseModel);
    } catch (e) {
        if (e instanceof Error) {
            socket.emit("get_friends_result", {
                message: e.message,
                status: 500,
            } as ResponseModel);
            return;
        }
        socket.emit("get_friends_result", {
            message: "Something went wrong",
            status: 500,
        } as ResponseModel);
    }
};

export const getFriendRequestHandler = async (data: any, socket: Socket) => {
    try {
        const { user_id } = socket.data.user;
        socket.emit("get_friend_requests_result", {
            message: errorCodes.SUCCESS,
            status: 200,
            value: await getFriendRequests(user_id),
        } as ResponseModel);
    } catch (e) {
        if (e instanceof Error) {
            socket.emit("get_friend_requests_result", {
                message: e.message,
                status: 500,
            } as ResponseModel);
            return;
        }
        socket.emit("get_friend_requests_result", {
            message: "Something went wrong",
            status: 500,
        } as ResponseModel);
    }
};

export const friendRequestHandler = async (data: any, socket: Socket) => {
    try {
        const { receiver_id } = data;
        const { user_id, username } = socket.data.user;

        const checkAlreadyRequestSended = await checkFriendRequest(
            user_id,
            receiver_id
        );

        if (checkAlreadyRequestSended.length > 0) {
            socket.emit("friend_request_result", {
                message: "Request already sended",
                status: 400,
            } as ResponseModel);
            return;
        }

        await sendFriendRequest(user_id, receiver_id);

        socket.to(receiver_id).emit("notification_channel", {
            message: `${username ?? "A user"} sent you a friend request`,
            status: 200,
        } as ResponseModel);

        socket.emit("friend_request_result", {
            message: "Request sended",
            status: 200,
        } as ResponseModel);
    } catch (e) {
        if (e instanceof Error) {
            socket.emit("friend_request_result", {
                message: e.message,
                status: 500,
            } as ResponseModel);
            return;
        }
        socket.emit("friend_request_result", {
            message: "Something went wrong",
            status: 500,
        } as ResponseModel);
    }
};

export const searchUserHandler = async (data: any, socket: Socket) => {
    try {
        const { username } = data;
        const { user_id } = socket.data.user

        if (!username) {
            socket.emit("search_user_result", {
                message: "Username required",
                status: 400,
            } as ResponseModel);
            return;
        }

        socket.emit("search_user_result", {
            message: "Success",
            status: 200,
            value: await searchUser(user_id, username),
        } as ResponseModel);
    } catch (e) {
        if (e instanceof Error) {
            socket.emit("search_user_result", {
                message: e.message,
                status: 500,
            } as ResponseModel);
            return;
        }
        socket.emit("search_user_result", {
            message: "Something went wrong",
            status: 500,
        } as ResponseModel);
    }
};


export const rejectFriendRequestHandler = async (data: any, socket: Socket) => {
    try {
        const { sender_id, status } = data;
        const { user_id } = socket.data.user;
        await updateFriendRequest(user_id, sender_id, status);

        socket.emit("notification_channel", {
            message: errorCodes.SUCCESS,
            status: 200,
        } as ResponseModel);

    } catch (e) {
        socket.emit("notification_channel", {
            message: "Failed",
            status: 500,
        } as ResponseModel);
    }
}

export const acceptFriendRequestHandler = async (data: any, socket: Socket) => {
    try {

        const { sender_id, status } = data;
        const {user_id} = socket.data.user
        await updateFriendRequest(user_id, sender_id, status);
        const user = await findUser(user_id);

        if (
            (status as string).toLowerCase().trim() ==
            FriendStatus.Accepted.toLowerCase().trim()
        ) {
            socket.to(sender_id).emit("notification_channel", {
                message: `${user[0].username ?? "A user"
                    } accepted your friend request`,
                status: 200,
            } as IResponse);
        }

    } catch (e) {
        socket.emit("notification_channel", { message : "Failed", status : 500 } as IResponse)
    }
}