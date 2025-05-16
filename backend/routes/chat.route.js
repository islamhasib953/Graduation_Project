const express = require("express");
const router = express.Router();
const verifyToken = require("../middlewares/virifyToken");
const allowedTo = require("../middlewares/allowedTo");
const userRoles = require("../utils/userRoles");
const chatController = require("../controllers/chat.controller");
const upload = require("../utils/multer.config");
const mongoose = require("mongoose"); // استيراد mongoose

// التحقق من صحة المعرفات
const validateIds = (req, res, next) => {
  const { childId, doctorId } = req.params;
  if (
    !mongoose.Types.ObjectId.isValid(childId) ||
    !mongoose.Types.ObjectId.isValid(doctorId)
  ) {
    return res.status(400).json({
      status: "fail",
      message: "Invalid childId or doctorId",
    });
  }
  next();
};

router.get(
  "/:childId/:doctorId/eligibility",
  verifyToken,
  allowedTo(userRoles.PATIENT),
  validateIds,
  chatController.checkChatEligibility
);

router.get(
  "/:childId/:doctorId/history",
  verifyToken,
  allowedTo(userRoles.PATIENT, userRoles.DOCTOR),
  validateIds,
  chatController.getChatHistory
);

router.post(
  "/:childId/:doctorId/upload",
  verifyToken,
  allowedTo(userRoles.PATIENT),
  validateIds,
  (req, res, next) => {
    req.modelName = "chat";
    next();
  },
  upload.single("media"),
  chatController.uploadMedia
);

module.exports = router;
//latest