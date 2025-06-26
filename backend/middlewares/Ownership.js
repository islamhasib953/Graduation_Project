const userRoles = require("../utils/userRoles");

function checkOwnership(req, res, next) {
  if (!req.user) {
    return next(appError.create("User not authenticated", 401));
  }

  const currentUser = req.user;
  const userId = req.params.userId || req.user.id;

  if (
    currentUser.role === userRoles.ADMIN ||
    currentUser._id.toString() === userId
  ) {
    return next();
  }

  return next(
    appError.create("You are not allowed to modify this account", 403)
  );
}

module.exports = checkOwnership;
