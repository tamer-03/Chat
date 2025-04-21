import { StringifyOptions } from "node:querystring";
import databasePool from "../../../../service/database";
import IUser from "../../model/interface/iuser";

interface IChat {
  username: string;
  photo: string;
  user_id: string;
  message: string;
  chat_id: string;
  chat_type : string
}

interface IChatMessage {
  user_id: string;
  username: string;
  photo: string;
  message: string;
  chat_message_id: string;
  sended_at: string;
  chat_id: string;
  chat_image: string;
  chat_type : string
}

interface IChatSeemed {
  id: string;
  chat_message_id: string;
  user_id: string;
  chat_id: string;
}

interface ICreateChatResult {
  chat_id: string;
}

export const getChats = async (user_id: string) => {
  return (
    await databasePool.query(
      `SELECT
    u.username,
    u.user_id,
    cm.chat_id AS chat_id_bin,
    BIN_TO_UUID(cm.chat_id) AS chat_id,
    lm.message,
    ct.chat_type,
    CASE
        WHEN u.photo IS NULL THEN '/storage/defaults/default_profile_image.png'
        ELSE CONCAT('/storage/', u.user_id, '/', u.photo)
    END AS photo
FROM
    chat_members cm
INNER JOIN
    users u ON u.user_id = cm.user_id
INNER JOIN
    chat_table ct ON cm.chat_id = ct.chat_id AND ct.chat_type = 'Personal'
LEFT JOIN
    chat_messages lm ON cm.chat_id = lm.chat_id
    AND lm.sended_at = (
        SELECT
            MAX(m2.sended_at)
        FROM
            chat_messages m2
        WHERE
            m2.chat_id = cm.chat_id
    )
WHERE
    cm.chat_id IN (
        SELECT
            chat_id
        FROM
            chat_members
        WHERE
            user_id = ?
    )
    AND cm.user_id != ?
ORDER BY
    lm.sended_at DESC;`,
      [user_id, user_id]
    )
  )[0] as IChat[];
};

export const getChatMessages = async (
  user_id: string,
  chat_id: string,
  beforeTime?: string,
  limit: number = 30
) => {
  return (
    await databasePool.query(
      `SELECT
    user.user_id AS user_id,
    user.username,
    message.message,
    BIN_TO_UUID(message.chat_message_id) AS chat_message_id,
    message.sended_at,
    BIN_TO_UUID(message.chat_id) AS chat_id,
    ct.chat_type, 
    CASE
        WHEN message.chat_image IS NOT NULL THEN CONCAT('/storage/', BIN_TO_UUID(message.chat_id), '/', message.chat_image)
        ELSE NULL
    END AS chat_image,
    CASE
        WHEN user.photo IS NULL THEN '/storage/defaults/default_profile_image.png'
        ELSE CONCAT('/storage/', user.user_id, '/', user.photo)
    END AS photo
FROM
    chat_messages message
INNER JOIN
    users user ON message.user_id = user.user_id
INNER JOIN
    chat_table ct ON ct.chat_id = message.chat_id 
WHERE
    BIN_TO_UUID(message.chat_id) = ?
    AND message.chat_id IN (
        SELECT chat_id FROM chat_members WHERE user_id = ?
    )
    AND (? IS NULL OR message.sended_at < ?)
ORDER BY message.sended_at DESC
LIMIT ?
`,
      [chat_id, user_id, beforeTime || null, beforeTime || null, limit]
    )
  )[0] as IChatMessage[]
};



/*
SELECT
            user.user_id AS user_id,
            user.username,
            message.message,
            BIN_TO_UUID(message.chat_message_id) AS chat_message_id,
            message.sended_at,
            BIN_TO_UUID(message.chat_id) AS chat_id,
            CASE
                WHEN message.chat_image IS NOT NULL THEN CONCAT('/storage/', BIN_TO_UUID(message.chat_id), '/', message.chat_image)
                ELSE NULL
            END AS chat_image,
            CASE
                WHEN user.photo IS NULL THEN '/storage/defaults/default_profile_image.png'
                ELSE CONCAT('/storage/', user.user_id, '/', user.photo)
            END AS photo
        FROM
            chat_messages message
        INNER JOIN
            users user ON message.user_id = user.user_id
        WHERE
            BIN_TO_UUID(message.chat_id) = ?
            AND message.chat_id IN (
                SELECT chat_id FROM chat_members WHERE user_id = ?
            )
            AND (? IS NULL OR message.sended_at < ?)
        ORDER BY message.sended_at DESC
        LIMIT ? */

export const sendChatMessage = async (
  message: string,
  users_id: string,
  chat_id: string
): Promise<Error | null> => {
  try {
    const getConnection = await databasePool.getConnection();

    await getConnection.beginTransaction();

    await databasePool.query(
      `insert into chat_messages(message, user_id, chat_id) values(?, ?, uuid_to_bin(?))`,
      [message, users_id, chat_id]
    );

    await getConnection.commit();

    return null;
  } catch (e) {
    if (e instanceof Error) {
      return e;
    }
    return Error("Something went wrong");
  }
};

