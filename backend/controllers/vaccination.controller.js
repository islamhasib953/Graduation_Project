// const UserVaccination = require("../models/UserVaccination.model");
// const Child = require("../models/child.model");
// const VaccineInfo = require("../models/vaccineInfo.model");
// const asyncWrapper = require("../middlewares/asyncWrapper");
// const httpStatusText = require("../utils/httpStatusText");
// const appError = require("../utils/appError");
// const {
//   sendNotificationCore,
// } = require("../controllers/notifications.controller");

// // ✅ Get all vaccinations
// const getAllVaccinations = asyncWrapper(async (req, res, next) => {
//   const vaccinations = await UserVaccination.find()
//     .populate("childId", "name birthDate gender")
//     .populate("vaccineInfoId");

//   if (!vaccinations.length) {
//     return next(
//       appError.create("No vaccinations found", 404, httpStatusText.FAIL)
//     );
//   }

//   res.status(200).json({ status: httpStatusText.SUCCESS, data: vaccinations });
// });

// const createVaccinationForAllChildren = asyncWrapper(async (req, res, next) => {
//   let vaccines = req.body;

//   // تحويل كائن واحد إلى array لو مش array
//   if (!Array.isArray(vaccines)) {
//     vaccines = [vaccines];
//   }

//   // التحقق إن الـ vaccines مش فاضي
//   if (vaccines.length === 0) {
//     return next(
//       appError.create(
//         "At least one vaccine is required",
//         400,
//         httpStatusText.FAIL
//       )
//     );
//   }

//   const createdVaccines = [];
//   const errors = [];

//   // لوب على كل تطعيم
//   for (const vaccine of vaccines) {
//     const {
//       disease,
//       originalSchedule,
//       ageVaccine,
//       doseName,
//       dosageAmount,
//       administrationMethod,
//       description,
//     } = vaccine;

//     // التحقق من الحقول المطلوبة
//     if (!disease || originalSchedule === undefined) {
//       errors.push(
//         `Missing required fields for vaccine: ${disease || "unknown"}`
//       );
//       continue;
//     }

//     // التحقق إن التطعيم مش موجود بالفعل
//     const existingVaccine = await VaccineInfo.findOne({ disease, doseName });
//     if (existingVaccine) {
//       errors.push(
//         `Vaccine already exists: ${disease} (${doseName || "unknown"})`
//       );
//       continue;
//     }

//     // إنشاء تطعيم جديد مع كل الحقول
//     const newVaccine = new VaccineInfo({
//       disease,
//       originalSchedule,
//       ageVaccine,
//       doseName,
//       dosageAmount,
//       administrationMethod,
//       description,
//     });

//     await newVaccine.save();
//     createdVaccines.push(newVaccine);

//     // جلب كل الأطفال
//     const children = await Child.find();
//     const vaccinationsToCreate = children.map((child) => ({
//       childId: child._id,
//       vaccineInfoId: newVaccine._id,
//       dueDate: new Date(
//         new Date(child.birthDate).setMonth(
//           new Date(child.birthDate).getMonth() + originalSchedule
//         )
//       ),
//     }));

//     // إضافة التطعيمات للأطفال
//     await UserVaccination.insertMany(vaccinationsToCreate);

//     // إرسال إشعارات لكل طفل
//     for (const child of children) {
//       try {
//         await sendNotificationCore(
//           child.parentId,
//           child._id,
//           null,
//           "Vaccination Added",
//           `${child.name}: ${newVaccine.disease} (${
//             newVaccine.doseName || "unknown"
//           }) scheduled for ${new Date(
//             new Date(child.birthDate).setMonth(
//               new Date(child.birthDate).getMonth() + originalSchedule
//             )
//           ).toLocaleDateString()}.`,
//           "vaccination",
//           "patient"
//         );
//         console.log(
//           `Notification sent for new vaccination: ${newVaccine.disease} for child: ${child.name}`
//         );
//       } catch (error) {
//         console.error(
//           `Failed to send notification for new vaccination: ${newVaccine.disease} for child: ${child.name}`,
//           error
//         );
//       }
//     }
//   }

