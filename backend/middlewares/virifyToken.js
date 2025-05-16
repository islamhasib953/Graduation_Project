const jwt = require("jsonwebtoken");
const httpStatusText = require("../utils/httpStatusText");
const appError = require("../utils/appError");
const User = require("../models/user.model");
const Doctor = require("../models/doctor.model"); // استيراد الـ Doctor Model

const verifyToken = async (req, res, next) => {
  try {
    const authHeader = req.headers.authorization || req.headers.Authorization;

    if (!authHeader || !authHeader.startsWith("Bearer ")) {
      return next(
        appError.create("Token is required", 401, httpStatusText.ERROR)
      );
    }

    const token = authHeader.split(" ")[1];
    if (!token) {
      return next(
        appError.create("Invalid token format", 401, httpStatusText.ERROR)
      );
    }

    const decoded = jwt.verify(token, process.env.TOKEN_SECRET_KEY);

    let user;
    // بناءً على الـ role في الـ Token، هنحدد الموديل اللي هنستخدمه
    if (decoded.role === "doctor") {
      user = await Doctor.findById(decoded.id).select("-password");
    } else {
      user = await User.findById(decoded.id).select("-password");
    }

    if (!user) {
      return next(
        appError.create(
          decoded.role === "doctor" ? "Doctor not found" : "User not found",
          404,
          httpStatusText.FAIL
        )
      );
    }

    req.user = user;

    next();
  } catch (error) {
    return next(appError.create(error.message, 401, httpStatusText.ERROR));
  }
};

module.exports = verifyToken;
