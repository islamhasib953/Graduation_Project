// const express = require("express");
// const router = express.Router();
// const vaccinationController = require("../controllers/vaccination.controller");
// const verifyToken = require("../middlewares/virifyToken");
// const allowedTo = require("../middlewares/allowedTo");
// const userRoles = require("../utils/userRoles");

// router
//   .route("/")
//   .get(
//     verifyToken,
//     allowedTo(userRoles.ADMIN),
//     vaccinationController.getAllVaccinations
//   )
//   .post(
//     verifyToken,
//     allowedTo(userRoles.ADMIN),
//     vaccinationController.createVaccinationForAllChildren
//   );
  
//   // Admin deletes a vaccination for all children
//   router.route('/:vaccinationId')
//   .delete(
//     verifyToken,
//     allowedTo(userRoles.ADMIN),
//     vaccinationController.deleteVaccinationForAllChildren
//   );

// router
//   .route("/:childId")
//   .get(
//     verifyToken,
//     allowedTo(userRoles.ADMIN, userRoles.DOCTOR, userRoles.PATIENT),
//     vaccinationController.getVaccinationsByChildId
//   );

// router
//   .route("/:childId/:vaccinationId")
//   .get(
//     verifyToken,
//     allowedTo(userRoles.ADMIN, userRoles.DOCTOR, userRoles.PATIENT),
//     vaccinationController.getUserVaccination
//   )
//   .patch(
//     verifyToken,
//     allowedTo(userRoles.ADMIN, userRoles.DOCTOR, userRoles.PATIENT),
//     vaccinationController.updateUserVaccination
//   )
//   .delete(
//     verifyToken,
//     allowedTo(userRoles.ADMIN, userRoles.DOCTOR, userRoles.PATIENT),
//     vaccinationController.deleteUserVaccination
//   );

// module.exports = router;



const express = require("express");
const router = express.Router();
const vaccinationController = require("../controllers/vaccination.controller");
const verifyToken = require("../middlewares/virifyToken");
const allowedTo = require("../middlewares/allowedTo");
const userRoles = require("../utils/userRoles");
const { sendNotification } = require("../controllers/notifications.controller");
const User = require("../models/user.model");
const Child = require("../models/child.model");

router
  .route("/")
  .get(
    verifyToken,
    allowedTo(userRoles.ADMIN),
    vaccinationController.getAllVaccinations
  )
  .post(verifyToken, allowedTo(userRoles.ADMIN), async (req, res, next) => {
    try {
      const adminId = req.user.id;

      // استدعاء دالة createVaccinationForAllChildren
      const result =
        await vaccinationController.createVaccinationForAllChildren(
          req,
          res,
          next
        );

      // التأكد إن العملية نجحت وإن الـ response تم إرساله
      if (res.headersSent) {
        const vaccination = result.data; // افتراض إن createVaccinationForAllChildren بترجع data
        if (vaccination) {
          console.log(
            `Sending notifications for new vaccination: ${req.body.disease}`
          );

          // إشعار للأدمن
          await sendNotification(
            adminId,
            null,
            null,
            "New Vaccination Added",
            `A new vaccination "${req.body.disease}" has been added for all children.`,
            "vaccination",
            "patient"
          );

          // إشعار لكل اليوزرز اللي عندهم أطفال
          const users = await User.find({ role: userRoles.PATIENT }).select(
            "_id"
          );
          const children = await Child.find({
            parentId: { $in: users.map((user) => user._id) },
          }).select("_id parentId");

          for (const child of children) {
            await sendNotification(
              child.parentId,
              child._id,
              null,
              "New Vaccination Available",
              `A new vaccination "${req.body.disease}" is now required for your child.`,
              "vaccination",
              "patient"
            );
          }
        }
      }
    } catch (error) {
      console.error("Error creating vaccination for all children:", error);
      return next(
        appError.create("Failed to create vaccination", 500, "error")
      );
    }
  });

router
  .route("/:vaccinationId")
  .delete(verifyToken, allowedTo(userRoles.ADMIN), async (req, res, next) => {
    try {
      const adminId = req.user.id;

      // استدعاء دالة deleteVaccinationForAllChildren
      const result =
        await vaccinationController.deleteVaccinationForAllChildren(
          req,
          res,
          next
        );

      // التأكد إن العملية نجحت وإن الـ response تم إرساله
      if (res.headersSent) {
        console.log(
          `Sending notification for deleted vaccination: ${req.params.vaccinationId}`
        );
        await sendNotification(
          adminId,
          null,
          null,
          "Vaccination Deleted",
          `The vaccination has been deleted for all children.`,
          "vaccination",
          "patient"
        );
      }
    } catch (error) {
      console.error(
        `Error deleting vaccination ${req.params.vaccinationId}:`,
        error
      );
      return next(
        appError.create("Failed to delete vaccination", 500, "error")
      );
    }
  });

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
    async (req, res, next) => {
      try {
        const { childId, vaccinationId } = req.params;
        const userId = req.user.id;

        // استدعاء دالة updateUserVaccination
        const result = await vaccinationController.updateUserVaccination(
          req,
          res,
          next
        );

        // التأكد إن العملية نجحت وإن الـ response تم إرساله
        if (res.headersSent) {
          const vaccination = result.data; // افتراض إن updateUserVaccination بترجع data
          if (vaccination) {
            console.log(
              `Sending notification for updated vaccination: ${vaccinationId}`
            );
            await sendNotification(
              userId,
              childId,
              null,
              "Vaccination Updated",
              `The vaccination "${vaccination.vaccineInfoId.disease}" has been updated for your child.`,
              "vaccination",
              "patient"
            );
          }
        }
      } catch (error) {
        console.error(
          `Error updating vaccination ${vaccinationId} for child ${childId}:`,
          error
        );
        return next(
          appError.create("Failed to update vaccination", 500, "error")
        );
      }
    }
  )
  .delete(
    verifyToken,
    allowedTo(userRoles.ADMIN, userRoles.DOCTOR, userRoles.PATIENT),
    async (req, res, next) => {
      try {
        const { childId, vaccinationId } = req.params;
        const userId = req.user.id;

        // استدعاء دالة deleteUserVaccination
        const result = await vaccinationController.deleteUserVaccination(
          req,
          res,
          next
        );

        // التأكد إن العملية نجحت وإن الـ response تم إرساله
        if (res.headersSent) {
          console.log(
            `Sending notification for deleted vaccination: ${vaccinationId}`
          );
          await sendNotification(
            userId,
            childId,
            null,
            "Vaccination Deleted",
            `The vaccination has been deleted for your child.`,
            "vaccination",
            "patient"
          );
        }
      } catch (error) {
        console.error(
          `Error deleting vaccination ${vaccinationId} for child ${childId}:`,
          error
        );
        return next(
          appError.create("Failed to delete vaccination", 500, "error")
        );
      }
    }
  );

module.exports = router;