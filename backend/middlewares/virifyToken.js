const jwt = require("jsonwebtoken");
const httpStatusText = require("../utils/httpStatusText");
const appError = require("../utils/appError");
const User = require("../models/user.model");

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

    const user = await User.findById(decoded.id).select("-password");

    if (!user) {
      return next(appError.create("User not found", 404, httpStatusText.FAIL));
    }

    req.user = user;

    next();
  } catch (error) {
    return next(appError.create(error.message, 401, httpStatusText.ERROR));
  }
};

module.exports = verifyToken;
