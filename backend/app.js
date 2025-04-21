// 1. الـ Imports
const express = require("express");
const bodyParser = require("body-parser");
const cookieParser = require("cookie-parser");
const dotenv = require("dotenv");
const cors = require("cors");
const morgan = require("morgan");
const limitReq = require("express-rate-limit");
const mongoSanitize = require("express-mongo-sanitize");
const xssClean = require("xss-clean");
const hpp = require("hpp");
const passport = require("passport");
const session = require("express-session");
const GoogleStrategy = require("passport-google-oauth20").Strategy;

// استيراد الأدوات المساعدة
const appError = require("./utils/appError");
const httpStatusText = require("./utils/httpStatusText");

// استيراد الـ Routes
const medicineRoutes = require("./routes/medicine.route");
const usersRoutes = require("./routes/users.route");
const childRoutes = require("./routes/child.route");
const historyRoutes = require("./routes/history.route");
const memoryRoutes = require("./routes/memory.route");
const vaccinationRoutes = require("./routes/vaccination.route");
const growthRoutes = require("./routes/growth.route");
const doctorRoutes = require("./routes/doctor.route"); // أضفنا الـ doctorRoutes
const predictRoutes = require("./routes/predict.route");
// 2. إعدادات أساسية
dotenv.config({ path: "./.env" });
const app = express();

// 3. إعدادات Express
app.use("/uploads", express.static("uploads"));
app.use(express.json());
app.use(bodyParser.json());
app.use(cookieParser());

// 4. Middlewares
// أ. أدوات الأمان
app.use(cors());
app.use(mongoSanitize());
app.use(xssClean());
app.use(hpp());

// ب. Rate Limiting
const limiter = limitReq({
  max: 200,
  windowMs: 1000 * 60 * 60,
  message: "Too many requests, try again after one hour",
});
app.use(limiter);

// ج. Morgan لتسجيل الطلبات
app.use(morgan("combined"));

// د. Middleware للرسائل (Express Messages)
app.use(async (req, res, next) => {
  res.locals.messages = require("express-messages")(req, res);
  next();
});

// 5. الـ Routes
app.use("/api/users", usersRoutes);
app.use("/api/medicines", medicineRoutes);
app.use("/api/children", childRoutes);
app.use("/api/history", historyRoutes);
app.use("/api/memory", memoryRoutes);
app.use("/api/vaccinations", vaccinationRoutes);
app.use("/api/growth", growthRoutes);
app.use("/api/doctors", doctorRoutes); // أضفنا الـ doctorRoutes هنا

app.use("/api/predict", predictRoutes); // إضافة predict route

// 6. Middleware للـ Routes الغير موجودة (Not Found)
app.all("*", (req, res) => {
  return res.status(404).json({
    status: httpStatusText.ERROR,
    data: { message: "This resource not found" },
  });
});

// 7. Global Error Handler
app.use((error, req, res, next) => {
  res.status(error.statusCode || 500).json({
    status: error.statusText || httpStatusText.ERROR,
    message: error.message,
    code: error.statusCode || 500,
    data: null,
  });
});

// 8. تصدير الـ App
module.exports = app;

//ai, community, sensors
//تعديلات اللى عند عبيد
// استخدم ال api بتاع logout عند عبيد 

////////////////////
//اشوف حوار الاشعارات
//اكمل الاسكرينات فى الدكتور واليوزر
