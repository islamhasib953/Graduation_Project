// const express = require("express");
// const http = require("http");
// const { Server } = require("socket.io");
// const bodyParser = require("body-parser");
// const cookieParser = require("cookie-parser");
// const dotenv = require("dotenv");
// const cors = require("cors");
// const morgan = require("morgan");
// const limitReq = require("express-rate-limit");
// const mongoSanitize = require("express-mongo-sanitize");
// const xssClean = require("xss-clean");
// const hpp = require("hpp");

// const appError = require("./utils/appError");
// const httpStatusText = require("./utils/httpStatusText");
// const MQTTService = require("./services/mqtt.service");
// const connectDB = require("./config/db.config");
// const scheduleNotifications = require("./utils/scheduleNotifications");

// // استيراد الـ Routes
// const medicineRoutes = require("./routes/medicine.route");
// const usersRoutes = require("./routes/users.route");
// const childRoutes = require("./routes/child.route");
// const historyRoutes = require("./routes/history.route");
// const memoryRoutes = require("./routes/memory.route");
// const vaccinationRoutes = require("./routes/vaccination.route");
// const growthRoutes = require("./routes/growth.route");
// const doctorRoutes = require("./routes/doctor.route");
// const sensorDataRoutes = require("./routes/sensorData.route");
// const predictionRoutes = require("./routes/predict.route");
// const notificationsRoutes = require("./routes/notifications.routes");

// // إعدادات أساسية
// dotenv.config({ path: "./.env" });
// const app = express();
// const server = http.createServer(app);
// const io = new Server(server, {
//   cors: {
//     origin: "*",
//     methods: ["GET", "POST"],
//   },
// });

// // إعدادات Express
// app.use("/uploads", express.static("uploads"));
// app.use(express.json());
// app.use(bodyParser.json());
// app.use(cookieParser());

// // Middlewares
// app.use(cors());
// app.use(mongoSanitize());
// app.use(xssClean());
// app.use(hpp());

// const limiter = limitReq({
//   max: 200,
//   windowMs: 1000 * 60 * 60,
//   message: "Too many requests, try again after one hour",
// });
// app.use(limiter);

// app.use(morgan("combined"));

// app.use(async (req, res, next) => {
//   res.locals.messages = require("express-messages")(req, res);
//   next();
// });

// // إعداد MongoDB
// connectDB();

// // إعداد MQTT
// const mqttService = new MQTTService(io);
// mqttService.connect();

// // إعداد الإشعارات المجدولة
// scheduleNotifications();

// // الـ Routes
// app.use("/api/users", usersRoutes);
// app.use("/api/medicines", medicineRoutes);
// app.use("/api/children", childRoutes);
// app.use("/api/history", historyRoutes);
// app.use("/api/memory", memoryRoutes);
// app.use("/api/vaccinations", vaccinationRoutes);
// app.use("/api/growth", growthRoutes);
// app.use("/api/doctors", doctorRoutes);
// app.use("/api/sensor-data", sensorDataRoutes);
// app.use("/api/predictions", predictionRoutes);
// app.use("/api/notifications", notificationsRoutes);

// app.all("*", (req, res) => {
//   return res.status(404).json({
//     status: httpStatusText.ERROR,
//     data: { message: "This resource not found" },
//   });
// });

// app.use((error, req, res, next) => {
//   res.status(error.statusCode || 500).json({
//     status: error.statusText || httpStatusText.ERROR,
//     message: error.message,
//     code: error.statusCode || 500,
//     data: null,
//   });
// });

// module.exports = { app, server };


const express = require("express");
const http = require("http");
const { Server } = require("socket.io");
const bodyParser = require("body-parser");
const cookieParser = require("cookie-parser");
const dotenv = require("dotenv");
const cors = require("cors");
const morgan = require("morgan");
const limitReq = require("express-rate-limit");
const mongoSanitize = require("express-mongo-sanitize");
const xssClean = require("xss-clean");
const hpp = require("hpp");

const appError = require("./utils/appError");
const httpStatusText = require("./utils/httpStatusText");
const MQTTService = require("./services/mqtt.service");
const connectDB = require("./config/db.config");
const scheduleNotifications = require("./utils/scheduleNotifications");

// استيراد الـ Routes
const medicineRoutes = require("./routes/medicine.route");
const usersRoutes = require("./routes/users.route");
const childRoutes = require("./routes/child.route");
const historyRoutes = require("./routes/history.route");
const memoryRoutes = require("./routes/memory.route");
const vaccinationRoutes = require("./routes/vaccination.route");
const growthRoutes = require("./routes/growth.route");
const doctorRoutes = require("./routes/doctor.route");
const sensorDataRoutes = require("./routes/sensorData.route");
const predictionRoutes = require("./routes/predict.route");
const notificationsRoutes = require("./routes/notifications.routes");

// إعدادات أساسية
dotenv.config({ path: "./.env" });
const app = express();
const server = http.createServer(app);
const io = new Server(server, {
  cors: {
    origin: "*",
    methods: ["GET", "POST"],
  },
});

// إعدادات Express
app.use("/uploads", express.static("uploads"));
app.use(express.json());
app.use(bodyParser.json());
app.use(cookieParser());

// Middlewares
app.use(cors());
app.use(mongoSanitize());
app.use(xssClean());
app.use(hpp());

const limiter = limitReq({
  max: 200,
  windowMs: 1000 * 60 * 60,
  message: "Too many requests, try again after one hour",
});
app.use(limiter);

app.use(morgan("combined"));

app.use(async (req, res, next) => {
  res.locals.messages = require("express-messages")(req, res);
  next();
});

// إعداد MongoDB
connectDB();

// إعداد MQTT
const mqttService = new MQTTService(io);
mqttService.connect();

// إعداد الإشعارات المجدولة
scheduleNotifications.scheduleNotifications();

// الـ Routes
app.use("/api/users", usersRoutes);
app.use("/api/medicines", medicineRoutes);
app.use("/api/children", childRoutes);
app.use("/api/history", historyRoutes);
app.use("/api/memory", memoryRoutes);
app.use("/api/vaccinations", vaccinationRoutes);
app.use("/api/growth", growthRoutes);
app.use("/api/doctors", doctorRoutes);
app.use("/api/sensor-data", sensorDataRoutes);
app.use("/api/predictions", predictionRoutes);
app.use("/api/notifications", notificationsRoutes);

app.all("*", (req, res) => {
  return res.status(404).json({
    status: httpStatusText.ERROR,
    data: { message: "This resource not found" },
  });
});

app.use((error, req, res, next) => {
  res.status(error.statusCode || 500).json({
    status: error.statusText || httpStatusText.ERROR,
    message: error.message,
    code: error.statusCode || 500,
    data: null,
  });
});

module.exports = { app, server };