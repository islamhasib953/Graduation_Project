const express = require("express");
const { validationResult } = require("express-validator");
const router = express.Router();

const medicineController = require("../controllers/medicine.controller");
const validationschema = require("../middlewares/validationschema");
const verifyToken = require("../middlewares/virifyToken");
const allowedTo = require("../middlewares/allowedTo");
const userRoles = require("../utils/userRoles");


router
  .route("/:childId")
  .get(verifyToken, allowedTo(userRoles.ADMIN, userRoles.DOCTOR, userRoles.PATIENT), medicineController.getAllMedicines)
  .post(
    verifyToken,
    allowedTo(userRoles.ADMIN, userRoles.DOCTOR, userRoles.PATIENT),
    validationschema.validateMedicine,
    medicineController.createMedicine
  );

router
  .route("/:childId/:medicineId")
  .get(verifyToken, allowedTo(userRoles.ADMIN, userRoles.DOCTOR, userRoles.PATIENT), medicineController.getSingleMedicine)
  .patch(
    verifyToken,
    allowedTo(userRoles.ADMIN, userRoles.DOCTOR, userRoles.PATIENT),
    validationschema.validateMedicine,
    medicineController.updateMedicine
  )
  .delete(verifyToken, allowedTo(userRoles.ADMIN, userRoles.DOCTOR, userRoles.PATIENT), medicineController.deleteMedicine);

module.exports = router;
