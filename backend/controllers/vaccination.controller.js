const UserVaccination = require("../models/UserVaccination.model");
const VaccineInfo = require("../models/vaccineInfo.model");
const Child = require("../models/child.model");
const asyncWrapper = require("../middlewares/asyncWrapper");
const appError = require("../utils/appError");
const httpStatusText = require("../utils/httpStatusText");
const { calculateDueDate } = require("../utils/calculateVaccinationDate");
const {
  sendNotificationCore,
} = require("../controllers/notifications.controller");
const { deleteObject } = require("../utils/s3-operations");

const createVaccinationForAllChildren = asyncWrapper(async (req, res, next) => {
  const {
    ageVaccine,
    originalSchedule,
    doseName,
    disease,
    dosageAmount,
    administrationMethod,
    description,
  } = req.body;

  if (
    !ageVaccine ||
    !(originalSchedule + 1) ||
    !doseName ||
    !disease ||
    !dosageAmount ||
    !administrationMethod ||
    !description
  ) {
    return next(
      appError.create(
        "All vaccine details are required.",
        400,
        httpStatusText.FAIL
      )
    );
  }

  const vaccineInfo = await VaccineInfo.create({
    ageVaccine,
    originalSchedule,
    doseName,
    disease,
    dosageAmount,
    administrationMethod,
    description,
  });
  const children = await Child.find();
  if (!children.length) {
    return next(
      appError.create(
        "No children found in the system.",
        404,
        httpStatusText.FAIL
      )
    );
  }

  await Promise.all(
    children.map(async (child) => {
      const dueDate = new Date(child.birthDate);
      dueDate.setMonth(dueDate.getMonth() + originalSchedule);
      const lastVaccination = await UserVaccination.findOne({
        childId: child._id,
      }).sort({ dueDate: -1 });
      let previousDelay = lastVaccination ? lastVaccination.delayDays : 0;
      dueDate.setDate(dueDate.getDate() + previousDelay);

      const userVaccination = new UserVaccination({
        childId: child._id,
        vaccineInfoId: vaccineInfo._id,
        dueDate,
      });
      await userVaccination.save();
    })
  );
  for (const child of children) {
    try {
      await sendNotificationCore(
        child.parentId,
        child._id,
        null,
        "Vaccination Added",
        `${child.name}: ${vaccineInfo.disease} (${
          vaccineInfo.doseName || "unknown"
        }) scheduled for ${new Date(
          new Date(child.birthDate).setMonth(
            new Date(child.birthDate).getMonth() + originalSchedule
          )
        ).toLocaleDateString()}.`,
        "vaccination",
        "patient"
      );
      console.log(
        `Notification sent for new vaccination: ${vaccineInfo.disease} for child: ${child.name}`
      );
    } catch (error) {
      console.error(
        `Failed to send notification for new vaccination: ${vaccineInfo.disease} for child: ${child.name}`,
        error
      );
    }
  }
  res.status(201).json({
    status: httpStatusText.SUCCESS,
    message: "Vaccination added successfully for all children.",
    data: vaccineInfo,
  });
});

const getAllVaccinations = asyncWrapper(async (req, res, next) => {
  const vaccinations = await UserVaccination.find()
    .populate("childId", "name birthDate gender")
    .populate("vaccineInfoId");

  if (!vaccinations.length) {
    return next(
      appError.create("No vaccinations found", 404, httpStatusText.FAIL)
    );
  }

  res.status(200).json({ status: httpStatusText.SUCCESS, data: vaccinations });
});

const deleteVaccinationForAllChildren = asyncWrapper(async (req, res, next) => {
  const { vaccinationId } = req.params;

  const vaccine = await VaccineInfo.findById(vaccinationId);
  if (!vaccine) {
    return next(appError.create("Vaccine not found", 404, httpStatusText.FAIL));
  }

  const deletedVaccinations = await UserVaccination.deleteMany({
    vaccineInfoId: vaccinationId,
  });

  await VaccineInfo.findByIdAndDelete(vaccinationId);

  res.status(200).json({
    status: "success",
    message: "Vaccine and all associated records deleted successfully",
    deletedVaccinationsCount: deletedVaccinations.deletedCount,
  });
});

