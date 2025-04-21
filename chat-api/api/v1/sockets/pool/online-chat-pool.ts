import onlineUserPool from "./online-user-pool";

class OnlineChatPool{
    public static instance : OnlineChatPool;
    private chat : Map<string, Set<string>>;

    constructor(){
        this.chat = new Map()
    }

    public static getInstance() : OnlineChatPool{
        if(!OnlineChatPool.instance){
            OnlineChatPool.instance = new OnlineChatPool();
        }
        return OnlineChatPool.instance;
    }

    public joinRoom(userId : string, chatId : string){
        if(!this.chat.has(chatId)){
            this.chat.set(chatId, new Set())
        }

        this.chat.get(chatId)!.add(userId)
    }

    public leaveRoom(userId : string, chatId : string){
        if(!this.chat.has(chatId)){
            return
        }

        this.chat.get(chatId)!.delete(userId)

        if(this.chat.get(chatId)!.size === 0){
            this.chat.delete(chatId)
        }
    }

    public getUsersInRoom(chatId : string) : string[]{
        const users = this.chat.get(chatId)
        if(!users){
            return []
        }
        return Array.from(users)
    }

}

export default OnlineChatPool.getInstance();
