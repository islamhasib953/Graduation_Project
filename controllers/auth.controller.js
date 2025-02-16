const jwt = require("jsonwebtoken");
const User = require("../models/user.model");
const httpStatusText = require("../utils/httpStatusText");
const appError = require("../utils/appError");
const asyncWrapper = require("../middlewares/asyncWrapper");
const generateJWT = require("../utils/generateJWT");

// ✅ تجديد التوكن
const refreshToken = asyncWrapper(async (req, res, next) => {
  const { refreshToken } = req.body;

  if (!refreshToken) {
    return next(
      appError.create("Refresh Token is required", 401, httpStatusText.FAIL)
    );
  }

  try {
    // فك تشفير التوكن
    const decoded = jwt.verify(refreshToken, process.env.REFRESH_TOKEN_SECRET);

    // البحث عن المستخدم باستخدام ID من التوكن
    const user = await User.findById(decoded.id);
    if (!user || user.refreshToken !== refreshToken) {
      return next(
        appError.create("Invalid Refresh Token", 403, httpStatusText.FAIL)
      );
    }

    // ✅ إنشاء Access Token جديد
    const newAccessToken = await generateJWT(
      { id: user._id, email: user.email, role: user.role },
      "10m"
    );

    res
      .status(200)
      .json({
        status: httpStatusText.SUCCESS,
        data: { accessToken: newAccessToken },
      });
  } catch (error) {
    return next(
      appError.create(
        "Invalid or Expired Refresh Token",
        403,
        httpStatusText.FAIL
      )
    );
  }
});

module.exports = { refreshToken };
