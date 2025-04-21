const express = require("express");
const router = express.Router();
const verifyToken = require("../middlewares/virifyToken");
const allowedTo = require("../middlewares/allowedTo");
const userRoles = require("../utils/userRoles");
// const validationschema = require("../middleware/validationschema");
const growthController = require("../controllers/growth.controller");

// Routes for creating and getting all growth records
router
  .route("/:childId")
  .post(
    verifyToken,
    allowedTo(userRoles.ADMIN, userRoles.DOCTOR, userRoles.PATIENT),
    // validationschema.validateGrowth,
    growthController.createGrowth
  )
  .get(
    verifyToken,
    allowedTo(userRoles.ADMIN, userRoles.DOCTOR, userRoles.PATIENT),
    growthController.getAllGrowth
  );

// Fixed routes for last record and last change (must come before :growthId)
router
  .route("/:childId/last")
  .get(
    verifyToken,
    allowedTo(userRoles.ADMIN, userRoles.DOCTOR, userRoles.PATIENT),
    growthController.getLastGrowthRecord
  );

router
  .route("/:childId/last-change")
  .get(
    verifyToken,
    allowedTo(userRoles.ADMIN, userRoles.DOCTOR, userRoles.PATIENT),
    growthController.getLastGrowthChange
  );

// Dynamic routes for specific growth record
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
    // validationschema.validateGrowth,
    growthController.updateGrowth
  )
  .delete(
    verifyToken,
    allowedTo(userRoles.ADMIN, userRoles.DOCTOR, userRoles.PATIENT),
    growthController.deleteGrowth
  );

module.exports = router;
