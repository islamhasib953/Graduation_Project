const express = require("express");
const router = express.Router();
const vaccinationController = require("../controllers/vaccination.controller");
const verifyToken = require("../middlewares/virifyToken");
const allowedTo = require("../middlewares/allowedTo");
const userRoles = require("../utils/userRoles");
const { uploadToS3, deleteFromS3 } = require("../middlewares/s3Middleware");

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

router
  .route("/:vaccinationId")
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
    (req, res, next) => {
      req.modelName = "UserVaccination"; // إضافة اسم الموديل
      next();
    },
    deleteFromS3, // مسح الصورة القديمة
    uploadToS3, // رفع الصورة الجديدة
    vaccinationController.updateUserVaccination
  )
  .delete(
    verifyToken,
    allowedTo(userRoles.ADMIN, userRoles.DOCTOR, userRoles.PATIENT),
    vaccinationController.deleteUserVaccination
  );

module.exports = router;
