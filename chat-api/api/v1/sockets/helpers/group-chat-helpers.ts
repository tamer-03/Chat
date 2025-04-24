import databasePool from "../../../../service/database";
import IGroupChat from "../../model/interface/igroup-chat";
import IUser from "../../model/interface/iuser";
import IuuidResult from "../../model/interface/iuuid-result";

export const createGroupChat = async (
  groupName: string,
  user_id: string,
  members: IUser[]
) => {
  const connection = await databasePool.getConnection();
  try {
    await connection.beginTransaction();

    const uuidResult = (
      await connection.query("SELECT UUID() AS uuid")
    )[0] as IuuidResult[];
    const chatId = uuidResult[0].uuid;

    await connection.query(
      "INSERT INTO chat_table(chat_id,chat_type) VALUES(UUID_TO_BIN(?),'GROUP')",
      [chatId]
    );

    await connection.query(
      `INSERT INTO chat_group (group_id, chat_id, group_name, creator_user_id, created_at)
       VALUES (UUID_TO_BIN(UUID()), UUID_TO_BIN(?), ?, ?, NOW());`,
      [chatId, groupName, user_id]
    );

    const membersId = members.map((e) => e.user_id);
    membersId.push(user_id);

    for (const memberId of membersId) {
      await connection.query(
        "INSERT INTO chat_members (chat_id, user_id) VALUES (UUID_TO_BIN(?), ?)",
        [chatId, memberId]
      );
    }
  } catch (e) {
    await connection.rollback()
    if (e instanceof Error) {
      return e;
    }
    return Error("Something went wrong");
  
  } finally {
    connection.release()
  }
};

export const getGroups = async (user_id: string) => {
  const getConnection = await databasePool.getConnection();

  await getConnection.beginTransaction();

  const groupMessages = (
    await databasePool.query(
      `SELECT
  bin_to_uuid(cg.group_id) AS group_id,
  cg.group_name,
  cg.created_at,
  bin_to_uuid(ct.chat_id) AS chat_id,
  cg.photo AS photo,
  ct.chat_type,
  (
    SELECT cmes.message
    FROM chat_messages cmes
    WHERE cmes.chat_id = ct.chat_id
    ORDER BY cmes.sended_at DESC
    LIMIT 1
  ) AS message
FROM
  chat_members cm
JOIN
  chat_group cg ON cm.chat_id = cg.chat_id
JOIN
  chat_table ct ON cg.chat_id = ct.chat_id
WHERE
  cm.user_id = ?
  AND ct.chat_type = 'Group'
`,
      [user_id]
    )
  )[0] as IGroupChat[];

  await getConnection.commit();

  return groupMessages;
};

export const getLastGroupChatMessage = async (
  chat_id: string,
  user_id: string,
  beforeDate?: string,
  limit: number = 1
) => {
  try {
    const getConn = await databasePool.getConnection();
    await getConn.beginTransaction();

    const result = (
      await getConn.query(
        `SELECT
      u.user_id AS user_id,
      u.username,
      m.message,
      BIN_TO_UUID(m.chat_message_id) AS chat_message_id,
      m.sended_at,
      BIN_TO_UUID(m.chat_id) AS chat_id,
      ct.chat_type,
      cg.group_name,
      bin_to_uuid(cg.group_id) as group_id,
      CASE
          WHEN m.chat_image IS NOT NULL THEN CONCAT('/storage/', BIN_TO_UUID(m.chat_id), '/', m.chat_image)
          ELSE NULL
      END AS chat_image,
      CASE
          WHEN cg.photo IS NOT NULL THEN CONCAT('/storage/', BIN_TO_UUID(m.chat_id), '/', cg.photo)
          ELSE '/storage/defaults/default_group_image.png'
      END AS photo
  FROM
      chat_messages m
  INNER JOIN
      users u ON u.user_id = m.user_id
  INNER JOIN
      chat_table ct ON ct.chat_id = m.chat_id AND ct.chat_type = 'Group'
  INNER JOIN
      chat_group cg ON cg.chat_id = ct.chat_id
  WHERE
      BIN_TO_UUID(m.chat_id) = ?
      AND m.chat_id IN (
          SELECT chat_id FROM chat_members WHERE user_id = ?
      )
      AND (? IS NULL OR m.sended_at < ?)
  ORDER BY
      m.sended_at DESC
  LIMIT ?;
  `,
        [chat_id, user_id, beforeDate, beforeDate, limit]
      )
    )[0] as IGroupChat[];

    await getConn.commit();

    return result;
  } catch (e) {
    if (e instanceof Error) return e;
    return Error("Something went wrong");
  }
};