export const createChat = async (user_id: number, to_user_id: number) => {
  try {
  } catch (e) {}
};

export const checkChat = async (user_id: number, to_user_id: number) => {
  return (
    await databasePool.query(
      `select BIN_TO_UUID(chat_id) as chat_id from chat_members where user_id = ? and chat_id in (select chat_id from chat_members where user_id = ?)`,
      [user_id, to_user_id]
    )
  )[0] as ICreateChatResult[];
};

export const getChatMembers = async (chat_id: string): Promise<IUser[]> => {
  if (!chat_id) return [] as IUser[];

  return (
    await databasePool.query(
      `SELECT user_id FROM chat_members where chat_id = uuid_to_bin(?)`,
      [chat_id]
    )
  )[0] as IUser[];
};

export const deleteChatMessage = async (
  chat_id: string,
  chat_message_id: string
): Promise<Error | null> => {
  try {
    if (!chat_id || !chat_message_id) return null;

    const getConn = await databasePool.getConnection();

    await getConn.beginTransaction();

    await databasePool.query(
      `delete from chat_messages where chat_id = uuid_to_bin(?) and chat_message_id = uuid_to_bin(?)`,
      [chat_id, chat_message_id]
    );

    await getConn.commit();

    return null;
  } catch (e) {
    if (e instanceof Error) return e;
    return Error("Something went wrong");
  }
};

export const editChatMessage = async (
  chat_id: string,
  chat_message_id: string,
  message: string
) => {
  if (!chat_id || !chat_message_id) return;

  await databasePool.query(
    `update chat_messages set message = ? where chat_id = uuid_to_bin(?) and chat_message_id = uuid_to_bin(?)`,
    [message, chat_id, chat_message_id]
  );
};

export const markMessageAsSeen = async (
  chat_message_id: string,
  user: number,
  chat_id: string
): Promise<void> => {
  if (!chat_message_id) return;
  try {
    await databasePool.execute(
      `INSERT IGNORE INTO chat_message_reads (chat_message_id, user_id, chat_id)
       VALUES (UUID_TO_BIN(?), ?, UUID_TO_BIN(?));`,
      [chat_message_id, user, chat_id]
    );
  } catch (error) {
    console.error("Mesaj görüldü olarak işaretlenirken hata:", error);
    throw error;
  }
};

export const getMessageSeemed = async (
  chat_message_id: string,
  user: number,
  chat_id: string
) => {
  if (!chat_message_id) return;
  return (
    (
      await databasePool.query(
        `
        select id, bin_to_uuid(chat_message_id) chat_message_id, user_id, bin_to_uuid(chat_id) chat_id from chat_message_reads where chat_message_id = uuid_to_bin(?) and user_id = ? and chat_id = uuid_to_bin(?)
        `,
        [chat_message_id, user, chat_id]
      )
    )[0] as IChatSeemed[]
  )[0];
};

export const getSeemedMessages = async (chat_id: string) => {
  return (
    await databasePool.query(
      `
        select chat_message_reads.user_id, users.username, users.photo, seemed_at, bin_to_uuid(chat_message_reads.chat_message_id) chat_message_id from chat_message_reads
 join chat_messages on chat_messages.chat_message_id = chat_message_reads.chat_message_id
 join users on chat_message_reads.user_id = users.user_id
 where chat_message_reads.chat_id = uuid_to_bin(?)`,
      [chat_id]
    )
  )[0];
};

export const checkOneSeemedMessage = async (
  chat_id: string,
  chat_message_id: string
) => {
  return (
    await databasePool.query(
      `
        select chat_message_reads.user_id, users.username, users.photo, seemed_at, bin_to_uuid(chat_message_reads.chat_message_id) chat_message_id from chat_message_reads
 join chat_messages on chat_messages.chat_message_id = chat_message_reads.chat_message_id
 join users on chat_message_reads.user_id = users.user_id
 where chat_message_reads.chat_id = uuid_to_bin(?) and chat_message_reads.chat_message_id = uuid_to_bin(?)`,
      [chat_id, chat_message_id]
    )
  )[0] as IChatMessage[];
};

export const getSeemedMessagesForUser = async (
  chat_id: string,
  user_id: number
) => {
  return (
    await databasePool.query(
      `
        SELECT 
          bin_to_uuid(chat_message_reads.chat_message_id) AS chat_message_id,
          chat_message_reads.user_id,
          users.username,
          users.photo,
          chat_message_reads.seemed_at
        FROM chat_message_reads
        JOIN chat_messages ON chat_messages.chat_message_id = chat_message_reads.chat_message_id
        JOIN users ON chat_message_reads.user_id = users.user_id
        WHERE chat_message_reads.chat_id = uuid_to_bin(?)
        AND chat_messages.user_id != ?
    `,
      [chat_id, user_id]
    )
  )[0];
};
