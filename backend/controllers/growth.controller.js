// const Growth = require("../models/growth.model");
// const Child = require("../models/child.model");
// const asyncWrapper = require("../middlewares/asyncWrapper");
// const httpStatusText = require("../utils/httpStatusText");
// const appError = require("../utils/appError");

// // ✅ Create a new growth record for a specific child
// const createGrowth = asyncWrapper(async (req, res, next) => {
//   const { childId } = req.params; // Extract childId from URL params
//   const userId = req.user.id; // Get userId from JWT (after authentication)
//   const { weight, height, headCircumference, date, time, notes, notesImage } =
//     req.body;

//   // Check for required fields
//   if (!weight || !height || !headCircumference || !date || !time) {
//     return next(
//       appError.create(
//         "Weight, height, head circumference, date, and time are required",
//         400,
//         httpStatusText.FAIL
//       )
//     );
//   }

//   // Verify that the child belongs to the authenticated user
//   const child = await Child.findOne({ _id: childId, parentId: userId });
//   if (!child) {
//     return next(
//       appError.create(
//         "Child not found or you are not authorized",
//         404,
//         httpStatusText.FAIL
//       )
//     );
//   }

//   const newGrowth = new Growth({
//     parentId: userId,
//     childId,
//     weight,
//     height,
//     headCircumference,
//     date,
//     time,
//     notes,
//     notesImage,
//   });

//   await newGrowth.save();
//   res.status(201).json({
//     status: httpStatusText.SUCCESS,
//     data: {
//       growth: {
//         _id: newGrowth._id,
//         parentId: newGrowth.parentId,
//         childId: newGrowth.childId,
//         weight: newGrowth.weight,
//         height: newGrowth.height,
//         headCircumference: newGrowth.headCircumference,
//         date: newGrowth.date,
//         time: newGrowth.time,
//         notes: newGrowth.notes,
//         notesImage: newGrowth.notesImage,
//         ageInMonths: newGrowth.ageInMonths,
//         createdAt: newGrowth.createdAt,
//       },
//     },
//   });
// });

// // ✅ Get all growth records for a specific child
// const getAllGrowth = asyncWrapper(async (req, res, next) => {
//   const { childId } = req.params;
//   const userId = req.user.id;

//   // Verify that the child belongs to the authenticated user
//   const child = await Child.findOne({ _id: childId, parentId: userId });
//   if (!child) {
//     return next(
//       appError.create(
//         "Child not found or you are not authorized",
//         404,
//         httpStatusText.FAIL
//       )
//     );
//   }

//   const growthRecords = await Growth.find({ childId, parentId: userId })
//     .sort({ createdAt: -1 }) // Sort from newest to oldest
//     .select(
//       "_id weight height headCircumference date time notes notesImage ageInMonths createdAt"
//     );

//   if (!growthRecords.length) {
//     return next(
//       appError.create(
//         "No growth records found for this child",
//         404,
//         httpStatusText.FAIL
//       )
//     );
//   }

//   res.json({
//     status: httpStatusText.SUCCESS,
//     data: growthRecords.map((record) => ({
//       _id: record._id,
//       weight: record.weight,
//       height: record.height,
//       headCircumference: record.headCircumference,
//       date: record.date,
//       time: record.time,
//       notes: record.notes,
//       notesImage: record.notesImage,
//       ageInMonths: record.ageInMonths,
//       createdAt: record.createdAt,
//     })),
//   });
// });

// // ✅ Get a single growth record for a specific child
// const getSingleGrowth = asyncWrapper(async (req, res, next) => {
//   const { childId, growthId } = req.params;
//   const userId = req.user.id;

//   // Verify that the child belongs to the authenticated user
//   const child = await Child.findOne({ _id: childId, parentId: userId });
//   if (!child) {
//     return next(
//       appError.create(
//         "Child not found or you are not authorized",
//         404,
//         httpStatusText.FAIL
//       )
//     );
//   }

