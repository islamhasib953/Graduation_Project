const userRoles = require('../utils/userRoles');

function checkOwnership(req, res, next) {
  if (!req.user) {
    return next(appError.create("User not authenticated", 401));
  }

  const currentUser = req.user; // ✅ Retrieved from `verifyToken`
  const userId = req.params.userId || req.user.id; // ✅ استخدم `req.user.id` عند عدم وجود `userId` في `req.params`

  if (
    currentUser.role === userRoles.ADMIN ||
    currentUser._id.toString() === userId
  ) {
    return next(); // ✅ السماح للمسؤول أو صاحب الحساب بالمتابعة
  }

  return next(
    appError.create("You are not allowed to modify this account", 403)
  );
}

module.exports = checkOwnership;
