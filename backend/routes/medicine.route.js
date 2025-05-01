// const express = require("express");
// const { validationResult } = require("express-validator");
// const router = express.Router();

// const medicineController = require("../controllers/medicine.controller");
// const validationschema = require("../middlewares/validationschema");
// const verifyToken = require("../middlewares/virifyToken");
// const allowedTo = require("../middlewares/allowedTo");
// const userRoles = require("../utils/userRoles");


// router
//   .route("/:childId")
//   .get(verifyToken, allowedTo(userRoles.ADMIN, userRoles.DOCTOR, userRoles.PATIENT), medicineController.getAllMedicines)
//   .post(
//     verifyToken,
//     allowedTo(userRoles.ADMIN, userRoles.DOCTOR, userRoles.PATIENT),
//     validationschema.validateMedicine,
//     medicineController.createMedicine
//   );

// router
//   .route("/:childId/:medicineId")
//   .get(verifyToken, allowedTo(userRoles.ADMIN, userRoles.DOCTOR, userRoles.PATIENT), medicineController.getSingleMedicine)
//   .patch(
//     verifyToken,
//     allowedTo(userRoles.ADMIN, userRoles.DOCTOR, userRoles.PATIENT),
//     validationschema.validateMedicine,
//     medicineController.updateMedicine
//   )
//   .delete(verifyToken, allowedTo(userRoles.ADMIN, userRoles.DOCTOR, userRoles.PATIENT), medicineController.deleteMedicine);

// module.exports = router;


const express = require("express");
const { validationResult } = require("express-validator");
const router = express.Router();
const appError = require("../utils/appError");
const medicineController = require("../controllers/medicine.controller");
const validationschema = require("../middlewares/validationschema");
const verifyToken = require("../middlewares/virifyToken");
const allowedTo = require("../middlewares/allowedTo");
const userRoles = require("../utils/userRoles");
const { sendNotification } = require("../controllers/notifications.controller");

router
  .route("/:childId")
  .get(
    verifyToken,
    allowedTo(userRoles.ADMIN, userRoles.DOCTOR, userRoles.PATIENT),
    medicineController.getAllMedicines
  )
  .post(
    verifyToken,
    allowedTo(userRoles.ADMIN, userRoles.DOCTOR, userRoles.PATIENT),
    validationschema.validateMedicine,
    async (req, res, next) => {
      try {
        const { childId } = req.params;
        const userId = req.user.id;

        // استدعاء دالة createMedicine
        const result = await medicineController.createMedicine(req, res, next);

        // التأكد إن العملية نجحت وإن الـ response تم إرساله
        if (res.headersSent) {
          const medicine = result.data; // افتراض إن createMedicine بترجع data في الـ response
          if (medicine) {
            console.log(
              `Sending notification for new medicine: ${medicine.name}`
            );
            await sendNotification(
              userId,
              childId,
              null,
              "New Medicine Added",
              `A new medicine "${medicine.name}" has been added for your child.`,
              "medicine",
              "user"
            );
          }
        }
      } catch (error) {
        console.error(`Error creating medicine for child ${childId}:`, error);
        return next(appError.create("Failed to create medicine", 500, "error"));
      }
    }
  );

router
  .route("/:childId/:medicineId")
  .get(
    verifyToken,
    allowedTo(userRoles.ADMIN, userRoles.DOCTOR, userRoles.PATIENT),
    medicineController.getSingleMedicine
  )
  .patch(
    verifyToken,
    allowedTo(userRoles.ADMIN, userRoles.DOCTOR, userRoles.PATIENT),
    validationschema.validateMedicine,
    async (req, res, next) => {
      try {
        const { childId, medicineId } = req.params;
        const userId = req.user.id;

        // استدعاء دالة updateMedicine
        const result = await medicineController.updateMedicine(req, res, next);

        // التأكد إن العملية نجحت وإن الـ response تم إرساله
        if (res.headersSent) {
          const medicine = result.data; // افتراض إن updateMedicine بترجع data في الـ response
          if (medicine) {
            console.log(
              `Sending notification for updated medicine: ${medicine.name}`
            );
            await sendNotification(
              userId,
              childId,
              null,
              "Medicine Updated",
              `The medicine "${medicine.name}" has been updated for your child.`,
              "medicine",
              "user"
            );
          }
        }
      } catch (error) {
        console.error(
          `Error updating medicine ${medicineId} for child ${childId}:`,
          error
        );
        return next(appError.create("Failed to update medicine", 500, "error"));
      }
    }
  )
  .delete(
    verifyToken,
    allowedTo(userRoles.ADMIN, userRoles.DOCTOR, userRoles.PATIENT),
    async (req, res, next) => {
      try {
        const { childId, medicineId } = req.params;
        const userId = req.user.id;

        // استدعاء دالة deleteMedicine
        const result = await medicineController.deleteMedicine(req, res, next);

        // التأكد إن العملية نجحت وإن الـ response تم إرساله
        if (res.headersSent) {
          console.log(
            `Sending notification for deleted medicine: ${medicineId}`
          );
          await sendNotification(
            userId,
            childId,
            null,
            "Medicine Deleted",
            `The medicine has been deleted for your child.`,
            "medicine",
            "user"
          );
        }
      } catch (error) {
        console.error(
          `Error deleting medicine ${medicineId} for child ${childId}:`,
          error
        );
        return next(appError.create("Failed to delete medicine", 500, "error"));
      }
    }
  );

module.exports = router;