import databasePool from "../../../../service/database";
import IGroupChat from "../../model/interface/igroup-chat";
import IUser from "../../model/interface/iuser";

export const findUser = async (user_id: string) => {
  return (
    await databasePool.query(
      "select user_id, username, photo from users where user_id = ? and is_active = 'ACTIVE' ",
      [user_id]
    )
  )[0] as IUser[];
};

