// const express = require("express");
// const router = express.Router();
// const vaccinationController = require("../controllers/vaccination.controller");
// const verifyToken = require("../middlewares/virifyToken");
// const allowedTo = require("../middlewares/allowedTo");
// const userRoles = require("../utils/userRoles");
// const upload = require("../utils/multer.config"); // استيراد Multer المركزي

// router
//   .route("/")
//   .get(
//     verifyToken,
//     allowedTo(userRoles.ADMIN),
//     vaccinationController.getAllVaccinations
//   )
//   .post(verifyToken, allowedTo(userRoles.ADMIN), async (req, res, next) => {
//     try {
//       const adminId = req.user.id;
//       const result =
//         await vaccinationController.createVaccinationForAllChildren(
//           req,
//           res,
//           next
//         );
//       if (res.headersSent) {
//         const vaccination = result.data;
//         if (vaccination) {
//           console.log(
//             `Sending notifications for new vaccination: ${req.body.disease}`
//           );
//           const {
//             sendNotification,
//           } = require("../controllers/notifications.controller");
//           const User = require("../models/user.model");
//           const Child = require("../models/child.model");
//           await sendNotification(
//             adminId,
//             null,
//             null,
//             "New Vaccination Added",
//             `A new vaccination "${req.body.disease}" has been added for all children.`,
//             "vaccination",
//             "patient"
//           );
//           const users = await User.find({ role: userRoles.PATIENT }).select(
//             "_id"
//           );
//           const children = await Child.find({
//             parentId: { $in: users.map((user) => user._id) },
//           }).select("_id parentId");
//           for (const child of children) {
//             await sendNotification(
//               child.parentId,
//               child._id,
//               null,
//               "New Vaccination Available",
//               `A new vaccination "${req.body.disease}" is now required for your child.`,
//               "vaccination",
//               "patient"
//             );
//           }
//         }
//       }
//     } catch (error) {
//       console.error("Error creating vaccination for all children:", error);
//       return next(
//         appError.create("Failed to create vaccination", 500, "error")
//       );
//     }
//   });

// router
//   .route("/:vaccinationId")
//   .delete(verifyToken, allowedTo(userRoles.ADMIN), async (req, res, next) => {
//     try {
//       const adminId = req.user.id;
//       const result =
//         await vaccinationController.deleteVaccinationForAllChildren(
//           req,
//           res,
//           next
//         );
//       if (res.headersSent) {
//         console.log(
//           `Sending notification for deleted vaccination: ${req.params.vaccinationId}`
//         );
//         const {
//           sendNotification,
//         } = require("../controllers/notifications.controller");
//         await sendNotification(
//           adminId,
//           null,
//           null,
//           "Vaccination Deleted",
//           `The vaccination has been deleted for all children.`,
//           "vaccination",
//           "patient"
//         );
//       }
//     } catch (error) {
//       console.error(
//         `Error deleting vaccination ${req.params.vaccinationId}:`,
//         error
//       );
//       return next(
//         appError.create("Failed to delete vaccination", 500, "error")
//       );
//     }
//   });

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
//     (req, res, next) => {
//       req.modelName = "vaccination"; // إضافة اسم الموديل
//       next();
//     },
//     upload.single("image"), // إضافة Multer لرفع الصورة عند التحديث
//     async (req, res, next) => {
//       try {
//         const { childId, vaccinationId } = req.params;
//         const userId = req.user.id;
//         const result = await vaccinationController.updateUserVaccination(
//           req,
//           res,
//           next
//         );
//         if (res.headersSent) {
//           const vaccination = result.data;
//           if (vaccination) {
//             console.log(
//               `Sending notification for updated vaccination: ${vaccinationId}`
//             );
//             const {
//               sendNotification,
//             } = require("../controllers/notifications.controller");
//             await sendNotification(
//               userId,
//               childId,
//               null,
//               "Vaccination Updated",
//               `The vaccination "${vaccination.vaccineInfoId.disease}" has been updated for your child.`,
//               "vaccination",
//               "patient"
//             );
//           }
//         }
//       } catch (error) {
//         console.error(
//           `Error updating vaccination ${vaccinationId} for child ${childId}:`,
//           error
//         );
//         return next(
//           appError.create("Failed to update vaccination", 500, "error")
//         );
//       }
//     }
//   )
//   .delete(
//     verifyToken,
//     allowedTo(userRoles.ADMIN, userRoles.DOCTOR, userRoles.PATIENT),
//     async (req, res, next) => {
//       try {
//         const { childId, vaccinationId } = req.params;
//         const userId = req.user.id;
//         const result = await vaccinationController.deleteUserVaccination(
//           req,
//           res,
//           next
//         );
//         if (res.headersSent) {
//           console.log(
//             `Sending notification for deleted vaccination: ${vaccinationId}`
//           );
//           const {
//             sendNotification,
//           } = require("../controllers/notifications.controller");
//           await sendNotification(
//             userId,
//             childId,
//             null,
//             "Vaccination Deleted",
//             `The vaccination has been deleted for your child.`,
//             "vaccination",
//             "patient"
//           );
//         }
//       } catch (error) {
//         console.error(
//           `Error deleting vaccination ${vaccinationId} for child ${childId}:`,
//           error
//         );
//         return next(
//           appError.create("Failed to delete vaccination", 500, "error")
//         );
//       }
//     }
//   );