const getVaccinationsByChildId = asyncWrapper(async (req, res, next) => {
  const { childId } = req.params;
  const vaccinations = await UserVaccination.find({ childId })
    .populate("childId", "name birthDate gender")
    .populate("vaccineInfoId");

  if (!vaccinations.length) {
    return next(
      appError.create(
        "No vaccinations found for this child",
        404,
        httpStatusText.FAIL
      )
    );
  }

  res.status(200).json({
    status: httpStatusText.SUCCESS,
    data: vaccinations.map((vaccination) => ({
      _id: vaccination.vaccineInfoId._id,
      userVaccinationId: vaccination._id,
      ageVaccine: vaccination.vaccineInfoId.ageVaccine,
      doseName: vaccination.vaccineInfoId.doseName,
      disease: vaccination.vaccineInfoId.disease,
      dosageAmount: vaccination.vaccineInfoId.dosageAmount,
      administrationMethod: vaccination.vaccineInfoId.administrationMethod,
      description: vaccination.vaccineInfoId.description,
      dueDate: vaccination.dueDate,
      status: vaccination.status,
    })),
  });
});

// const updateUserVaccination = asyncWrapper(async (req, res, next) => {
//   const { childId, vaccinationId } = req.params;
//   const { actualDate, status, notes } = req.body;

//   if (!actualDate || !status) {
//     return next(
//       appError.create(
//         "Vaccination details are required",
//         400,
//         httpStatusText.FAIL
//       )
//     );
//   }

//   const vaccination = await UserVaccination.findOne({
//     _id: vaccinationId,
//     childId,
//   }).populate("vaccineInfoId");

//   if (!vaccination) {
//     return next(
//       appError.create("Vaccination record not found", 404, httpStatusText.FAIL)
//     );
//   }

//   const child = await Child.findById(childId);

//   if (!child || !child.birthDate) {
//     return next(
//       appError.create(
//         "Child record not found or birthDate is missing",
//         404,
//         httpStatusText.FAIL
//       )
//     );
//   }
//   const dueDate = new Date(child.birthDate);
//   dueDate.setMonth(
//     dueDate.getMonth() + vaccination.vaccineInfoId.originalSchedule
//   );
//   const delayDays = Math.max(
//     0,
//     Math.floor(
//       (new Date(actualDate) - new Date(dueDate)) / (1000 * 60 * 60 * 24)
//     )
//   );

//   const currentDate = new Date();
//   currentDate.setHours(0, 0, 0, 0);
//   const newActualDate = new Date(actualDate);
//   newActualDate.setHours(0, 0, 0, 0);

//   if (newActualDate > currentDate) {
//     return next(
//       appError.create(
//         "Cannot update vaccination with a future actual date",
//         400,
//         httpStatusText.FAIL
//       )
//     );
//   }

//   vaccination.actualDate = new Date(actualDate);
//   vaccination.delayDays = delayDays;
//   vaccination.status = status;
//   vaccination.notes = notes;
//   vaccination.image = req.s3Data ? req.s3Data.url : vaccination.image;
//   await vaccination.save();

//   const futureVaccinations = await UserVaccination.find({
//     childId,
//     dueDate: { $gt: vaccination.dueDate },
//   })
//     .populate("vaccineInfoId")
//     .sort("dueDate");

//   if (futureVaccinations.length > 0) {
//     let accumulatedDelay = delayDays > 0 ? delayDays : 0;
//     for (let future of futureVaccinations) {
//       let dueDate = new Date(child.birthDate);
//       dueDate.setMonth(
//         dueDate.getMonth() + future.vaccineInfoId.originalSchedule
//       );
//       let newDueDate = new Date(dueDate);
//       let lastnewdate = dueDate.setDate(
//         newDueDate.getDate() + accumulatedDelay
//       );
//       let storeDueDate = new Date(lastnewdate);

