const express = require("express");
const router = express.Router();
const sensorDataController = require("../controllers/sensorData.controller");
const verifyToken = require("../middlewares/virifyToken");
const allowedTo = require("../middlewares/allowedTo");
const userRoles = require("../utils/userRoles");

// router
//   .route("/:childId/validate")
//   .post(
//     verifyToken,
//     allowedTo(userRoles.ADMIN, userRoles.DOCTOR, userRoles.PATIENT),
//     sensorDataController.validateAndStoreSensorData
//   );

router
  .route("/:childId")
  .get(
    verifyToken,
    allowedTo(userRoles.ADMIN, userRoles.DOCTOR, userRoles.PATIENT),
    sensorDataController.getAllSensorData
  );

router
  .route("/:childId/:sensorDataId")
  .get(
    verifyToken,
    allowedTo(userRoles.ADMIN, userRoles.DOCTOR, userRoles.PATIENT),
    sensorDataController.getSingleSensorData
  );

router
  .route("/:childId/activities")
  .get(
    verifyToken,
    allowedTo(userRoles.ADMIN, userRoles.DOCTOR, userRoles.PATIENT),
    sensorDataController.getActivitiesForLastDay
  );

router
  .route("/:childId/sleep-qualities")
  .get(
    verifyToken,
    allowedTo(userRoles.ADMIN, userRoles.DOCTOR, userRoles.PATIENT),
    sensorDataController.getSleepQualitiesForLastDay
  );

module.exports = router;