//   // إرجاع الاستجابة
//   if (createdVaccines.length === 0) {
//     return next(
//       appError.create(
//         `No vaccines were created. Errors: ${errors.join(", ")}`,
//         400,
//         httpStatusText.FAIL
//       )
//     );
//   }

//   res.status(201).json({
//     status: httpStatusText.SUCCESS,
//     data: { vaccines: createdVaccines },
//     errors: errors.length > 0 ? errors : undefined,
//   });
// });

// const deleteVaccinationForAllChildren = asyncWrapper(async (req, res, next) => {
//   const { vaccinationId } = req.params;

//   const vaccine = await VaccineInfo.findById(vaccinationId);
//   if (!vaccine) {
//     return next(appError.create("Vaccine not found", 404, httpStatusText.FAIL));
//   }

//   await VaccineInfo.findByIdAndDelete(vaccinationId);
//   await UserVaccination.deleteMany({ vaccineInfoId: vaccinationId });

//   res.json({
//     status: httpStatusText.SUCCESS,
//     message: "Vaccination deleted successfully",
//   });
// });

// const getSingleUserVaccination = asyncWrapper(async (req, res, next) => {
//   const { childId, vaccinationId } = req.params;

//   const child = await Child.findById(childId);
//   if (!child) {
//     return next(appError.create("Child not found", 404, httpStatusText.FAIL));
//   }

//   const vaccination = await UserVaccination.findOne({
//     _id: vaccinationId,
//     childId,
//   })
//     .populate("vaccineInfoId", "disease originalSchedule")
//     .select("dueDate status image");

//   if (!vaccination) {
//     return next(
//       appError.create("Vaccination not found", 404, httpStatusText.FAIL)
//     );
//   }

//   res.json({
//     status: httpStatusText.SUCCESS,
//     data: vaccination,
//   });
// });

// const updateUserVaccination = asyncWrapper(async (req, res, next) => {
//   const { childId, vaccinationId } = req.params;
//   const userId = req.user.id;
//   const userRole = req.user.role;
//   const { actualDate, actualTime, status, notes, image } = req.body;

//   const child = await Child.findById(childId);
//   if (!child) {
//     return next(appError.create("Child not found", 404, httpStatusText.FAIL));
//   }

//   const vaccination = await UserVaccination.findOne({
//     _id: vaccinationId,
//     childId,
//   });
//   if (!vaccination) {
//     return next(
//       appError.create("Vaccination not found", 404, httpStatusText.FAIL)
//     );
//   }

//   const changes = [];
//   if (status && status !== vaccination.status) {
//     changes.push(`status to ${status}`);
//     vaccination.status = status;
//   }
//   if (
//     actualDate &&
//     (!vaccination.actualDate ||
//       actualDate !== vaccination.actualDate.toISOString().split("T")[0])
//   ) {
//     changes.push(`actual date to ${actualDate}`);
//     const newActualDate = new Date(actualDate);
//     newActualDate.setHours(0, 0, 0, 0);
//     vaccination.actualDate = newActualDate;
//   }
//   if (actualTime) {
//     changes.push(`actual time to ${actualTime}`);
//     if (vaccination.actualDate) {
//       const [hours, minutes] = actualTime.split(":");
//       vaccination.actualDate.setHours(parseInt(hours), parseInt(minutes));
//     }
//   }
//   if (notes && notes !== vaccination.notes) {
//     changes.push(`notes to ${notes}`);
//     vaccination.notes = notes;
//   }
//   if (image && image !== vaccination.image) {
//     changes.push(`image to ${image}`);
//     vaccination.image = image;
//   }
//   if (req.file) {
//     changes.push(`image updated`);
//     vaccination.image = `/uploads/${req.file.filename}`;
//   }

//   await vaccination.save();

//   // تحديث التطعيمات المستقبلية هنا
//   if (vaccination.delayDays > 0) {
//     const futureVaccinations = await UserVaccination.find({
//       childId: vaccination.childId,
//       dueDate: { $gt: vaccination.dueDate },
//       status: "Pending",
//     });

//     console.log(
//       `📌 Found ${futureVaccinations.length} future vaccinations for child ${vaccination.childId}`
//     );

