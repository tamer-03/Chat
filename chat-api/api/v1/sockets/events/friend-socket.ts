import { Socket } from "socket.io";
import ResponseModel from "../../model/error-model";
import FriendStatus from "../../model/types/friend-status";
import IResponse from "../../model/interface/iresponse";
import {
  acceptFriendRequestHandler,
  friendRequestHandler,
  getFriendRequestHandler,
  getFriendsHandler,
  rejectFriendRequestHandler,
  searchUserHandler,
} from "../handlers/friends-handler";

const friendSocket = (socket: Socket) => {

  socket.on("get_friends", async (data) => getFriendsHandler(data, socket));

  socket.on("get_friend_requests", async () =>
    getFriendRequestHandler(undefined, socket)
  );

  socket.on("friend_request", async (data) =>
    friendRequestHandler(data, socket)
  );

  socket.on("search_user", async (data) => searchUserHandler(data, socket));

  socket.on("update_friend_request", async (data) => {
    try {
      const { friend_status_type } = data;

      switch (friend_status_type) {
        case FriendStatus.Accepted:
          await acceptFriendRequestHandler(data, socket)
          break;

        case FriendStatus.Rejected:
          await rejectFriendRequestHandler(data,socket)
          break;

        case FriendStatus.Waiting:
          break;

        default:
          socket.emit("update_friend_request_result", {
            message: "Invalid friend status type",
            status: 400,
          } as IResponse);
          break;
      }

    } catch (e) {
      socket.emit("update_friend_request_result", {
        message: "Failed",
        status: 500,
      } as ResponseModel);
    }
  });
};

export default friendSocket;