//   const growthRecord = await Growth.findOne({
//     _id: growthId,
//     childId,
//     parentId: userId,
//   }).select(
//     "_id weight height headCircumference date time notes notesImage ageInMonths createdAt"
//   );

//   if (!growthRecord) {
//     return next(
//       appError.create("Growth record not found", 404, httpStatusText.FAIL)
//     );
//   }

//   res.json({
//     status: httpStatusText.SUCCESS,
//     data: {
//       _id: growthRecord._id,
//       weight: weightRecord.weight,
//       height: growthRecord.height,
//       headCircumference: growthRecord.headCircumference,
//       date: growthRecord.date,
//       time: growthRecord.time,
//       notes: growthRecord.notes,
//       notesImage: growthRecord.notesImage,
//       ageInMonths: growthRecord.ageInMonths,
//       createdAt: growthRecord.createdAt,
//     },
//   });
// });

// // ✅ Update a growth record
// const updateGrowth = asyncWrapper(async (req, res, next) => {
//   const { childId, growthId } = req.params;
//   const userId = req.user.id;
//   const { weight, height, headCircumference, date, time, notes, notesImage } =
//     req.body;

//   // Verify that the child belongs to the authenticated user
//   const child = await Child.findOne({ _id: childId, parentId: userId });
//   if (!child) {
//     return next(
//       appError.create(
//         "Child not found or you are not authorized",
//         404,
//         httpStatusText.FAIL
//       )
//     );
//   }

//   const updatedGrowth = await Growth.findOneAndUpdate(
//     { _id: growthId, childId, parentId: userId },
//     { weight, height, headCircumference, date, time, notes, notesImage },
//     { new: true, runValidators: true }
//   ).select(
//     "_id weight height headCircumference date time notes notesImage ageInMonths createdAt"
//   );

//   if (!updatedGrowth) {
//     return next(
//       appError.create("Growth record not found", 404, httpStatusText.FAIL)
//     );
//   }

//   res.json({
//     status: httpStatusText.SUCCESS,
//     data: {
//       _id: updatedGrowth._id,
//       weight: updatedGrowth.weight,
//       height: updatedGrowth.height,
//       headCircumference: updatedGrowth.headCircumference,
//       date: updatedGrowth.date,
//       time: updatedGrowth.time,
//       notes: updatedGrowth.notes,
//       notesImage: updatedGrowth.notesImage,
//       ageInMonths: updatedGrowth.ageInMonths,
//       createdAt: updatedGrowth.createdAt,
//     },
//   });
// });

// // ✅ Delete a growth record
// const deleteGrowth = asyncWrapper(async (req, res, next) => {
//   const { childId, growthId } = req.params;
//   const userId = req.user.id;

//   // Verify that the child belongs to the authenticated user
//   const child = await Child.findOne({ _id: childId, parentId: userId });
//   if (!child) {
//     return next(
//       appError.create(
//         "Child not found or you are not authorized",
//         404,
//         httpStatusText.FAIL
//       )
//     );
//   }

//   const deletedGrowth = await Growth.findOneAndDelete({
//     _id: growthId,
//     childId,
//     parentId: userId,
//   });

//   if (!deletedGrowth) {
//     return next(
//       appError.create("Growth record not found", 404, httpStatusText.FAIL)
//     );
//   }

//   res.json({
//     status: httpStatusText.SUCCESS,
//     message: "Growth record deleted successfully",
//   });
// });

// // ✅ Get the last growth record for a specific child
// const getLastGrowthRecord = asyncWrapper(async (req, res, next) => {
//   const { childId } = req.params;
//   const userId = req.user.id;

//   // Verify that the child belongs to the authenticated user
//   const child = await Child.findOne({ _id: childId, parentId: userId });
//   if (!child) {
//     return next(
//       appError.create(
//         "Child not found or you are not authorized",
//         404,
//         httpStatusText.FAIL
//       )
//     );
//   }

