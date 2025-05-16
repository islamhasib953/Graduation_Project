const { Server } = require("socket.io");
const Appointment = require("../models/appointment.model");

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
            // التحقق من وجود موعد مقبول
            const acceptedAppointment = await Appointment.findOne({
              childId,
              doctorId,
              status: "Accepted",
            });

            if (!acceptedAppointment) {
              socket.emit("error", {
                message:
                  "You must have at least one accepted appointment with this doctor to send messages",
              });
              return;
            }

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
            socket.emit("error", { message: "Failed to send message" });
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
