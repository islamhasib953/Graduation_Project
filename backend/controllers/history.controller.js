// const History = require("../models/history.model");
// const asyncWrapper = require("../middlewares/asyncWrapper");
// const httpStatusText = require("../utils/httpStatusText");
// const appError = require("../utils/appError");

// // ✅ Create a new history record
// const createHistory = asyncWrapper(async (req, res, next) => {
//   const { childId } = req.params; // Extract childId from URL params
//   const {
//     diagnosis,
//     disease,
//     treatment,
//     notes,
//     date,
//     time,
//     notesImage,
//     doctorName,
//   } = req.body; // أضفنا doctorName هنا

//   if (!diagnosis || !disease || !treatment || !date || !time) {
//     return next(
//       appError.create(
//         "All required fields must be provided",
//         400,
//         httpStatusText.FAIL
//       )
//     );
//   }

//   const newHistory = new History({
//     childId,
//     diagnosis,
//     disease,
//     treatment,
//     notes,
//     date,
//     time,
//     doctorName: doctorName || undefined, // لو ما بعتيش doctorName، هياخد القيمة الافتراضية من الـ Schema
//     notesImage: notesImage || null,
//   });

//   await newHistory.save();

//   // مكان التعديل: أضفنا doctorName في الـ Response
//   res.json({
//     status: httpStatusText.SUCCESS,
//     data: {
//       _id: newHistory._id,
//       diagnosis: newHistory.diagnosis,
//       disease: newHistory.disease,
//       treatment: newHistory.treatment,
//       notes: newHistory.notes,
//       notesImage: newHistory.notesImage,
//       date: newHistory.date,
//       time: newHistory.time,
//       doctorName: newHistory.doctorName, // أضفنا doctorName هنا
//     },
//   });
// });

// // ✅ Get all history records for a specific child
// const getAllHistory = asyncWrapper(async (req, res, next) => {
//   const { childId } = req.params;

//   // مكان التعديل: أضفنا doctorName في الـ select
//   const history = await History.find({ childId }).select(
//     "diagnosis disease treatment date childId notes notesImage time doctorName" // أضفنا doctorName هنا
//   );

//   if (!history.length) {
//     return next(
//       appError.create(
//         "No history records found for this child",
//         404,
//         httpStatusText.FAIL
//       )
//     );
//   }

//   // مكان التعديل: أضفنا doctorName في الـ Response
//   res.json({
//     status: httpStatusText.SUCCESS,
//     data: history.map((record) => ({
//       _id: record._id,
//       diagnosis: record.diagnosis,
//       disease: record.disease,
//       treatment: record.treatment,
//       notes: record.notes,
//       date: record.date,
//       time: record.time,
//       notesImage: record.notesImage, // عدلنا notesImage بدل notes
//       doctorName: record.doctorName, // أضفنا doctorName هنا
//     })),
//   });
// });

// // ✅ Get a single history record for a specific child
// const getSingleHistory = asyncWrapper(async (req, res, next) => {
//   const { childId, historyId } = req.params;

//   // مكان التعديل: أضفنا doctorName في الـ select
//   const history = await History.findOne({ _id: historyId, childId }).select(
//     "_id diagnosis disease treatment notes notesImage date time doctorName" // أضفنا doctorName هنا
//   );

//   if (!history) {
//     return next(
//       appError.create("History record not found", 404, httpStatusText.FAIL)
//     );
//   }

//   // مكان التعديل: أضفنا doctorName في الـ Response
//   res.json({
//     status: httpStatusText.SUCCESS,
//     data: {
//       _id: history._id,
//       diagnosis: history.diagnosis,
//       disease: history.disease,
//       treatment: history.treatment,
//       notes: history.notes,
//       notesImage: history.notesImage,
//       date: history.date,
//       time: history.time,
//       doctorName: history.doctorName, // أضفنا doctorName هنا
//     },
//   });
// });