//     const updates = futureVaccinations.map((v) => ({
//       updateOne: {
//         filter: { _id: v._id },
//         update: {
//           $inc: { dueDate: vaccination.delayDays * 24 * 60 * 60 * 1000 }, // زيادة الـ dueDate بالميلي ثانية
//           $inc: { delayDays: vaccination.delayDays },
//         },
//       },
//     }));

//     if (updates.length > 0) {
//       await UserVaccination.bulkWrite(updates);
//       for (let v of futureVaccinations) {
//         const oldDueDate = new Date(v.dueDate);
//         v.dueDate = new Date(
//           v.dueDate.getTime() + vaccination.delayDays * 24 * 60 * 60 * 1000
//         );
//         console.log(
//           `📌 Updated vaccination ${
//             v._id
//           }: dueDate from ${oldDueDate.toISOString()} to ${v.dueDate.toISOString()}`
//         );
//       }
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

//   res.json({
//     status: httpStatusText.SUCCESS,
//     data: {
//       _id: vaccination._id,
//       childId: vaccination.childId,
//       vaccineInfoId: vaccination.vaccineInfoId,
//       dueDate: vaccination.dueDate,
//       status: vaccination.status,
//       actualDate: vaccination.actualDate,
//       delayDays: vaccination.delayDays,
//       notes: vaccination.notes,
//       image: vaccination.image,
//       createdAt: vaccination.createdAt,
//       updatedAt: vaccination.updatedAt,
//     },
//   });
// });

// const deleteUserVaccination = asyncWrapper(async (req, res, next) => {
//     const { childId, vaccinationId } = req.params;
//     const userId = req.user.id;

//     const child = await Child.findById(childId);
//     if (!child) {
//       return next(appError.create("Child not found", 404, httpStatusText.FAIL));
//     }

//     const vaccination = await UserVaccination.findOne({
//       _id: vaccinationId,
//       childId,
//     });
//     if (!vaccination) {
//       return next(
//         appError.create("Vaccination not found", 404, httpStatusText.FAIL)
//       );
//     }

//     await UserVaccination.deleteOne({ _id: vaccinationId });

//   try {
//     await sendNotificationCore(
//       child.parentId,
//       childId,
//       null,
//       "Vaccination Removed",
//       `${child.name}: ${deletedVaccination.vaccineInfoId?.name} removed.`,
//       "vaccination",
//       "patient"
//     );
//     console.log(
//       `Notification sent for deleted vaccination: ${deletedVaccination.vaccineInfoId?.name}`
//     );
//   } catch (error) {
//     console.error(
//       `Failed to send notification for deleted vaccination: ${deletedVaccination.vaccineInfoId?.name}`,
//       error
//     );
//   }

//   res.json({
//     status: httpStatusText.SUCCESS,
//     message: "Vaccination deleted successfully",
//   });
// });

// const getVaccinationsByChildId = asyncWrapper(async (req, res, next) => {
//   const { childId } = req.params;

//   const child = await Child.findById(childId);
//   if (!child) {
//     return next(appError.create("Child not found", 404, httpStatusText.FAIL));
//   }

//   const vaccinations = await UserVaccination.find({ childId })
//     .populate("vaccineInfoId", "disease originalSchedule")
//     .select("dueDate status image");

//   res.json({
//     status: httpStatusText.SUCCESS,
//     data: vaccinations,
//   });
// });

// module.exports = {
//   createVaccinationForAllChildren, //admin==
//   getAllVaccinations, //admin==
//   deleteVaccinationForAllChildren, //admin==
//   getVaccinationsByChildId, //user==
//   getSingleUserVaccination, //user==
//   updateUserVaccination, //user==
//   deleteUserVaccination, //user==
// };

//****************************************** */

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

// ✅ Admin creates a new vaccine and assigns it to all children
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
  // إضافة إشعارات لكل طفل
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

// ✅ Get all vaccinations
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

// ✅ Admin deletes a vaccination for all children
const deleteVaccinationForAllChildren = asyncWrapper(async (req, res, next) => {
  const { vaccinationId } = req.params;

  // Check if the vaccine exists
  const vaccine = await VaccineInfo.findById(vaccinationId);
  if (!vaccine) {
    return next(appError.create("Vaccine not found", 404, httpStatusText.FAIL));
  }

  // Delete all user vaccinations associated with this vaccine
  const deletedVaccinations = await UserVaccination.deleteMany({
    vaccineInfoId: vaccinationId,
  });

  // Delete the vaccine itself
  await VaccineInfo.findByIdAndDelete(vaccinationId);

  res.status(200).json({
    status: "success",
    message: "Vaccine and all associated records deleted successfully",
    deletedVaccinationsCount: deletedVaccinations.deletedCount,
  });
});

