import { send } from "node:process";
import databasePool from "../../../../service/database";
import ResponseModel from "../../model/error-model";
import IUser from "../../model/interface/iuser";

interface IFriends {
  user_id: number;
  username: string;
  photo: string | undefined;
  email: string;
}

interface IFriendRequests{
    user_id : number,
    username : string,
    email : string,
    photo : string
}

interface IFriend{
  sender_id : number,
  receiver_id : number,
  status : string
}

interface ISearchUsers{
  user_id : number,
  username : string,
  email : string,
  photo : string,
  friend_status : IFriendStatus
}

type IFriendStatus = "ACCEPTED" | "WAITING" | "NOT_FRIENDS";


export const getFriends = async (
  user_id: number
): Promise<IFriends[]> => {
  try {
    return (
      /*
      
         */
      await databasePool.query(
        `SELECT u.user_id, u.username, u.email, CASE
        WHEN u.photo IS NULL THEN '/storage/defaults/default_profile_image.png'
        ELSE CONCAT('/storage/', u.user_id, '/', u.photo)
    END AS photo  FROM friends f LEFT JOIN users u ON (u.user_id = CASE WHEN f.sender_id = ? THEN f.receiver_id ELSE f.sender_id END)
        WHERE f.status = 'Accepted'  
        AND (f.sender_id = ? OR f.receiver_id = ?) `,
        [user_id, user_id, user_id]
      )
    )[0] as IFriends[];
  } catch (e) {
    return [];
  }
};


export const getFriendRequests = async(user_id : number) : Promise<IFriendRequests[]> => {
    try{
      return (await databasePool.query(
        `select u.user_id, u.username, u.email, case when u.photo is null then '/storage/defaults/default_profile_image.png' else concat('/storage/',u.user_id,'/',u.photo) end from users u inner join friends f on f.sender_id = u.user_id where f.receiver_id = ? and f.status = 'waiting'`,
        [user_id , 'waiting']
      ))[0] as IFriendRequests[]
    }catch(e){
      return []
    }
}

export const checkFriendRequest = async(user_id : number, receiver_id : number) : Promise<IFriend[]> => {
  try{
    return (await databasePool.query(
      `SELECT sender_id, receiver_id, status FROM friends where sender_id = ? and receiver_id = ?`,
      [user_id,receiver_id]
    ))[0] as IFriend[]
  }catch(e){
    return[]
  }
}

export const sendFriendRequest = async(user_id : number, receiver_id : number) => {
  (await databasePool.query(
    `insert into friends (sender_id, receiver_id) values (?,?)`,
    [user_id,receiver_id]
  ))
}

export const searchUser = async(user_id : number,username : string) : Promise<ISearchUsers[]> => {
  return (await databasePool.query(
    `SELECT DISTINCT
    u.user_id,
    u.username,
    u.email,
    CASE
      WHEN f.status = 'ACCEPTED' THEN 'ACCEPTED'
      WHEN f.status = 'WAITING' THEN 'WAITING'
      ELSE 'not_friends'
    END AS friend_status,
    case when u.photo is null then '/storage/defaults/default_profile_image.png' else concat('/storage/',u.user_id,'/',u.photo) end as photo
  FROM users u
  LEFT JOIN friends f 
    ON (
         (u.user_id = f.sender_id AND f.receiver_id = ?)
         OR
         (u.user_id = f.receiver_id AND f.sender_id = ?)
       )
       AND f.status IN ('ACCEPTED', 'WAITING')
  WHERE LOWER(u.username) LIKE LOWER(?)
    AND u.user_id != ?;`,
    [
      user_id,
      user_id,
      `%${username}%`,
      user_id,
    ]
  ))[0] as ISearchUsers[] 
}


export const updateFriendRequest = async (user_id : number, receiver_id : number,status : string) => {
  await databasePool.query(
    `update friends f set f.status = ? where receiver_id = ? and sender_id = ?`,
    [status,user_id, receiver_id]
  )
}

export const getChatMessages = async (chat_id : string) => {
  return await databasePool.query(
    `SELECT user.username, user.photo, message.message,message.user_id, message.chat_image, message.sended_at, BIN_TO_UUID(message.chat_message_id) as chat_message_id
FROM chat_messages message inner join users user on user.user_id = message.user_id
WHERE chat_id = UUID_TO_BIN(?) order by message.sended_at ASC`,
    [chat_id]
  );
}