const express = require("express");
const { refreshToken } = require("../controllers/auth.controller");

const router = express.Router();

// ✅ مسار تجديد التوكن
router.post("/refresh-token", refreshToken);

module.exports = router;
