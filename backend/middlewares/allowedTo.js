const appError = require("../utils/appError");

const allowedTo = (...roles) => {
  return (req, res, next) => {
    if (!req.user) {
      return next(appError.create("User not authenticated", 401));
    }

    if (!roles.includes(req.user.role)) {
      return next(
        appError.create("You are not authorized to access this route", 403)
      );
    }

    next();
  };
};

module.exports = allowedTo;