// module.exports = router;
//****************************************** */

// const express = require("express");
// const router = express.Router();
// const vaccinationController = require("../controllers/vaccination.controller");
// const verifyToken = require("../middlewares/virifyToken");
// const allowedTo = require("../middlewares/allowedTo");
// const userRoles = require("../utils/userRoles");
// const upload = require("../utils/multer.config");
// const appError = require("../utils/appError");
// const {
//   sendNotificationCore,
// } = require("../controllers/notifications.controller");
// const User = require("../models/user.model");
// const Child = require("../models/child.model");

// router
//   .route("/")
//   .get(
//     verifyToken,
//     allowedTo(userRoles.ADMIN),
//     vaccinationController.getAllVaccinations
//   )
//   .post(verifyToken, allowedTo(userRoles.ADMIN), async (req, res, next) => {
//     try {
//       const adminId = req.user.id;
//       await vaccinationController.createVaccinationForAllChildren(
//         req,
//         res,
//         next
//       );
//       if (res.headersSent) {
//         const vaccination =
//           res.locals.data || (res.statusCode === 201 && res._body?.data);
//         if (vaccination) {
//           console.log(
//             `Sending notifications for new vaccination: ${req.body.disease}`
//           );
//           try {
//             await sendNotificationCore(
//               adminId,
//               null,
//               null,
//               "New Vaccination Added",
//               `A new vaccination "${req.body.disease}" has been added for all children.`,
//               "vaccination",
//               "patient"
//             );
//             const users = await User.find({ role: userRoles.PATIENT }).select(
//               "_id"
//             );
//             const children = await Child.find({
//               parentId: { $in: users.map((user) => user._id) },
//             }).select("_id parentId");
//             for (const child of children) {
//               await sendNotificationCore(
//                 child.parentId,
//                 child._id,
//                 null,
//                 "New Vaccination Available",
//                 `A new vaccination "${req.body.disease}" is now required for your child.`,
//                 "vaccination",
//                 "patient"
//               );
//             }
//           } catch (error) {
//             console.error(
//               `Failed to send notifications for new vaccination: ${req.body.disease}`,
//               error
//             );
//           }
//         }
//       }
//     } catch (error) {
//       console.error("Error creating vaccination for all children:", error);
//       return next(
//         appError.create("Failed to create vaccination", 500, "error")
//       );
//     }
//   });