//   const lastGrowthRecord = await Growth.findOne({ childId, parentId: userId })
//     .sort({ createdAt: -1 }) // Sort by createdAt in descending order (latest first)
//     .select(
//       "_id weight height headCircumference date time notes notesImage ageInMonths createdAt"
//     );

//   if (!lastGrowthRecord) {
//     return next(
//       appError.create(
//         "No growth records found for this child",
//         404,
//         httpStatusText.FAIL
//       )
//     );
//   }

//   console.log("Last growth record:", lastGrowthRecord); // Debugging log

//   res.json({
//     status: httpStatusText.SUCCESS,
//     data: {
//       _id: lastGrowthRecord._id,
//       weight: lastGrowthRecord.weight,
//       height: lastGrowthRecord.height,
//       headCircumference: lastGrowthRecord.headCircumference,
//       date: lastGrowthRecord.date,
//       time: lastGrowthRecord.time,
//       notes: lastGrowthRecord.notes,
//       notesImage: lastGrowthRecord.notesImage,
//       ageInMonths: lastGrowthRecord.ageInMonths,
//       createdAt: lastGrowthRecord.createdAt,
//     },
//   });
// });

// // ✅ Get the change between the last two growth records for a specific child
// const getLastGrowthChange = asyncWrapper(async (req, res, next) => {
//   const { childId } = req.params;
//   const userId = req.user.id;

//   // Verify that the child belongs to the authenticated user
//   const child = await Child.findOne({ _id: childId, parentId: userId });
//   if (!child) {
//     return next(
//       appError.create(
//         "Child not found or you are not authorized",
//         404,
//         httpStatusText.FAIL
//       )
//     );
//   }

//   // Get all growth records sorted by createdAt
//   const growthRecords = await Growth.find({ childId, parentId: userId })
//     .sort({ createdAt: -1 }) // Sort by createdAt in descending order
//     .select(
//       "_id weight height headCircumference date time ageInMonths createdAt"
//     );

//   // Case 1: No growth records, use birth data as current and zeros as previous
//   if (!growthRecords.length) {
//     const birthData = {
//       weight: child.weightAtBirth,
//       height: child.heightAtBirth,
//       headCircumference: child.headCircumferenceAtBirth,
//       date: child.birthDate,
//       time: "00:00",
//       ageInMonths: 0,
//       createdAt: child.createdAt,
//     };

//     const zeroData = {
//       weight: 0,
//       height: 0,
//       headCircumference: 0,
//       date: child.birthDate, // Use birth date for consistency
//       time: "00:00",
//       ageInMonths: 0,
//       createdAt: child.createdAt,
//     };

//     const changes = {
//       weightChange: birthData.weight - zeroData.weight,
//       heightChange: birthData.height - zeroData.height,
//       headCircumferenceChange:
//         birthData.headCircumference - zeroData.headCircumference,
//       ageInMonthsDifference: birthData.ageInMonths - zeroData.ageInMonths,
//       timeIntervalDays: 0, // No time interval since it's the same date
//     };

//     console.log("No growth records, using birth data:", birthData); // Debugging log

//     return res.json({
//       status: httpStatusText.SUCCESS,
//       data: {
//         latestRecord: birthData,
//         previousRecord: zeroData,
//         changes,
//       },
//     });
//   }

//   // Case 2: One growth record, compare with birth data
//   if (growthRecords.length === 1) {
//     const latest = growthRecords[0];
//     const birthData = {
//       weight: child.weightAtBirth,
//       height: child.heightAtBirth,
//       headCircumference: child.headCircumferenceAtBirth,
//       date: child.birthDate,
//       time: "00:00",
//       ageInMonths: 0,
//       createdAt: child.createdAt,
//     };

//     const changes = {
//       weightChange: latest.weight - birthData.weight,
//       heightChange: latest.height - birthData.height,
//       headCircumferenceChange:
//         latest.headCircumference - birthData.headCircumference,
//       ageInMonthsDifference: latest.ageInMonths - birthData.ageInMonths,
//       timeIntervalDays: Math.round(
//         (new Date(latest.date) - new Date(birthData.date)) /
//           (1000 * 60 * 60 * 24)
//       ),
//     };

