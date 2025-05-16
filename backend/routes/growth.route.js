// const express = require("express");
// const router = express.Router();
// const verifyToken = require("../middlewares/virifyToken");
// const allowedTo = require("../middlewares/allowedTo");
// const userRoles = require("../utils/userRoles");
// // const validationschema = require("../middleware/validationschema");
// const growthController = require("../controllers/growth.controller");
// const { sendNotification } = require("../controllers/notifications.controller");
// const Appointment = require("../models/appointment.model");

// router
//   .route("/:childId")
//   .post(
//     verifyToken,
//     allowedTo(userRoles.ADMIN, userRoles.DOCTOR, userRoles.PATIENT),
//     // validationschema.validateGrowth,
//     async (req, res, next) => {
//       try {
//         const { childId } = req.params;
//         const userId = req.user.id;

//         // استدعاء دالة createGrowth
//         const result = await growthController.createGrowth(req, res, next);

//         // التأكد إن العملية نجحت وإن الـ response تم إرساله
//         if (res.headersSent) {
//           const growth = result.data; // افتراض إن createGrowth بترجع data
//           if (growth) {
//             console.log(
//               `Sending notification for new growth record: Height ${growth.height}, Weight ${growth.weight}`
//             );
//             await sendNotification(
//               userId,
//               childId,
//               null,
//               "New Growth Record Added",
//               `A new growth record (Height: ${growth.height}, Weight: ${growth.weight}) has been added for your child.`,
//               "growth",
//               "patient"
//             );

//             // التحقق من انحراف الطول
//             const standardHeight = growth.ageInMonths * 2 + 50;
//             const heightDeviation = Math.abs(growth.height - standardHeight);
//             if (heightDeviation > 10) {
//               console.log(
//                 `Sending growth alert for child ${childId}: Height deviation ${heightDeviation}`
//               );
//               await sendNotification(
//                 userId,
//                 childId,
//                 null,
//                 "Growth Alert",
//                 `The height of your child (${growth.height} cm) deviates significantly from the expected value (${standardHeight} cm).`,
//                 "growth_alert",
//                 "patient"
//               );

//               // إشعار للدكتور (مش مفعل افتراضيًا)
//               /*
//               const latestAppointment = await Appointment.findOne({ childId, status: "Accepted" })
//                 .sort({ date: -1 })
//                 .select("doctorId");
//               if (latestAppointment && latestAppointment.doctorId) {
//                 await sendNotification(
//                   null,
//                   childId,
//                   latestAppointment.doctorId,
//                   "Growth Alert for Patient",
//                   `A growth record for a patient shows significant height deviation (Height: ${growth.height} cm, Expected: ${standardHeight} cm).`,
//                   "growth_alert",
//                   "doctor"
//                 );
//               }
//               */
//             }
//           }
//         }
//       } catch (error) {
//         console.error(
//           `Error creating growth record for child ${childId}:`,
//           error
//         );
//         return next(
//           appError.create("Failed to create growth record", 500, "error")
//         );
//       }
//     }
//   )
//   .get(
//     verifyToken,
//     allowedTo(userRoles.ADMIN, userRoles.DOCTOR, userRoles.PATIENT),
//     growthController.getAllGrowth
//   );

// router
//   .route("/:childId/last")
//   .get(
//     verifyToken,
//     allowedTo(userRoles.ADMIN, userRoles.DOCTOR, userRoles.PATIENT),
//     growthController.getLastGrowthRecord
//   );

// router
//   .route("/:childId/last-change")
//   .get(
//     verifyToken,
//     allowedTo(userRoles.ADMIN, userRoles.DOCTOR, userRoles.PATIENT),
//     growthController.getLastGrowthChange
//   );

// router
//   .route("/:childId/:growthId")
//   .get(
//     verifyToken,
//     allowedTo(userRoles.ADMIN, userRoles.DOCTOR, userRoles.PATIENT),
//     growthController.getSingleGrowth
//   )
//   .patch(
//     verifyToken,
//     allowedTo(userRoles.ADMIN, userRoles.DOCTOR, userRoles.PATIENT),
//     // validationschema.validateGrowth,
//     async (req, res, next) => {
//       try {
//         const { childId, growthId } = req.params;
//         const userId = req.user.id;

//         // استدعاء دالة updateGrowth
//         const result = await growthController.updateGrowth(req, res, next);

//         // التأكد إن العملية نجحت وإن الـ response تم إرساله
//         if (res.headersSent) {
//           const growth = result.data; // افتراض إن updateGrowth بترجع data
//           if (growth) {
//             console.log(
//               `Sending notification for updated growth record: Height ${growth.height}, Weight ${growth.weight}`
//             );
//             await sendNotification(
//               userId,
//               childId,
//               null,
//               "Growth Record Updated",
//               `The growth record (Height: ${growth.height}, Weight: ${growth.weight}) has been updated for your child.`,
//               "growth",
//               "patient"
//             );

