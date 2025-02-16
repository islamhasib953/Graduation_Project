const express = require("express");
const router = express.Router();
const vaccinationController = require("../controllers/vaccination.controller");
const verifyToken = require("../middlewares/virifyToken");
const allowedTo = require("../middlewares/allowedTo");
const userRoles = require("../utils/userRoles");

router
  .route("/")
  .get(
    verifyToken,
    allowedTo(userRoles.ADMIN),
    vaccinationController.getAllVaccinations
  )
  .post(
    verifyToken,
    allowedTo(userRoles.ADMIN),
    vaccinationController.createVaccinationForAllChildren
  );
  
  // Admin deletes a vaccination for all children
  router.route('/:vaccinationId')
  .delete(
    verifyToken,
    allowedTo(userRoles.ADMIN),
    vaccinationController.deleteVaccinationForAllChildren
  );

router
  .route("/:childId")
  .get(
    verifyToken,
    allowedTo(userRoles.ADMIN, userRoles.DOCTOR, userRoles.PATIENT),
    vaccinationController.getVaccinationsByChildId
  );

router
  .route("/:childId/:vaccinationId")
  .get(
    verifyToken,
    allowedTo(userRoles.ADMIN, userRoles.DOCTOR, userRoles.PATIENT),
    vaccinationController.getUserVaccination
  )
  .patch(
    verifyToken,
    allowedTo(userRoles.ADMIN, userRoles.DOCTOR, userRoles.PATIENT),
    vaccinationController.updateUserVaccination
  )
  .delete(
    verifyToken,
    allowedTo(userRoles.ADMIN, userRoles.DOCTOR, userRoles.PATIENT),
    vaccinationController.deleteUserVaccination
  );

module.exports = router;