//     console.log("One growth record, comparing with birth data:", {
//       latest,
//       birthData,
//     }); // Debugging log

//     return res.json({
//       status: httpStatusText.SUCCESS,
//       data: {
//         latestRecord: {
//           _id: latest._id,
//           weight: latest.weight,
//           height: latest.height,
//           headCircumference: latest.headCircumference,
//           date: latest.date,
//           time: latest.time,
//           ageInMonths: latest.ageInMonths,
//           createdAt: latest.createdAt,
//         },
//         previousRecord: birthData,
//         changes,
//       },
//     });
//   }

//   // Case 3: Two or more growth records, compare the last two
//   const [latest, previous] = growthRecords;
//   const changes = {
//     weightChange: latest.weight - previous.weight,
//     heightChange: latest.height - previous.height,
//     headCircumferenceChange:
//       latest.headCircumference - previous.headCircumference,
//     ageInMonthsDifference: latest.ageInMonths - previous.ageInMonths,
//     timeIntervalDays: Math.round(
//       (new Date(latest.date) - new Date(previous.date)) / (1000 * 60 * 60 * 24)
//     ),
//   };

//   console.log("Two or more growth records, comparing:", { latest, previous }); // Debugging log

//   res.json({
//     status: httpStatusText.SUCCESS,
//     data: {
//       latestRecord: {
//         _id: latest._id,
//         weight: latest.weight,
//         height: latest.height,
//         headCircumference: latest.headCircumference,
//         date: latest.date,
//         time: latest.time,
//         ageInMonths: latest.ageInMonths,
//         createdAt: latest.createdAt,
//       },
//       previousRecord: {
//         _id: previous._id,
//         weight: previous.weight,
//         height: previous.height,
//         headCircumference: previous.headCircumference,
//         date: previous.date,
//         time: previous.time,
//         ageInMonths: previous.ageInMonths,
//         createdAt: previous.createdAt,
//       },
//       changes,
//     },
//   });
// });

// module.exports = {
//   createGrowth,
//   getAllGrowth,
//   getSingleGrowth,
//   updateGrowth,
//   deleteGrowth,
//   getLastGrowthRecord,
//   getLastGrowthChange,
// };

const Growth = require("../models/growth.model");
const Child = require("../models/child.model");
const asyncWrapper = require("../middlewares/asyncWrapper");
const httpStatusText = require("../utils/httpStatusText");
const appError = require("../utils/appError");
const { sendNotification } = require("../controllers/notifications.controller");

// ✅ Create a new growth record for a specific child
const createGrowth = asyncWrapper(async (req, res, next) => {
  const { childId } = req.params;
  const userId = req.user.id;
  const userRole = req.user.role;
  const { weight, height, headCircumference, date, time, notes, notesImage } =
    req.body;

  if (!weight || !height || !headCircumference || !date || !time) {
    return next(
      appError.create(
        "Weight, height, head circumference, date, and time are required",
        400,
        httpStatusText.FAIL
      )
    );
  }

  let childQuery = { _id: childId };
  if (userRole === "PATIENT") {
    childQuery.parentId = userId;
  }
  const child = await Child.findOne(childQuery);
  if (!child) {
    return next(
      appError.create(
        "Child not found or you are not authorized",
        404,
        httpStatusText.FAIL
      )
    );
  }

  const newGrowth = new Growth({
    parentId: userRole === "PATIENT" ? userId : child.parentId,
    childId,
    weight,
    height,
    headCircumference,
    date,
    time,
    notes,
    notesImage,
  });

  await newGrowth.save();

  // إرسال إشعار مختصر
  await sendNotification(
    child.parentId,
    childId,
    null,
    "Growth Added",
    `${child.name}: Growth record added.`,
    "growth",
    "patient" // تغيير من "user" إلى "patient"
  );

  res.status(201).json({
    status: httpStatusText.SUCCESS,
    data: {
      growth: {
        _id: newGrowth._id,
        parentId: newGrowth.parentId,
        childId: newGrowth.childId,
        weight: newGrowth.weight,
        height: newGrowth.height,
        headCircumference: newGrowth.headCircumference,
        date: newGrowth.date,
        time: newGrowth.time,
        notes: newGrowth.notes,
        notesImage: newGrowth.notesImage,
        ageInMonths: newGrowth.ageInMonths,
        createdAt: newGrowth.createdAt,
      },
    },
  });
});

