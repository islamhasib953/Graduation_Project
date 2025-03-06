const express = require("express");
const router = express.Router();
const verifyToken = require("../middlewares/verifyToken");
const checkOwnership = require("../middlewares/Ownership");
const validationschema = require("../middlewares/validationschema");

const growthController = require("../controllers/growth.controller");
const allowedTo = require("../middlewares/allowedTo");
const userRoles = require("../utils/userRoles");

router
  .route("/:childId")
  .post(
    verifyToken,
    allowedTo(userRoles.ADMIN, userRoles.DOCTOR, userRoles.PATIENT),
    validationschema.validateGrowth, // Validation middleware
    growthController.createGrowth
  )
  .get(
    verifyToken,
    allowedTo(userRoles.ADMIN, userRoles.DOCTOR, userRoles.PATIENT),
    growthController.getAllGrowth
  );

router
  .route("/:childId/:growthId")
  .get(
    verifyToken,
    allowedTo(userRoles.ADMIN, userRoles.DOCTOR, userRoles.PATIENT),
    growthController.getSingleGrowth
  )
  .patch(
    verifyToken,
    allowedTo(userRoles.ADMIN, userRoles.DOCTOR, userRoles.PATIENT),
    validationschema.validateGrowth,
    growthController.updateGrowth
  )
  .delete(
    verifyToken,
    allowedTo(userRoles.ADMIN, userRoles.DOCTOR, userRoles.PATIENT),
    growthController.deleteGrowth
  );

router
  .route("/:childId/last")
  .get(verifyToken, checkOwnership, growthController.getLastGrowthRecord);

router
  .route("/:childId/last-change")
  .get(verifyToken, checkOwnership, growthController.getLastGrowthChange);

module.exports = router;