// ✅ Get all vaccinations for a specific child using childId
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
    })),
  });
});

// ✅ updates a vaccination record
const updateUserVaccination = asyncWrapper(async (req, res, next) => {
  const { childId, vaccinationId } = req.params;
  const { actualDate, status, notes, image } = req.body;

  if (!actualDate || !status) {
    return next(
      appError.create(
        "Vaccination details are required",
        400,
        httpStatusText.FAIL
      )
    );
  }

  const vaccination = await UserVaccination.findOne({
    _id: vaccinationId,
    childId,
  }).populate("vaccineInfoId"); // ✅ Populate vaccine details

  if (!vaccination) {
    return next(
      appError.create("Vaccination record not found", 404, httpStatusText.FAIL)
    );
  }

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
  const dueDate = new Date(child.birthDate);
  dueDate.setMonth(
    dueDate.getMonth() + vaccination.vaccineInfoId.originalSchedule
  );
  // let calcduedate = new Date(child.birthDate);
  const delayDays = Math.max(
    0,
    Math.floor(
      (new Date(actualDate) - new Date(dueDate)) / (1000 * 60 * 60 * 24)
    )
  );

  // إضافة التحقق من التاريخ
  const currentDate = new Date();
  currentDate.setHours(0, 0, 0, 0); // ضبط الوقت لـ 00:00:00 عشان مقارنة اليوم فقط
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

  // الجزء الموجود من قبل
  vaccination.actualDate = new Date(actualDate);
  vaccination.delayDays = delayDays;
  vaccination.status = status;
  vaccination.notes = notes;
  vaccination.image = image || vaccination.image;
  await vaccination.save();

  const futureVaccinations = await UserVaccination.find({
    childId,
    dueDate: { $gt: vaccination.dueDate },
  })
    .populate("vaccineInfoId")
    .sort("dueDate");

  if (futureVaccinations.length > 0) {
    let accumulatedDelay = delayDays > 0 ? delayDays : 0;
    for (let future of futureVaccinations) {
      let dueDate = new Date(child.birthDate);
      dueDate.setMonth(
        dueDate.getMonth() + future.vaccineInfoId.originalSchedule
      );
      let newDueDate = new Date(dueDate);
      let lastnewdate = dueDate.setDate(
        newDueDate.getDate() + accumulatedDelay
      );
      let storeDueDate = new Date(lastnewdate);

      await UserVaccination.updateOne(
        { _id: future._id },
        {
          $set: {
            dueDate: storeDueDate,
            delayDays: accumulatedDelay,
          },
        }
      );

      accumulatedDelay = delayDays;
    }
  }

  // إضافة إشعار تحديث التطعيم
  try {
    const vaccineName = vaccination.vaccineInfoId?.name || "unknown";
    await sendNotificationCore(
      child.parentId,
      childId,
      null,
      "Vaccination Updated",
      `${child.name}: ${vaccineName} updated.`,
      "vaccination",
      "patient"
    );
    console.log(`Notification sent for updated vaccination: ${vaccineName}`);
  } catch (error) {
    console.error(
      `Failed to send notification for updated vaccination: ${
        vaccination.vaccineInfoId?.name || "unknown"
      }`,
      error
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

// ✅ Get a specific user vaccination record
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

// ✅ Delete a specific user vaccination record
const deleteUserVaccination = asyncWrapper(async (req, res, next) => {
  const { vaccinationId } = req.params;

  // Find the vaccination record
  const vaccination = await UserVaccination.findById(vaccinationId);
  if (!vaccination) {
    return next(
      appError.create("Vaccination record not found", 404, httpStatusText.FAIL)
    );
  }

  // Delete the vaccination record
  await UserVaccination.findByIdAndDelete(vaccinationId);

  // إضافة إشعار حذف التطعيم
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