//       await UserVaccination.updateOne(
//         { _id: future._id },
//         {
//           $set: {
//             dueDate: storeDueDate,
//             delayDays: accumulatedDelay,
//           },
//         }
//       );

//       accumulatedDelay = delayDays;
//     }
//   }

//   try {
//     const vaccineName = vaccination.vaccineInfoId?.name || "unknown";
//     await sendNotificationCore(
//       child.parentId,
//       childId,
//       null,
//       "Vaccination Updated",
//       `${child.name}: ${vaccineName} updated.`,
//       "vaccination",
//       "patient"
//     );
//     console.log(`Notification sent for updated vaccination: ${vaccineName}`);
//   } catch (error) {
//     console.error(
//       `Failed to send notification for updated vaccination: ${
//         vaccination.vaccineInfoId?.name || "unknown"
//       }`,
//       error
//     );
//   }

//   res.status(200).json({
//     status: "success",
//     message: "Vaccination record and future due dates updated successfully",
//     data: {
//       vaccineInfoId: vaccination.vaccineInfoId._id,
//       userVaccineId: vaccination._id,
//       dueDate: vaccination.dueDate,
//       actualDate: vaccination.actualDate,
//       delayDays: vaccination.delayDays,
//       status: vaccination.status,
//       notes: vaccination.notes,
//       image: vaccination.image,
//     },
//   });
// });



const updateUserVaccination = asyncWrapper(async (req, res, next) => {
  const { childId, vaccinationId } = req.params;
  const { actualDate, status, notes } = req.body;

  // Validate required fields
  if (!actualDate || !status) {
    return next(
      appError.create(
        "Vaccination details are required",
        400,
        httpStatusText.FAIL
      )
    );
  }

  // Find the vaccination record
  const vaccination = await UserVaccination.findOne({
    _id: vaccinationId,
    childId,
  }).populate("vaccineInfoId");

  if (!vaccination) {
    return next(
      appError.create("Vaccination record not found", 404, httpStatusText.FAIL)
    );
  }

  // Find the child
  const child = await Child.findById(childId);
  if (!child || !child.birthDate) {
    return next(
      appError.create(
        "Child record not found or birthDate is missing",
        404,
        httpStatusText.FAIL
      )
    );
  }

  // Calculate original dueDate for current vaccination (remains unchanged)
  const originalDueDate = new Date(child.birthDate);
  originalDueDate.setMonth(
    originalDueDate.getMonth() + vaccination.vaccineInfoId.originalSchedule
  );

  // Calculate delayDays based on original dueDate and new actualDate
  const delayDays = Math.max(
    0,
    Math.floor(
      (new Date(actualDate) - new Date(originalDueDate)) / (1000 * 60 * 60 * 24)
    )
  );

  // Validate actualDate is not in the future
  const currentDate = new Date();
  currentDate.setHours(0, 0, 0, 0);
  const newActualDate = new Date(actualDate);
  newActualDate.setHours(0, 0, 0, 0);
  if (newActualDate > currentDate) {
    return next(
      appError.create(
        "Cannot update vaccination with a future actual date",
        400,
        httpStatusText.FAIL
      )
    );
  }

  // Update the current vaccination (dueDate remains unchanged, store delayDays)
  vaccination.actualDate = new Date(actualDate);
  vaccination.status = status;
  vaccination.notes = notes;
  vaccination.image = req.s3Data ? req.s3Data.url : vaccination.image;
  vaccination.delayDays = delayDays; // Store delayDays as is
  await vaccination.save();

  // Update future vaccinations with the delay
  if (delayDays > 0) {
    const futureVaccinations = await UserVaccination.find({
      childId,
      dueDate: { $gt: vaccination.dueDate },
    })
      .populate("vaccineInfoId")
      .sort("dueDate");

    if (futureVaccinations.length > 0) {
      await Promise.all(
        futureVaccinations.map(async (future) => {
          // Calculate original dueDate for future vaccination
          const futureOriginalDueDate = new Date(child.birthDate);
          futureOriginalDueDate.setMonth(
            futureOriginalDueDate.getMonth() +
              future.vaccineInfoId.originalSchedule
          );
          // Apply the new delay to the original dueDate
          const newDueDate = new Date(futureOriginalDueDate);
          newDueDate.setDate(newDueDate.getDate() + delayDays);
          await UserVaccination.updateOne(
            { _id: future._id },
            {
              $set: {
                dueDate: newDueDate,
                delayDays: 0, // Keep delayDays 0 for future vaccinations
              },
            }
          );
        })
      );
    }
  }

  // Send notification
  // try {
  //   const vaccineName = vaccination.vaccineInfoId?.disease || "unknown";
  //   await sendNotificationCore(
  //     child.parentId,
  //     childId,
  //     null,
  //     "Vaccination Updated",
  //     `${child.name}: ${vaccineName} updated.`,
  //     "vaccination",
  //     "patient"
  //   );
  //   console.log(`Notification sent for updated vaccination: ${vaccineName}`);
  // } catch (error) {
  //   console.error(
  //     `Failed to send notification for updated vaccination: ${
  //       vaccination.vaccineInfoId?.disease || "unknown"
  //     }`,
  //     error
  //   );
  // }

  // Return response
  res.status(200).json({
    status: httpStatusText.SUCCESS,
    message: "Vaccination record and future due dates updated successfully",
    data: {
      vaccineInfoId: vaccination.vaccineInfoId._id,
      userVaccineId: vaccination._id,
      dueDate: vaccination.dueDate,
      actualDate: vaccination.actualDate,
      delayDays: vaccination.delayDays,
      status: vaccination.status,
      notes: vaccination.notes,
      image: vaccination.image,
    },
  });
});



