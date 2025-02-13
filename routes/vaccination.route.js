const express = require("express");
const router = express.Router();
const vaccinationController = require("../controllers/vaccination.controller");
const verifyToken = require("../middlewares/virifyToken");
const checkOwnership = require("../middlewares/Ownership");
const allowedTo = require("../middlewares/allowedTo");
const userRoles = require("../utils/userRoles");

/**
 * Routes for managing vaccinations
 */

// ✅ Route to get all vaccinations and create a new vaccination (Admin only)
router
  .route("/")
  .get(verifyToken, checkOwnership, vaccinationController.getAllVaccinations)
  .post(
    verifyToken,
    allowedTo(userRoles.ADMIN),
    vaccinationController.createVaccinationForAllChildren
  );

router
  .route("/:childId")
  .get(
    verifyToken,
    checkOwnership, vaccinationController.getVaccinationsByChildId
  );

// ✅ Routes for handling a single vaccination by ID
// router
//   .route("/:vaccinationId")
//   .get(verifyToken, checkOwnership, vaccinationController.getSingleVaccination)
//   .patch(verifyToken, checkOwnership, vaccinationController.updateVaccination)
//   .delete(verifyToken, checkOwnership, vaccinationController.deleteVaccination);

module.exports = router;
