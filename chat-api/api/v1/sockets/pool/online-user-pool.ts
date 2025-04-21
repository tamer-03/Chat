
class OnlineUserPool {
  private static instance: OnlineUserPool;
  private onlineUsers: Map<number, string>;

  private constructor() {
    this.onlineUsers = new Map<number, string>();
  }

  public static getInstance(): OnlineUserPool {
    if (!OnlineUserPool.instance) {
      OnlineUserPool.instance = new OnlineUserPool();
    }
    return OnlineUserPool.instance;
  }

  public addUser(userId: number, socketId: string): void {
    this.onlineUsers.set(userId, socketId);
  }

  public removeUser(userId: number): void {
    this.onlineUsers.delete(userId);
  }

  public getUserSocketId(userId: number): string | undefined {
    return this.onlineUsers.get(userId);
  }

  public getAllOnlineUsers(): Map<number, string> {
    return this.onlineUsers;
  }
}

export default OnlineUserPool.getInstance();
