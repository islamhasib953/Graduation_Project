const { Server } = require("socket.io");

class WebSocketService {
  constructor(server) {
    this.io = new Server(server, {
      cors: {
        origin: "*",
        methods: ["GET", "POST"],
      },
    });

    this.initializeSocket();
  }

  initializeSocket() {
    this.io.on("connection", (socket) => {
      console.log("A client connected:", socket.id);

      socket.on("joinChat", ({ childId, doctorId }) => {
        const room = `${childId}-${doctorId}`;
        socket.join(room);
        console.log(`Client ${socket.id} joined room: ${room}`);
      });

      socket.on(
        "sendMessage",
        async ({ childId, doctorId, sender, content, media }) => {
          const room = `${childId}-${doctorId}`;
          const Chat = require("../models/chat.model");

          try {
            let chat = await Chat.findOne({ childId, doctorId });
            if (!chat) {
              chat = new Chat({
                childId,
                doctorId,
                messages: [],
              });
            }

            const message = {
              sender,
              content,
              media,
              timestamp: new Date(),
            };

            chat.messages.push(message);
            await chat.save();

            this.io.to(room).emit("receiveMessage", message);
          } catch (error) {
            console.error("Error saving message:", error);
          }
        }
      );

      socket.on("disconnect", () => {
        console.log("A client disconnected:", socket.id);
      });
    });
  }

  getIO() {
    return this.io;
  }
}

module.exports = WebSocketService;
