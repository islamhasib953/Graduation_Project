const express = require("express");
const { validationResult } = require("express-validator");
const router = express.Router();

const memoryController = require("../controllers/memory.controller");
const validationschema = require("../middlewares/validationschema");
const verifyToken = require("../middlewares/virifyToken");
const allowedTo = require("../middlewares/allowedTo");
const userRoles = require("../utils/userRoles");
const checkOwnership = require("../middlewares/Ownership");

router
  .route("/:childId")
  .get(
    verifyToken,
    allowedTo(userRoles.ADMIN, userRoles.PATIENT),
    memoryController.getAllMemories
  )
  .post(
    verifyToken,
    allowedTo(userRoles.ADMIN, userRoles.PATIENT),
    validationschema.validateMemory,
    memoryController.createMemory
  );

router
  .route("/:childId/:memoryId")
  // .get(verifyToken, checkOwnership, memoryController.getSingleMemory)
  .patch(
    verifyToken,
    checkOwnership,
    validationschema.validateMemory,
    memoryController.updateMemory
  )
  .delete(verifyToken, checkOwnership, memoryController.deleteMemory);

router
  .route("/favorites/:childId")
  .get(verifyToken, checkOwnership, memoryController.getFavoriteMemories);

router
  .route("/favorites/:childId/:memoryId")
  .patch(verifyToken, checkOwnership, memoryController.toggleFavoriteMemory);

module.exports = router;