// // ✅ Update a history record
// const updateHistory = asyncWrapper(async (req, res, next) => {
//   const { childId, historyId } = req.params;
//   const {
//     diagnosis,
//     disease,
//     treatment,
//     notes,
//     date,
//     time,
//     notesImage,
//     doctorName,
//   } = req.body; // أضفنا doctorName هنا

//   // مكان التعديل: أضفنا doctorName في الـ Update
//   const updatedHistory = await History.findOneAndUpdate(
//     { _id: historyId, childId },
//     {
//       diagnosis,
//       disease,
//       treatment,
//       notes,
//       date,
//       time,
//       notesImage,
//       doctorName,
//     }, // أضفنا doctorName هنا
//     { new: true, runValidators: true }
//   );

//   if (!updatedHistory) {
//     return next(
//       appError.create("History record not found", 404, httpStatusText.FAIL)
//     );
//   }

//   // مكان التعديل: أضفنا doctorName في الـ Response
//   res.json({
//     status: httpStatusText.SUCCESS,
//     data: {
//       history: {
//         _id: updatedHistory._id,
//         diagnosis: updatedHistory.diagnosis,
//         disease: updatedHistory.disease,
//         treatment: updatedHistory.treatment,
//         notes: updatedHistory.notes,
//         notesImage: updatedHistory.notesImage,
//         date: updatedHistory.date,
//         time: updatedHistory.time,
//         doctorName: updatedHistory.doctorName, // أضفنا doctorName هنا
//       },
//     },
//   });
// });

// // ✅ Delete a history record
// const deleteHistory = asyncWrapper(async (req, res, next) => {
//   const { childId, historyId } = req.params;

//   const deletedHistory = await History.findOneAndDelete({
//     _id: historyId,
//     childId,
//   });

//   if (!deletedHistory) {
//     return next(
//       appError.create("History record not found", 404, httpStatusText.FAIL)
//     );
//   }

//   res.json({
//     status: httpStatusText.SUCCESS,
//     message: "History record deleted successfully",
//   });
// });

// // ✅ Filter history records using query parameters
// const filterHistory = asyncWrapper(async (req, res, next) => {
//   const { childId } = req.params;
//   const { diagnosis, disease, treatment, fromDate, toDate, sortBy } = req.query;

//   let query = { childId };

//   if (diagnosis) {
//     query.diagnosis = { $regex: diagnosis, $options: "i" };
//   }

//   if (disease) {
//     query.disease = { $regex: disease, $options: "i" };
//   }

//   if (treatment) {
//     query.treatment = { $regex: treatment, $options: "i" };
//   }

//   if (fromDate && toDate) {
//     query.date = { $gte: new Date(fromDate), $lte: new Date(toDate) };
//   }

//   let sortOption = { date: -1 };
//   if (sortBy === "oldest") {
//     sortOption = { date: 1 };
//   }

//   // مكان التعديل: أضفنا doctorName في الـ select
//   const history = await History.find(query)
//     .sort(sortOption)
//     .select("_id diagnosis disease treatment date doctorName"); // أضفنا doctorName هنا

//   if (!history.length) {
//     return next(
//       appError.create("No history records found", 404, httpStatusText.FAIL)
//     );
//   }

//   // مكان التعديل: أضفنا doctorName في الـ Response
//   res.json({
//     status: httpStatusText.SUCCESS,
//     data: history.map((record) => ({
//       _id: record._id,
//       diagnosis: record.diagnosis,
//       disease: record.disease,
//       treatment: record.treatment,
//       date: record.date,
//       doctorName: record.doctorName, // أضفنا doctorName هنا
//     })),
//   });
// });

// module.exports = {
//   createHistory,
//   getAllHistory,
//   getSingleHistory,
//   updateHistory,
//   deleteHistory,
//   filterHistory,
// };

const History = require("../models/history.model");
const Child = require("../models/child.model");
const asyncWrapper = require("../middlewares/asyncWrapper");
const httpStatusText = require("../utils/httpStatusText");
const appError = require("../utils/appError");
const { sendNotification } = require("../controllers/notifications.controller");