// router
//   .route("/:vaccinationId")
//   .delete(verifyToken, allowedTo(userRoles.ADMIN), async (req, res, next) => {
//     try {
//       const adminId = req.user.id;
//       await vaccinationController.deleteVaccinationForAllChildren(
//         req,
//         res,
//         next
//       );
//       if (res.headersSent) {
//         console.log(
//           `Sending notification for deleted vaccination: ${req.params.vaccinationId}`
//         );
//         try {
//           await sendNotificationCore(
//             adminId,
//             null,
//             null,
//             "Vaccination Deleted",
//             `The vaccination has been deleted for all children.`,
//             "vaccination",
//             "patient"
//           );
//         } catch (error) {
//           console.error(
//             `Failed to send notification for deleted vaccination: ${req.params.vaccinationId}`,
//             error
//           );
//         }
//       }
//     } catch (error) {
//       console.error(
//         `Error deleting vaccination ${req.params.vaccinationId}:`,
//         error
//       );
//       return next(
//         appError.create("Failed to delete vaccination", 500, "error")
//       );
//     }
//   });

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
//     vaccinationController.getSingleUserVaccination
//   )
//   .patch(
//     verifyToken,
//     allowedTo(userRoles.ADMIN, userRoles.DOCTOR, userRoles.PATIENT),
//     (req, res, next) => {
//       req.modelName = "vaccination";
//       next();
//     },
//     upload.single("image"),
//     async (req, res, next) => {
//       try {
//         const { childId, vaccinationId } = req.params;
//         const userId = req.user.id;
//         await vaccinationController.updateUserVaccination(req, res, next);
//         if (res.headersSent) {
//           const vaccination =
//             res.locals.data || (res.statusCode === 200 && res._body?.data);
//           if (vaccination) {
//             console.log(
//               `Sending notification for updated vaccination: ${vaccinationId}`
//             );
//             try {
//               await sendNotificationCore(
//                 userId,
//                 childId,
//                 null,
//                 "Vaccination Updated",
//                 `The vaccination "${
//                   vaccination.vaccineInfo?.name || "unknown"
//                 }" has been updated for your child.`,
//                 "vaccination",
//                 "patient"
//               );
//             } catch (error) {
//               console.error(
//                 `Failed to send notification for updated vaccination: ${vaccinationId}`,
//                 error
//               );
//             }
//           }
//         }
//       } catch (error) {
//         console.error(
//           `Error updating vaccination ${vaccinationId} for child ${childId}:`,
//           error
//         );
//         return next(
//           appError.create("Failed to update vaccination", 500, "error")
//         );
//       }
//     }
//   )
//   .delete(
//     verifyToken,
//     allowedTo(userRoles.ADMIN, userRoles.DOCTOR, userRoles.PATIENT),
//     async (req, res, next) => {
//       try {
//         const { childId, vaccinationId } = req.params;
//         const userId = req.user.id;
//         await vaccinationController.deleteUserVaccination(req, res, next);
//         if (res.headersSent) {
//           console.log(
//             `Sending notification for deleted vaccination: ${vaccinationId}`
//           );
//           try {
//             await sendNotificationCore(
//               userId,
//               childId,
//               null,
//               "Vaccination Deleted",
//               `The vaccination has been deleted for your child.`,
//               "vaccination",
//               "patient"
//             );
//           } catch (error) {
//             console.error(
//               `Failed to send notification for deleted vaccination: ${vaccinationId}`,
//               error
//             );
//           }
//         }
//       } catch (error) {
//         console.error(
//           `Error deleting vaccination ${vaccinationId} for child ${childId}:`,
//           error
//         );
//         return next(
//           appError.create("Failed to delete vaccination", 500, "error")
//         );
//       }
//     }
//   );

// module.exports = router;

//************************** */
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
    vaccinationController.updateUserVaccination
  )
  .delete(
    verifyToken,
    allowedTo(userRoles.ADMIN, userRoles.DOCTOR, userRoles.PATIENT),
    vaccinationController.deleteUserVaccination
  );

module.exports = router;