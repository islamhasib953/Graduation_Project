const appError = require("../utils/appError");
const userRoles = require("../utils/userRoles");

function checkOwnership(req, res, next) {
  if (!req.user) {
    return next(appError.create("User not authenticated", 401));
  }

  const { userId } = req.params;
  const currentUser = req.user; // ✅ Retrieved from `verifyToken`

  if (
    currentUser.role === userRoles.ADMIN ||
    currentUser._id.toString() === userId
  ) {
    return next(); // ✅ Allow Admin or the account owner to proceed
  }

  return next(
    appError.create("You are not allowed to modify this account", 403)
  );
}

module.exports = checkOwnership;