// ✅ Create a new history record
const createHistory = asyncWrapper(async (req, res, next) => {
  const { childId } = req.params;
  const userId = req.user?.id; // جعل userId اختياريًا
  const {
    diagnosis,
    disease,
    treatment,
    notes,
    date,
    time,
    notesImage,
    doctorName,
  } = req.body;

  if (!diagnosis || !disease || !treatment || !date || !time) {
    return next(
      appError.create(
        "All required fields must be provided",
        400,
        httpStatusText.FAIL
      )
    );
  }

  // التحقق من وجود الطفل فقط (بدون التحقق من parentId)
  const child = await Child.findById(childId);
  if (!child) {
    return next(appError.create("Child not found", 404, httpStatusText.FAIL));
  }

  const newHistory = new History({
    childId,
    diagnosis,
    disease,
    treatment,
    notes,
    date,
    time,
    doctorName: doctorName || undefined,
    notesImage: notesImage || null,
  });

  await newHistory.save();

  // إرسال الإشعار فقط إذا كان userId موجودًا
  if (userId) {
    await sendNotification(
      userId,
      childId,
      null,
      "History Added",
      `${child.name}: ${disease} added.`,
      "history",
      "patient"
    );
  }

  res.json({
    status: httpStatusText.SUCCESS,
    data: {
      _id: newHistory._id,
      diagnosis: newHistory.diagnosis,
      disease: newHistory.disease,
      treatment: newHistory.treatment,
      notes: newHistory.notes,
      notesImage: newHistory.notesImage,
      date: newHistory.date,
      time: newHistory.time,
      doctorName: newHistory.doctorName,
    },
  });
});

// ✅ Get all history records for a specific child
const getAllHistory = asyncWrapper(async (req, res, next) => {
  const { childId } = req.params;

  // التحقق من وجود الطفل فقط (بدون التحقق من parentId)
  const child = await Child.findById(childId);
  if (!child) {
    return next(appError.create("Child not found", 404, httpStatusText.FAIL));
  }

  const history = await History.find({ childId }).select(
    "diagnosis disease treatment date childId notes notesImage time doctorName"
  );

  if (!history.length) {
    return next(
      appError.create(
        "No history records found for this child",
        404,
        httpStatusText.FAIL
      )
    );
  }

  res.json({
    status: httpStatusText.SUCCESS,
    data: history.map((record) => ({
      _id: record._id,
      diagnosis: record.diagnosis,
      disease: record.disease,
      treatment: record.treatment,
      notes: record.notes,
      date: record.date,
      time: record.time,
      notesImage: record.notesImage,
      doctorName: record.doctorName,
    })),
  });
});

// ✅ Get a single history record for a specific child
const getSingleHistory = asyncWrapper(async (req, res, next) => {
  const { childId, historyId } = req.params;

  // التحقق من وجود الطفل فقط (بدون التحقق من parentId)
  const child = await Child.findById(childId);
  if (!child) {
    return next(appError.create("Child not found", 404, httpStatusText.FAIL));
  }

  const history = await History.findOne({ _id: historyId, childId }).select(
    "_id diagnosis disease treatment notes notesImage date time doctorName"
  );

  if (!history) {
    return next(
      appError.create("History record not found", 404, httpStatusText.FAIL)
    );
  }

  res.json({
    status: httpStatusText.SUCCESS,
    data: {
      _id: history._id,
      diagnosis: history.diagnosis,
      disease: history.disease,
      treatment: history.treatment,
      notes: history.notes,
      notesImage: history.notesImage,
      date: history.date,
      time: history.time,
      doctorName: history.doctorName,
    },
  });
});