// ✅ Get all growth records for a specific child
const getAllGrowth = asyncWrapper(async (req, res, next) => {
  const { childId } = req.params;
  const userId = req.user.id;
  const userRole = req.user.role;

  let childQuery = { _id: childId };
  if (userRole === "PATIENT") {
    childQuery.parentId = userId;
  }
  const child = await Child.findOne(childQuery);
  if (!child) {
    return next(
      appError.create(
        "Child not found or you are not authorized",
        404,
        httpStatusText.FAIL
      )
    );
  }

  const growthRecords = await Growth.find({ childId })
    .sort({ createdAt: -1 })
    .select(
      "_id weight height headCircumference date time notes notesImage ageInMonths createdAt"
    );

  if (!growthRecords.length) {
    return next(
      appError.create(
        "No growth records found for this child",
        404,
        httpStatusText.FAIL
      )
    );
  }

  res.json({
    status: httpStatusText.SUCCESS,
    data: growthRecords.map((record) => ({
      _id: record._id,
      weight: record.weight,
      height: record.height,
      headCircumference: record.headCircumference,
      date: record.date,
      time: record.time,
      notes: record.notes,
      notesImage: record.notesImage,
      ageInMonths: record.ageInMonths,
      createdAt: record.createdAt,
    })),
  });
});

// ✅ Get a single growth record for a specific child
const getSingleGrowth = asyncWrapper(async (req, res, next) => {
  const { childId, growthId } = req.params;
  const userId = req.user.id;
  const userRole = req.user.role;

  let childQuery = { _id: childId };
  if (userRole === "PATIENT") {
    childQuery.parentId = userId;
  }
  const child = await Child.findOne(childQuery);
  if (!child) {
    return next(
      appError.create(
        "Child not found or you are not authorized",
        404,
        httpStatusText.FAIL
      )
    );
  }

  const growthRecord = await Growth.findOne({ _id: growthId, childId }).select(
    "_id weight height headCircumference date time notes notesImage ageInMonths createdAt"
  );

  if (!growthRecord) {
    return next(
      appError.create("Growth record not found", 404, httpStatusText.FAIL)
    );
  }

  res.json({
    status: httpStatusText.SUCCESS,
    data: {
      _id: growthRecord._id,
      weight: growthRecord.weight,
      height: growthRecord.height,
      headCircumference: growthRecord.headCircumference,
      date: growthRecord.date,
      time: growthRecord.time,
      notes: growthRecord.notes,
      notesImage: growthRecord.notesImage,
      ageInMonths: growthRecord.ageInMonths,
      createdAt: growthRecord.createdAt,
    },
  });
});

