const express = require("express");
const { validationResult } = require("express-validator");
const router = express.Router();

const medicineController = require("../controllers/medicine.controller");
const validationschema = require("../middlewares/validationschema");
const verifyToken = require("../middlewares/virifyToken");
const allowedTo = require("../middlewares/allowedTo");
const userRoles = require("../utils/userRoles");
const checkOwnership = require("../middlewares/Ownership");


router
  .route("/:childId")
  .get(verifyToken, checkOwnership, medicineController.getAllMedicines)
  .post(
    verifyToken,
    checkOwnership,
    validationschema.validateMedicine,
    medicineController.createMedicine
  );

router
  .route("/:childId/:medicineId")
  .get(verifyToken, checkOwnership, medicineController.getSingleMedicine)
  .patch(
    verifyToken,
    checkOwnership,
    validationschema.validateMedicine,
    medicineController.updateMedicine
  )
  .delete(verifyToken, checkOwnership, medicineController.deleteMedicine);

module.exports = router;
