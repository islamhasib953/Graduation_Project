const express = require("express");
const router = express.Router();
const verifyToken = require("../middlewares/virifyToken");
const allowedTo = require("../middlewares/allowedTo");
const userRoles = require("../utils/userRoles");
const chatController = require("../controllers/chat.controller");
const upload = require("../utils/multer.config"); // استيراد Multer المركزي

router.get(
  "/:childId/:doctorId/eligibility",
  verifyToken,
  allowedTo(userRoles.PATIENT),
  chatController.checkChatEligibility
);

router.get(
  "/:childId/:doctorId/history",
  verifyToken,
  allowedTo(userRoles.PATIENT, userRoles.DOCTOR),
  chatController.getChatHistory
);

router.post(
  "/:childId/:doctorId/upload",
  verifyToken,
  allowedTo(userRoles.PATIENT),
  (req, res, next) => {
    req.modelName = "chat"; // إضافة اسم الموديل ليظهر في اسم الملف
    next();
  },
  upload.single("media"),
  chatController.uploadMedia // نقل المنطق إلى الكنترولر
);

module.exports = router;
