const express = require("express");
const router = express.Router();
const verifyToken = require("../middleware/verifyToken");
const allowedTo = require("../middleware/allowedTo");
const userRoles = require("../utils/userRoles");
const validationschema = require("../middleware/validationschema");
const growthController = require("../controllers/growth.controller");

router
  .route("/:childId")
  .post(
    verifyToken,
    allowedTo(userRoles.ADMIN, userRoles.DOCTOR, userRoles.PATIENT),
    validationschema.validateGrowth,
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
  .get(verifyToken, growthController.getLastGrowthRecord);

router
  .route("/:childId/last-change")
  .get(verifyToken, growthController.getLastGrowthChange);

module.exports = router;