// ✅ Update a growth record
const updateGrowth = asyncWrapper(async (req, res, next) => {
  const { childId, growthId } = req.params;
  const userId = req.user.id;
  const userRole = req.user.role;
  const { weight, height, headCircumference, date, time, notes, notesImage } =
    req.body;

  let childQuery = { _id: childId };
  if (userRole === "PATIENT") {
    childQuery.parentId = userId;
  }
  const child = await Child.findOne(childQuery);
  if (!child) {
    return next(
      appError.create(
        "Child not found or you are not authorized",
        404,
        httpStatusText.FAIL
      )
    );
  }

  const updatedGrowth = await Growth.findOneAndUpdate(
    { _id: growthId, childId },
    { weight, height, headCircumference, date, time, notes, notesImage },
    { new: true, runValidators: true }
  ).select(
    "_id weight height headCircumference date time notes notesImage ageInMonths createdAt"
  );

  if (!updatedGrowth) {
    return next(
      appError.create("Growth record not found", 404, httpStatusText.FAIL)
    );
  }

  // إرسال إشعار مختصر
  await sendNotification(
    child.parentId,
    childId,
    null,
    "Growth Updated",
    `${child.name}: Growth record updated.`,
    "growth",
    "patient" // تغيير من "user" إلى "patient"
  );

  res.json({
    status: httpStatusText.SUCCESS,
    data: {
      _id: updatedGrowth._id,
      weight: updatedGrowth.weight,
      height: updatedGrowth.height,
      headCircumference: updatedGrowth.headCircumference,
      date: updatedGrowth.date,
      time: updatedGrowth.time,
      notes: updatedGrowth.notes,
      notesImage: updatedGrowth.notesImage,
      ageInMonths: updatedGrowth.ageInMonths,
      createdAt: updatedGrowth.createdAt,
    },
  });
});

// ✅ Delete a growth record
const deleteGrowth = asyncWrapper(async (req, res, next) => {
  const { childId, growthId } = req.params;
  const userId = req.user.id;
  const userRole = req.user.role;

  let childQuery = { _id: childId };
  if (userRole === "PATIENT") {
    childQuery.parentId = userId;
  }
  const child = await Child.findOne(childQuery);
  if (!child) {
    return next(
      appError.create(
        "Child not found or you are not authorized",
        404,
        httpStatusText.FAIL
      )
    );
  }

  const deletedGrowth = await Growth.findOneAndDelete({
    _id: growthId,
    childId,
  });

  if (!deletedGrowth) {
    return next(
      appError.create("Growth record not found", 404, httpStatusText.FAIL)
    );
  }

  // إرسال إشعار مختصر
  await sendNotification(
    child.parentId,
    childId,
    null,
    "Growth Removed",
    `${child.name}: Growth record removed.`,
    "growth",
    "patient" // تغيير من "user" إلى "patient"
  );

  res.json({
    status: httpStatusText.SUCCESS,
    message: "Growth record deleted successfully",
  });
});

// ✅ Get the last growth record for a specific child
const getLastGrowthRecord = asyncWrapper(async (req, res, next) => {
  const { childId } = req.params;
  const userId = req.user.id;
  const userRole = req.user.role;

  let childQuery = { _id: childId };
  if (userRole === "PATIENT") {
    childQuery.parentId = userId;
  }
  const child = await Child.findOne(childQuery);
  if (!child) {
    return next(
      appError.create(
        "Child not found or you are not authorized",
        404,
        httpStatusText.FAIL
      )
    );
  }

  const lastGrowthRecord = await Growth.findOne({ childId })
    .sort({ createdAt: -1 })
    .select(
      "_id weight height headCircumference date time notes notesImage ageInMonths createdAt"
    );

  if (!lastGrowthRecord) {
    return next(
      appError.create(
        "No growth records found for this child",
        404,
        httpStatusText.FAIL
      )
    );
  }

  res.json({
    status: httpStatusText.SUCCESS,
    data: {
      _id: lastGrowthRecord._id,
      weight: lastGrowthRecord.weight,
      height: lastGrowthRecord.height,
      headCircumference: lastGrowthRecord.headCircumference,
      date: lastGrowthRecord.date,
      time: lastGrowthRecord.time,
      notes: lastGrowthRecord.notes,
      notesImage: lastGrowthRecord.notesImage,
      ageInMonths: lastGrowthRecord.ageInMonths,
      createdAt: lastGrowthRecord.createdAt,
    },
  });
});

