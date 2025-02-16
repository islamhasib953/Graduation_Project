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

// app.use(session({
//   secret: "secret",  //process.env.SESSION_SECRET,
//   resave: false,
//   saveUninitialized: true,
//   // cookie: { secure: process.env.NODE_ENV === 'production' }
// }))

// app.use(passport.initialize);
// app.use(passport.session());

// passport.serializeUser(function(user, done) {
//   done(null, user);
// });

// passport.deserializeUser(function(user, done) {
//   done(null, user);
// });

// passport.use(new GoogleStrategy({
//   clientID: process.env.GOOGLE_CLIENT_ID,
//   clientSecret: process.env.GOOGLE_CLIENT_SECRET,
//   callbackURL: process.env.GOOGLE_CALLBACK_URL,
//   scope: ['profile', 'email']
//   },
//   async (accessToken, refreshToken, profile, done) => {
//     try {
//       const user = await User.findOne({ googleId: profile.id });
//       if (user) {
//         return done(null, user);
//       } else {
//         const newUser = await User.create({
//           googleId: profile.id,
//           name: profile.displayName,
//           email: profile.emails[0].value
//         });
//         return done(null, newUser);
//       }
//     } catch (error) {
//       done(error);
//     }
//   }

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

// routes
// app.use("/api/auth", authRoutes);
app.use("/api/users", usersRoutes);
app.use("/api/medicines", medicineRoutes);
app.use("/api/children", childRoutes);
app.use("/api/history", historyRoutes);
app.use("/api/memory", memoryRoutes);
app.use("/api/vaccinations", vaccinationRoutes);

//global midderware for not found routes
app.all("*", (req, res) => {
  return res
    .status(404)
    .json({
      status: httpStatusText.ERROR,
      data: { message: "this resource not found" },
    });
});

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

//,  ارفع السيرفرو ايميلات فايربيز
