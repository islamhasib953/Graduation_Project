const express = require("express");
const router = express.Router();
const memoryController = require("../controllers/memory.controller");
const { validationSchema } = require("../middlewares/validationschema");
const verifyToken = require("../middlewares/virifyToken");
const allowedTo = require("../middlewares/allowedTo");
const userRoles = require("../utils/userRoles");
const checkOwnership = require("../middlewares/Ownership");


router
  .route("/:childId")
  .get(verifyToken, checkOwnership, memoryController.getAllMemories)
  .post(
    verifyToken,
    checkOwnership,
    allowedTo(userRoles.ADMIN, userRoles.PARENT),
    memoryController.createMemory
  );

router
  .route("/:childId/:memoryId")
  .patch(verifyToken, checkOwnership, memoryController.updateMemory)
  .delete(verifyToken, checkOwnership, memoryController.deleteMemory);

router
  .route("/favorites/:childId")
  .get(verifyToken, checkOwnership, memoryController.getFavoriteMemories);

router
  .route("/:childId/:memoryId/favorite")
  .patch(verifyToken, checkOwnership, memoryController.toggleFavoriteMemory);

module.exports = router;
