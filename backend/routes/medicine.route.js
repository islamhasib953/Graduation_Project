const express = require("express");
const { validationResult } = require("express-validator");
const router = express.Router();
const appError = require("../utils/appError");
const medicineController = require("../controllers/medicine.controller");
const validationschema = require("../middlewares/validationschema");
const verifyToken = require("../middlewares/virifyToken");
const allowedTo = require("../middlewares/allowedTo");
const userRoles = require("../utils/userRoles");
const {
  sendNotificationCore,
} = require("../controllers/notifications.controller");

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

        await medicineController.createMedicine(req, res, next);

        if (res.headersSent) {
          const medicine =
            res.locals.data || (res.statusCode === 201 && res._body?.data);
          if (medicine) {
            console.log(
              `Sending notification for new medicine: ${medicine.name}`
            );
            try {
              await sendNotificationCore(
                userId,
                childId,
                null,
                "New Medicine Added",
                `A new medicine "${medicine.name}" has been added for your child.`,
                "medicine",
                "patient"
              );
            } catch (error) {
              console.error(
                `Failed to send notification for new medicine: ${medicine.name}`,
                error
              );
            }
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

        await medicineController.updateMedicine(req, res, next);

        if (res.headersSent) {
          const medicine =
            res.locals.data || (res.statusCode === 200 && res._body?.data);
          if (medicine) {
            console.log(
              `Sending notification for updated medicine: ${medicine.name}`
            );
            try {
              await sendNotificationCore(
                userId,
                childId,
                null,
                "Medicine Updated",
                `The medicine "${medicine.name}" has been updated for your child.`,
                "medicine",
                "patient"
              );
            } catch (error) {
              console.error(
                `Failed to send notification for updated medicine: ${medicine.name}`,
                error
              );
            }
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

        await medicineController.deleteMedicine(req, res, next);

        if (res.headersSent) {
          console.log(
            `Sending notification for deleted medicine: ${medicineId}`
          );
          try {
            await sendNotificationCore(
              userId,
              childId,
              null,
              "Medicine Deleted",
              `The medicine has been deleted for your child.`,
              "medicine",
              "patient"
            );
          } catch (error) {
            console.error(
              `Failed to send notification for deleted medicine: ${medicineId}`,
              error
            );
          }
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