// ✅ Get the change between the last two growth records for a specific child
const getLastGrowthChange = asyncWrapper(async (req, res, next) => {
  const { childId } = req.params;
  const userId = req.user.id;
  const userRole = req.user.role;

  let childQuery = { _id: childId };
  if (userRole === "PATIENT") {
    childQuery.parentId = userId;
  }
  const child = await Child.findOne(childQuery);
  if (!child) {
    return next(
      appError.create(
        "Child not found or you are not authorized",
        404,
        httpStatusText.FAIL
      )
    );
  }

  const growthRecords = await Growth.find({ childId })
    .sort({ createdAt: -1 })
    .select(
      "_id weight height headCircumference date time ageInMonths createdAt"
    );

  if (!growthRecords.length) {
    const birthData = {
      weight: child.weightAtBirth,
      height: child.heightAtBirth,
      headCircumference: child.headCircumferenceAtBirth,
      date: child.birthDate,
      time: "00:00",
      ageInMonths: 0,
      createdAt: child.createdAt,
    };

    const zeroData = {
      weight: 0,
      height: 0,
      headCircumference: 0,
      date: child.birthDate,
      time: "00:00",
      ageInMonths: 0,
      createdAt: child.createdAt,
    };

    const changes = {
      weightChange: birthData.weight - zeroData.weight,
      heightChange: birthData.height - zeroData.height,
      headCircumferenceChange:
        birthData.headCircumference - zeroData.headCircumference,
      ageInMonthsDifference: birthData.ageInMonths - zeroData.ageInMonths,
      timeIntervalDays: 0,
    };

    return res.json({
      status: httpStatusText.SUCCESS,
      data: {
        latestRecord: birthData,
        previousRecord: zeroData,
        changes,
      },
    });
  }

  if (growthRecords.length === 1) {
    const latest = growthRecords[0];
    const birthData = {
      weight: child.weightAtBirth,
      height: child.heightAtBirth,
      headCircumference: child.headCircumferenceAtBirth,
      date: child.birthDate,
      time: "00:00",
      ageInMonths: 0,
      createdAt: child.createdAt,
    };

    const changes = {
      weightChange: latest.weight - birthData.weight,
      heightChange: latest.height - birthData.height,
      headCircumferenceChange:
        latest.headCircumference - birthData.headCircumference,
      ageInMonthsDifference: latest.ageInMonths - birthData.ageInMonths,
      timeIntervalDays: Math.round(
        (new Date(latest.date) - new Date(birthData.date)) /
          (1000 * 60 * 60 * 24)
      ),
    };

    return res.json({
      status: httpStatusText.SUCCESS,
      data: {
        latestRecord: {
          _id: latest._id,
          weight: latest.weight,
          height: latest.height,
          headCircumference: latest.headCircumference,
          date: latest.date,
          time: latest.time,
          ageInMonths: latest.ageInMonths,
          createdAt: latest.createdAt,
        },
        previousRecord: birthData,
        changes,
      },
    });
  }

  const [latest, previous] = growthRecords;
  const changes = {
    weightChange: latest.weight - previous.weight,
    heightChange: latest.height - previous.height,
    headCircumferenceChange:
      latest.headCircumference - previous.headCircumference,
    ageInMonthsDifference: latest.ageInMonths - previous.ageInMonths,
    timeIntervalDays: Math.round(
      (new Date(latest.date) - new Date(previous.date)) / (1000 * 60 * 60 * 24)
    ),
  };

  res.json({
    status: httpStatusText.SUCCESS,
    data: {
      latestRecord: {
        _id: latest._id,
        weight: latest.weight,
        height: latest.height,
        headCircumference: latest.headCircumference,
        date: latest.date,
        time: latest.time,
        ageInMonths: latest.ageInMonths,
        createdAt: latest.createdAt,
      },
      previousRecord: {
        _id: previous._id,
        weight: previous.weight,
        height: previous.height,
        headCircumference: previous.headCircumference,
        date: previous.date,
        time: previous.time,
        ageInMonths: previous.ageInMonths,
        createdAt: previous.createdAt,
      },
      changes,
    },
  });
});

module.exports = {
  createGrowth,
  getAllGrowth,
  getSingleGrowth,
  updateGrowth,
  deleteGrowth,
  getLastGrowthRecord,
  getLastGrowthChange,
};