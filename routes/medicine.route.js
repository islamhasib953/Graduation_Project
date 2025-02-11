const express = require("express");
const router = express.Router();
const medicineController = require("../controllers/medicine.controller");
const { validationSchema } = require("../middlewares/validationschema");
const verifyToken = require("../middlewares/virifyToken");
const allowedTo = require("../middlewares/allowedTo");
const userRoles = require("../utils/userRoles");
const checkOwnership = require("../middlewares/Ownership");


router.route("/")
      .get(verifyToken, checkOwnership, medicineController.getAllMedicines)
      .post(verifyToken, checkOwnership, // Only ADMIN and DOCTOR can add medicines
      validationSchema(), medicineController.createMedicine
);

router.route("/:medicineId")
      .patch(verifyToken, checkOwnership, medicineController.updateMedicine)
      .delete(verifyToken, checkOwnership, medicineController.deleteMedicine
);

module.exports = router;