//             // التحقق من انحراف الطول
//             const standardHeight = growth.ageInMonths * 2 + 50;
//             const heightDeviation = Math.abs(growth.height - standardHeight);
//             if (heightDeviation > 10) {
//               console.log(
//                 `Sending growth alert for child ${childId}: Height deviation ${heightDeviation}`
//               );
//               await sendNotification(
//                 userId,
//                 childId,
//                 null,
//                 "Growth Alert",
//                 `The height of your child (${growth.height} cm) deviates significantly from the expected value (${standardHeight} cm).`,
//                 "growth_alert",
//                 "patient"
//               );

//               // إشعار للدكتور (مش مفعل افتراضيًا)
//               /*
//               const latestAppointment = await Appointment.findOne({ childId, status: "Accepted" })
//                 .sort({ date: -1 })
//                 .select("doctorId");
//               if (latestAppointment && latestAppointment.doctorId) {
//                 await sendNotification(
//                   null,
//                   childId,
//                   latestAppointment.doctorId,
//                   "Growth Alert for Patient",
//                   `A growth record for a patient shows significant height deviation (Height: ${growth.height} cm, Expected: ${standardHeight} cm).`,
//                   "growth_alert",
//                   "doctor"
//                 );
//               }
//               */
//             }
//           }
//         }
//       } catch (error) {
//         console.error(
//           `Error updating growth record ${growthId} for child ${childId}:`,
//           error
//         );
//         return next(
//           appError.create("Failed to update growth record", 500, "error")
//         );
//       }
//     }
//   )
//   .delete(
//     verifyToken,
//     allowedTo(userRoles.ADMIN, userRoles.DOCTOR, userRoles.PATIENT),
//     async (req, res, next) => {
//       try {
//         const { childId, growthId } = req.params;
//         const userId = req.user.id;

//         // استدعاء دالة deleteGrowth
//         const result = await growthController.deleteGrowth(req, res, next);

//         // التأكد إن العملية نجحت وإن الـ response تم إرساله
//         if (res.headersSent) {
//           console.log(
//             `Sending notification for deleted growth record: ${growthId}`
//           );
//           await sendNotification(
//             userId,
//             childId,
//             null,
//             "Growth Record Deleted",
//             `A growth record has been deleted for your child.`,
//             "growth",
//             "patient"
//           );
//         }
//       } catch (error) {
//         console.error(
//           `Error deleting growth record ${growthId} for child ${childId}:`,
//           error
//         );
//         return next(
//           appError.create("Failed to delete growth record", 500, "error")
//         );
//       }
//     }
//   );

// module.exports = router;

const express = require("express");
const router = express.Router();
const verifyToken = require("../middlewares/virifyToken");
const allowedTo = require("../middlewares/allowedTo");
const userRoles = require("../utils/userRoles");
const growthController = require("../controllers/growth.controller");
const {
  sendNotificationCore,
} = require("../controllers/notifications.controller");
const Appointment = require("../models/appointment.model");
const appError = require("../utils/appError");

router
  .route("/:childId")
  .post(
    verifyToken,
    allowedTo(userRoles.ADMIN, userRoles.DOCTOR, userRoles.PATIENT),
    async (req, res, next) => {
      try {
        const { childId } = req.params;
        const userId = req.user.id;

        // استدعاء دالة createGrowth
        await growthController.createGrowth(req, res, next);

        // التأكد إن العملية نجحت وإن الـ response تم إرساله
        if (res.headersSent) {
          const growth =
            res.locals.data || (res.statusCode === 201 && res._body?.data); // افتراض إن البيانات في res.locals.data أو res._body.data
          if (growth) {
            console.log(
              `Sending notification for new growth record: Height ${growth.height}, Weight ${growth.weight}`
            );
            try {
              await sendNotificationCore(
                userId,
                childId,
                null,
                "New Growth Record Added",
                `A new growth record (Height: ${growth.height}, Weight: ${growth.weight}) has been added for your child.`,
                "growth",
                "patient"
              );
            } catch (error) {
              console.error(
                `Failed to send notification for new growth record: ${growth.height}`,
                error
              );
            }

            // التحقق من انحراف الطول
            const standardHeight = growth.ageInMonths * 2 + 50;
            const heightDeviation = Math.abs(growth.height - standardHeight);
            if (heightDeviation > 10) {
              console.log(
                `Sending growth alert for child ${childId}: Height deviation ${heightDeviation}`
              );
              try {
                await sendNotificationCore(
                  userId,
                  childId,
                  null,
                  "Growth Alert",
                  `The height of your child (${growth.height} cm) deviates significantly from the expected value (${standardHeight} cm).`,
                  "growth_alert",
                  "patient"
                );
              } catch (error) {
                console.error(
                  `Failed to send growth alert for child ${childId}`,
                  error
                );
              }

              // إشعار للدكتور (مش مفعل افتراضيًا)
              /*
              const latestAppointment = await Appointment.findOne({ childId, status: "Accepted" })
                .sort({ date: -1 })
                .select("doctorId");
              if (latestAppointment && latestAppointment.doctorId) {
                await sendNotificationCore(
                  null,
                  childId,
                  latestAppointment.doctorId,
                  "Growth Alert for Patient",
                  `A growth record for a patient shows significant height deviation (Height: ${growth.height} cm, Expected: ${standardHeight} cm).`,
                  "growth_alert",
                  "doctor"
                );
              }
              */
            }
          }
        }
      } catch (error) {
        console.error(
          `Error creating growth record for child ${childId}:`,
          error
        );
        return next(
          appError.create("Failed to create growth record", 500, "error")
        );
      }
    }
  )
  .get(
    verifyToken,
    allowedTo(userRoles.ADMIN, userRoles.DOCTOR, userRoles.PATIENT),
    growthController.getAllGrowth
  );

