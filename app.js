const express = require("express");
const bodyParser = require("body-parser");
const cookieParser = require("cookie-parser");
const appError = require("./utils/appError");
const httpStatusText = require("./utils/httpStatusText");
// const errorHandler = require('./Errors/errorHandling')
const dotenv = require("dotenv");
const limitReq = require("express-rate-limit");
const mongoSanitize = require("express-mongo-sanitize");
const xssClean = require("xss-clean");
const hpp = require("hpp");
const cors = require("cors");
const http = require("http");
// const testRoutes = require("./routes/watchhttp");
const morgan = require("morgan");


//************* */
// const { Server } = require("socket.io");
// const mqttClient = require("./mqtt/mqtt");
// const watchRoutes = require("./routes/watchRoutes");
//*********************** */


const passport = require("passport");
const session = require("express-session");
const GoogleStrategy = require("passport-google-oauth20").Strategy;

const medicineRoutes = require("./routes/medicine.route");
const usersRoutes = require("./routes/users.route");
const childRoutes = require("./routes/child.route");
const historyRoutes = require("./routes/history.route");
const memoryRoutes = require("./routes/memory.route");
const vaccinationRoutes = require("./routes/vaccination.route");
// const authRoutes = require("./routes/auth.route");

dotenv.config({ path: "./.env" });
const app = express();


app.use("/uploads", express.static("uploads"));

app.use(express.json());
app.use(bodyParser.json());

app.use(cors());

app.use(mongoSanitize());
app.use(xssClean());
app.use(hpp());
app.use(cookieParser());

app.use(async (req, res, next) => {
  res.locals.messages = require("express-messages")(req, res);
  next();
});

const limiter = limitReq({
  max: 200,
  windowMs: 1000 * 60 * 60,
  message: "Too many requests, try again after one hour",
});


app.use(morgan("combined"));

// routes
// app.use("/api/auth", authRoutes);
app.use("/api/users", usersRoutes);
app.use("/api/medicines", medicineRoutes);
app.use("/api/children", childRoutes);
app.use("/api/history", historyRoutes);
app.use("/api/memory", memoryRoutes);
app.use("/api/vaccinations", vaccinationRoutes);

// app.use("/api/testing", testRoutes);

//global midderware for not found routes
app.all("*", (req, res) => {
  return res
    .status(404)
    .json({
      status: httpStatusText.ERROR,
      data: { message: "this resource not found" },
    });
});


// test
// const server = http.createServer(app);
// const io = new Server(server, {
//   cors: { origin: "*" },
// });

// global.io = io;
// app.use("/api", watchRoutes);

//********************** */


//global error handler
app.use((error, req, res, next) => {
  res
    .status(error.statusCode || 500)
    .json({
      status: error.statusText || httpStatusText.ERROR,
      message: error.message,
      code: error.statusCode || 500,
      data: null,
    });
});

module.exports = app;

