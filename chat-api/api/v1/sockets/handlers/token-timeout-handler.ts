import { Socket } from "socket.io"
import IResponse from "../../model/interface/iresponse"

const tokenTimeoutHandler = (socket : Socket) => {
    try{
        const exp = socket.data.exp;
        console.log(exp);

        if (typeof exp !== "number" || exp <= 0) {
            throw new Error("Invalid or expired token");
        }

        setTimeout(() => {
            socket.emit("notification_channel", { message: "Auth expired", status: 498 } as IResponse);
            socket.disconnect();
        }, exp);
    }catch(e){
        socket.emit("notification_channel", { message : "Auth already expired", status : 498 } as IResponse)
        socket.disconnect()
    }
}

export default tokenTimeoutHandler