// ✅ Update a history record
const updateHistory = asyncWrapper(async (req, res, next) => {
  const { childId, historyId } = req.params;
  const userId = req.user?.id; // جعل userId اختياريًا
  const {
    diagnosis,
    disease,
    treatment,
    notes,
    date,
    time,
    notesImage,
    doctorName,
  } = req.body;

  // التحقق من وجود الطفل فقط (بدون التحقق من parentId)
  const child = await Child.findById(childId);
  if (!child) {
    return next(appError.create("Child not found", 404, httpStatusText.FAIL));
  }

  const updatedHistory = await History.findOneAndUpdate(
    { _id: historyId, childId },
    {
      diagnosis,
      disease,
      treatment,
      notes,
      date,
      time,
      notesImage,
      doctorName,
    },
    { new: true, runValidators: true }
  );

  if (!updatedHistory) {
    return next(
      appError.create("History record not found", 404, httpStatusText.FAIL)
    );
  }

  // إرسال الإشعار فقط إذا كان userId موجودًا
  if (userId) {
    await sendNotification(
      userId,
      childId,
      null,
      "History Updated",
      `${child.name}: ${updatedHistory.disease} updated.`,
      "history",
      "patient"
    );
  }

  res.json({
    status: httpStatusText.SUCCESS,
    data: {
      history: {
        _id: updatedHistory._id,
        diagnosis: updatedHistory.diagnosis,
        disease: updatedHistory.disease,
        treatment: updatedHistory.treatment,
        notes: updatedHistory.notes,
        notesImage: updatedHistory.notesImage,
        date: updatedHistory.date,
        time: updatedHistory.time,
        doctorName: updatedHistory.doctorName,
      },
    },
  });
});

// ✅ Delete a history record
const deleteHistory = asyncWrapper(async (req, res, next) => {
  const { childId, historyId } = req.params;
  const userId = req.user?.id; // جعل userId اختياريًا

  // التحقق من وجود الطفل فقط (بدون التحقق من parentId)
  const child = await Child.findById(childId);
  if (!child) {
    return next(appError.create("Child not found", 404, httpStatusText.FAIL));
  }

  const deletedHistory = await History.findOneAndDelete({
    _id: historyId,
    childId,
  });

  if (!deletedHistory) {
    return next(
      appError.create("History record not found", 404, httpStatusText.FAIL)
    );
  }

  // إرسال الإشعار فقط إذا كان userId موجودًا
  if (userId) {
    await sendNotification(
      userId,
      childId,
      null,
      "History Removed",
      `${child.name}: Record removed.`,
      "history",
      "patient"
    );
  }

  res.json({
    status: httpStatusText.SUCCESS,
    message: "History record deleted successfully",
  });
});

// ✅ Filter history records using query parameters
const filterHistory = asyncWrapper(async (req, res, next) => {
  const { childId } = req.params;

  // التحقق من وجود الطفل فقط (بدون التحقق من parentId)
  const child = await Child.findById(childId);
  if (!child) {
    return next(appError.create("Child not found", 404, httpStatusText.FAIL));
  }

  const { diagnosis, disease, treatment, fromDate, toDate, sortBy } = req.query;

  let query = { childId };

  if (diagnosis) {
    query.diagnosis = { $regex: diagnosis, $options: "i" };
  }

  if (disease) {
    query.disease = { $regex: disease, $options: "i" };
  }

  if (treatment) {
    query.treatment = { $regex: treatment, $options: "i" };
  }

  if (fromDate && toDate) {
    query.date = { $gte: new Date(fromDate), $lte: new Date(toDate) };
  }

  let sortOption = { date: -1 };
  if (sortBy === "oldest") {
    sortOption = { date: 1 };
  }

  const history = await History.find(query)
    .sort(sortOption)
    .select("_id diagnosis disease treatment date doctorName");

  if (!history.length) {
    return next(
      appError.create("No history records found", 404, httpStatusText.FAIL)
    );
  }

  res.json({
    status: httpStatusText.SUCCESS,
    data: history.map((record) => ({
      _id: record._id,
      diagnosis: record.diagnosis,
      disease: record.disease,
      treatment: record.treatment,
      date: record.date,
      doctorName: record.doctorName,
    })),
  });
});

module.exports = {
  createHistory,
  getAllHistory,
  getSingleHistory,
  updateHistory,
  deleteHistory,
  filterHistory,
};