router
  .route("/:childId/last")
  .get(
    verifyToken,
    allowedTo(userRoles.ADMIN, userRoles.DOCTOR, userRoles.PATIENT),
    growthController.getLastGrowthRecord
  );

router
  .route("/:childId/last-change")
  .get(
    verifyToken,
    allowedTo(userRoles.ADMIN, userRoles.DOCTOR, userRoles.PATIENT),
    growthController.getLastGrowthChange
  );

router
  .route("/:childId/:growthId")
  .get(
    verifyToken,
    allowedTo(userRoles.ADMIN, userRoles.DOCTOR, userRoles.PATIENT),
    growthController.getSingleGrowth
  )
  .patch(
    verifyToken,
    allowedTo(userRoles.ADMIN, userRoles.DOCTOR, userRoles.PATIENT),
    async (req, res, next) => {
      try {
        const { childId, growthId } = req.params;
        const userId = req.user.id;

        // استدعاء دالة updateGrowth
        await growthController.updateGrowth(req, res, next);

        // التأكد إن العملية نجحت وإن الـ response تم إرساله
        if (res.headersSent) {
          const growth =
            res.locals.data || (res.statusCode === 200 && res._body?.data); // افتراض إن البيانات في res.locals.data أو res._body.data
          if (growth) {
            console.log(
              `Sending notification for updated growth record: Height ${growth.height}, Weight ${growth.weight}`
            );
            try {
              await sendNotificationCore(
                userId,
                childId,
                null,
                "Growth Record Updated",
                `The growth record (Height: ${growth.height}, Weight: ${growth.weight}) has been updated for your child.`,
                "growth",
                "patient"
              );
            } catch (error) {
              console.error(
                `Failed to send notification for updated growth record: ${growth.height}`,
                error
              );
            }

            // التحقق من انحراف الطول
            const standardHeight = growth.ageInMonths * 2 + 50;
            const heightDeviation = Math.abs(growth.height - standardHeight);
            if (heightDeviation > 10) {
              console.log(
                `Sending growth alert for child ${childId}: Height deviation ${heightDeviation}`
              );
              try {
                await sendNotificationCore(
                  userId,
                  childId,
                  null,
                  "Growth Alert",
                  `The height of your child (${growth.height} cm) deviates significantly from the expected value (${standardHeight} cm).`,
                  "growth_alert",
                  "patient"
                );
              } catch (error) {
                console.error(
                  `Failed to send growth alert for child ${childId}`,
                  error
                );
              }

              // إشعار للدكتور (مش مفعل افتراضيًا)
              /*
              const latestAppointment = await Appointment.findOne({ childId, status: "Accepted" })
                .sort({ date: -1 })
                .select("doctorId");
              if (latestAppointment && latestAppointment.doctorId) {
                await sendNotificationCore(
                  null,
                  childId,
                  latestAppointment.doctorId,
                  "Growth Alert for Patient",
                  `A growth record for a patient shows significant height deviation (Height: ${growth.height} cm, Expected: ${standardHeight} cm).`,
                  "growth_alert",
                  "doctor"
                );
              }
              */
            }
          }
        }
      } catch (error) {
        console.error(
          `Error updating growth record ${growthId} for child ${childId}:`,
          error
        );
        return next(
          appError.create("Failed to update growth record", 500, "error")
        );
      }
    }
  )
  .delete(
    verifyToken,
    allowedTo(userRoles.ADMIN, userRoles.DOCTOR, userRoles.PATIENT),
    async (req, res, next) => {
      try {
        const { childId, growthId } = req.params;
        const userId = req.user.id;

        // استدعاء دالة deleteGrowth
        await growthController.deleteGrowth(req, res, next);

        // التأكد إن العملية نجحت وإن الـ response تم إرساله
        if (res.headersSent) {
          console.log(
            `Sending notification for deleted growth record: ${growthId}`
          );
          try {
            await sendNotificationCore(
              userId,
              childId,
              null,
              "Growth Record Deleted",
              `A growth record has been deleted for your child.`,
              "growth",
              "patient"
            );
          } catch (error) {
            console.error(
              `Failed to send notification for deleted growth record: ${growthId}`,
              error
            );
          }
        }
      } catch (error) {
        console.error(
          `Error deleting growth record ${growthId} for child ${childId}:`,
          error
        );
        return next(
          appError.create("Failed to delete growth record", 500, "error")
        );
      }
    }
  );

module.exports = router;