const getUserVaccination = asyncWrapper(async (req, res, next) => {
  const { vaccinationId } = req.params;

  const vaccination = await UserVaccination.findById(vaccinationId).populate(
    "childId vaccineInfoId"
  );
  if (!vaccination) {
    return next(
      appError.create("Vaccination record not found", 404, httpStatusText.FAIL)
    );
  }
  res.status(200).json({
    status: "success",
    message: "Vaccination record and future due dates updated successfully",
    data: {
      vaccineInfoId: vaccination.vaccineInfoId._id,
      userVaccineId: vaccination._id,
      dueDate: vaccination.dueDate,
      actualDate: vaccination.actualDate,
      delayDays: vaccination.delayDays,
      status: vaccination.status,
      notes: vaccination.notes,
      image: vaccination.image,
    },
  });
});

const deleteUserVaccination = asyncWrapper(async (req, res, next) => {
  const { vaccinationId } = req.params;

  const vaccination = await UserVaccination.findById(vaccinationId);
  if (!vaccination) {
    return next(
      appError.create("Vaccination record not found", 404, httpStatusText.FAIL)
    );
  }

  if (vaccination.image && vaccination.image !== "uploads/vaccination.jpg") {
    const key = vaccination.image.split("/").pop();
    await deleteObject(key);
  }

  await UserVaccination.findByIdAndDelete(vaccinationId);

  const child = await Child.findById(vaccination.childId);
  try {
    await sendNotificationCore(
      child.parentId,
      child._id,
      null,
      "Vaccination Removed",
      `${child.name}: ${vaccination.vaccineInfoId?.name} removed.`,
      "vaccination",
      "patient"
    );
    console.log(
      `Notification sent for deleted vaccination: ${vaccination.vaccineInfoId?.name}`
    );
  } catch (error) {
    console.error(
      `Failed to send notification for deleted vaccination: ${vaccination.vaccineInfoId?.name}`,
      error
    );
  }

  res.status(200).json({
    status: "success",
    message: "Vaccination record deleted successfully",
    data: null,
  });
});

module.exports = {
  createVaccinationForAllChildren,
  getAllVaccinations,
  deleteVaccinationForAllChildren,
  getVaccinationsByChildId,
  updateUserVaccination,
  getUserVaccination,
  deleteUserVaccination,
};
