// // const Medicine = require("../models/medicine.model");
// // const Child = require("../models/child.model");
// // const asyncWrapper = require("../middlewares/asyncWrapper");
// // const httpStatusText = require("../utils/httpStatusText");
// // const appError = require("../utils/appError");

// // // ✅ Create a new medicine for a specific child
// // const createMedicine = asyncWrapper(async (req, res, next) => {
// //   const { childId } = req.params; // Extract childId from URL params
// //   const userId = req.user.id; // جلب الـ userId من الـ JWT (بعد تسجيل الدخول)
// //   const { name, description, days, times } = req.body;

// //   if (!name || !days || !times) {
// //     return next(
// //       appError.create(
// //         "Name, days, and times are required",
// //         400,
// //         httpStatusText.FAIL
// //       )
// //     );
// //   }

// //   // التحقق إن الـ childId ده ينتمي لليوزر اللي سجل دخول
// //   const child = await Child.findOne({ _id: childId, parentId: userId }); // تعديل userId إلى parentId
// //   if (!child) {
// //     return next(
// //       appError.create(
// //         "Child not found or you are not authorized",
// //         404,
// //         httpStatusText.FAIL
// //       )
// //     );
// //   }

// //   const newMedicine = new Medicine({
// //     userId, // إضافة الـ userId للدواء
// //     childId,
// //     name,
// //     description,
// //     days,
// //     times,
// //   });

// //   await newMedicine.save();
// //   res.status(201).json({
// //     status: httpStatusText.SUCCESS,
// //     data: {
// //       medicine: {
// //         _id: newMedicine._id,
// //         userId: newMedicine.userId,
// //         childId: newMedicine.childId,
// //         name: newMedicine.name,
// //         description: newMedicine.description,
// //         days: newMedicine.days,
// //         times: newMedicine.times,
// //         createdAt: newMedicine.createdAt,
// //       },
// //     },
// //   });
// // });

// // // ✅ Get all medicines for a specific child
// // const getAllMedicines = asyncWrapper(async (req, res, next) => {
// //   const { childId } = req.params; // Assuming you pass childId in the URL
// //   const userId = req.user.id; // جلب الـ userId من الـ JWT

// //   // التحقق إن الـ childId ده ينتمي لليوزر اللي سجل دخول
// //   const child = await Child.findOne({ _id: childId, parentId: userId }); // تعديل userId إلى parentId
// //   if (!child) {
// //     return next(
// //       appError.create(
// //         "Child not found or you are not authorized",
// //         404,
// //         httpStatusText.FAIL
// //       )
// //     );
// //   }

// //   const medicines = await Medicine.find({ childId, userId }).select(
// //     "_id name description days times createdAt"
// //   );

// //   if (!medicines.length) {
// //     return next(
// //       appError.create(
// //         "No medicines found for this child",
// //         404,
// //         httpStatusText.FAIL
// //       )
// //     );
// //   }

// //   res.json({
// //     status: httpStatusText.SUCCESS,
// //     data: medicines.map((medicine) => ({
// //       _id: medicine._id,
// //       name: medicine.name,
// //       description: medicine.description,
// //       days: medicine.days,
// //       times: medicine.times,
// //       createdAt: medicine.createdAt,
// //     })),
// //   });
// // });

// // // ✅ Get a single medicine record for a specific child
// // const getSingleMedicine = asyncWrapper(async (req, res, next) => {
// //   const { childId, medicineId } = req.params;
// //   const userId = req.user.id; // جلب الـ userId من الـ JWT

// //   // التحقق إن الـ childId ده ينتمي لليوزر اللي سجل دخول
// //   const child = await Child.findOne({ _id: childId, parentId: userId }); // تعديل userId إلى parentId
// //   if (!child) {
// //     return next(
// //       appError.create(
// //         "Child not found or you are not authorized",
// //         404,
// //         httpStatusText.FAIL
// //       )
// //     );
// //   }

// //   const medicine = await Medicine.findOne({
// //     _id: medicineId,
// //     childId,
// //     userId,
// //   }).select("_id name description days times createdAt");

// //   if (!medicine) {
// //     return next(
// //       appError.create("Medicine not found", 404, httpStatusText.FAIL)
// //     );
// //   }

// //   res.json({
// //     status: httpStatusText.SUCCESS,
// //     data: {
// //       _id: medicine._id,
// //       name: medicine.name,
// //       description: medicine.description,
// //       days: medicine.days,
// //       times: medicine.times,
// //       createdAt: medicine.createdAt,
// //     },
// //   });
// // });

// // // ✅ Update a medicine record
// // const updateMedicine = asyncWrapper(async (req, res, next) => {
// //   const { childId, medicineId } = req.params;
// //   const userId = req.user.id; // جلب الـ userId من الـ JWT
// //   const { name, description, days, times } = req.body;

// //   // التحقق إن الـ childId ده ينتمي لليوزر اللي سجل دخول
// //   const child = await Child.findOne({ _id: childId, parentId: userId }); // تعديل userId إلى parentId
// //   if (!child) {
// //     return next(
// //       appError.create(
// //         "Child not found or you are not authorized",
// //         404,
// //         httpStatusText.FAIL
// //       )
// //     );
// //   }

// //   const updatedMedicine = await Medicine.findOneAndUpdate(
// //     { _id: medicineId, childId, userId },
// //     { name, description, days, times },
// //     { new: true, runValidators: true }
// //   ).select("_id name description days times createdAt");

// //   if (!updatedMedicine) {
// //     return next(
// //       appError.create("Medicine not found", 404, httpStatusText.FAIL)
// //     );
// //   }

// //   res.json({
// //     status: httpStatusText.SUCCESS,
// //     data: {
// //       _id: updatedMedicine._id,
// //       name: updatedMedicine.name,
// //       description: updatedMedicine.description,
// //       days: updatedMedicine.days,
// //       times: updatedMedicine.times,
// //       createdAt: updatedMedicine.createdAt,
// //     },
// //   });
// // });

// // // ✅ Delete a medicine record
// // const deleteMedicine = asyncWrapper(async (req, res, next) => {
// //   const { childId, medicineId } = req.params;
// //   const userId = req.user.id; // جلب الـ userId من الـ JWT

// //   // التحقق إن الـ childId ده ينتمي لليوزر اللي سجل دخول
// //   const child = await Child.findOne({ _id: childId, parentId: userId }); // تعديل userId إلى parentId
// //   if (!child) {
// //     return next(
// //       appError.create(
// //         "Child not found or you are not authorized",
// //         404,
// //         httpStatusText.FAIL
// //       )
// //     );
// //   }

// //   const deletedMedicine = await Medicine.findOneAndDelete({
// //     _id: medicineId,
// //     childId,
// //     userId,
// //   });

// //   if (!deletedMedicine) {
// //     return next(
// //       appError.create("Medicine not found", 404, httpStatusText.FAIL)
// //     );
// //   }

// //   res.json({
// //     status: httpStatusText.SUCCESS,
// //     message: "Medicine deleted successfully",
// //   });
// // });

// // module.exports = {
// //   createMedicine,
// //   getAllMedicines,
// //   getSingleMedicine,
// //   updateMedicine,
// //   deleteMedicine,
// // };


// const Medicine = require("../models/medicine.model");
// const Child = require("../models/child.model");
// const asyncWrapper = require("../middlewares/asyncWrapper");
// const httpStatusText = require("../utils/httpStatusText");
// const appError = require("../utils/appError");

// // ✅ Create a new medicine for a specific child
// const createMedicine = asyncWrapper(async (req, res, next) => {
//   const { childId } = req.params;
//   const userId = req.user.id;
//   const { name, description, days, times } = req.body;

//   if (!name || !days || !times) {
//     return next(
//       appError.create(
//         "Name, days, and times are required",
//         400,
//         httpStatusText.FAIL
//       )
//     );
//   }

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

//   const newMedicine = new Medicine({
//     userId,
//     childId,
//     name,
//     description,
//     days,
//     times,
//   });

//   await newMedicine.save();
//   res.status(201).json({
//     status: httpStatusText.SUCCESS,
//     data: {
//       medicine: {
//         _id: newMedicine._id,
//         userId: newMedicine.userId,
//         childId: newMedicine.childId,
//         name: newMedicine.name,
//         description: newMedicine.description,
//         days: newMedicine.days,
//         times: newMedicine.times,
//         createdAt: newMedicine.createdAt,
//       },
//     },
//   });
// });

// // ✅ Get all medicines for a specific child
// const getAllMedicines = asyncWrapper(async (req, res, next) => {
//   const { childId } = req.params;
//   const userId = req.user.id;

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

//   const medicines = await Medicine.find({ childId, userId }).select(
//     "_id name description days times createdAt"
//   );

//   if (!medicines.length) {
//     return next(
//       appError.create(
//         "No medicines found for this child",
//         404,
//         httpStatusText.FAIL
//       )
//     );
//   }

//   res.json({
//     status: httpStatusText.SUCCESS,
//     data: medicines.map((medicine) => ({
//       _id: medicine._id,
//       name: medicine.name,
//       description: medicine.description,
//       days: medicine.days,
//       times: medicine.times,
//       createdAt: medicine.createdAt,
//     })),
//   });
// });

// // ✅ Get a single medicine record for a specific child
// const getSingleMedicine = asyncWrapper(async (req, res, next) => {
//   const { childId, medicineId } = req.params;
//   const userId = req.user.id;

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

//   const medicine = await Medicine.findOne({
//     _id: medicineId,
//     childId,
//     userId,
//   }).select("_id name description days times createdAt");

//   if (!medicine) {
//     return next(
//       appError.create("Medicine not found", 404, httpStatusText.FAIL)
//     );
//   }

//   res.json({
//     status: httpStatusText.SUCCESS,
//     data: {
//       _id: medicine._id,
//       name: medicine.name,
//       description: medicine.description,
//       days: medicine.days,
//       times: medicine.times,
//       createdAt: medicine.createdAt,
//     },
//   });
// });

// // ✅ Update a medicine record
// const updateMedicine = asyncWrapper(async (req, res, next) => {
//   const { childId, medicineId } = req.params;
//   const userId = req.user.id;
//   const { name, description, days, times } = req.body;

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

//   const updatedMedicine = await Medicine.findOneAndUpdate(
//     { _id: medicineId, childId, userId },
//     { name, description, days, times },
//     { new: true, runValidators: true }
//   ).select("_id name description days times createdAt");

//   if (!updatedMedicine) {
//     return next(
//       appError.create("Medicine not found", 404, httpStatusText.FAIL)
//     );
//   }

//   res.json({
//     status: httpStatusText.SUCCESS,
//     data: {
//       _id: updatedMedicine._id,
//       name: updatedMedicine.name,
//       description: updatedMedicine.description,
//       days: updatedMedicine.days,
//       times: updatedMedicine.times,
//       createdAt: updatedMedicine.createdAt,
//     },
//   });
// });

// // ✅ Delete a medicine record
// const deleteMedicine = asyncWrapper(async (req, res, next) => {
//   const { childId, medicineId } = req.params;
//   const userId = req.user.id;

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

//   const deletedMedicine = await Medicine.findOneAndDelete({
//     _id: medicineId,
//     childId,
//     userId,
//   });

//   if (!deletedMedicine) {
//     return next(
//       appError.create("Medicine not found", 404, httpStatusText.FAIL)
//     );
//   }

//   res.json({
//     status: httpStatusText.SUCCESS,
//     message: "Medicine deleted successfully",
//   });
// });

// module.exports = {
//   createMedicine,
//   getAllMedicines,
//   getSingleMedicine,
//   updateMedicine,
//   deleteMedicine,
// };

const Medicine = require("../models/medicine.model");
const Child = require("../models/child.model");
const asyncWrapper = require("../middlewares/asyncWrapper");
const httpStatusText = require("../utils/httpStatusText");
const appError = require("../utils/appError");
const { sendNotification } = require("../controllers/notifications.controller");

// ✅ Create a new medicine for a specific child
const createMedicine = asyncWrapper(async (req, res, next) => {
  const { childId } = req.params;
  const userId = req.user?.id;
  const { name, description, days, times } = req.body;

  // التحقق من وجود userId
  if (!userId) {
    return next(
      appError.create("User not authenticated", 401, httpStatusText.FAIL)
    );
  }

  if (!name || !days || !times) {
    return next(
      appError.create(
        "Name, days, and times are required",
        400,
        httpStatusText.FAIL
      )
    );
  }

  const child = await Child.findOne({ _id: childId, parentId: userId });
  if (!child) {
    return next(
      appError.create(
        "Child not found or you are not authorized",
        404,
        httpStatusText.FAIL
      )
    );
  }

  const newMedicine = new Medicine({
    userId,
    childId,
    name,
    description,
    days,
    times,
  });

  await newMedicine.save();

  // إرسال إشعار
  try {
    await sendNotification(
      userId,
      childId,
      null,
      "Medicine Added",
      `${child.name}: ${name} added.`,
      "medicine",
      "patient"
    );
    console.log(
      `Notification sent for new medicine: ${name} for child: ${child.name}`
    );
  } catch (error) {
    console.error(
      `Failed to send notification for new medicine: ${name}`,
      error
    );
  }

  res.status(201).json({
    status: httpStatusText.SUCCESS,
    data: {
      medicine: {
        _id: newMedicine._id,
        userId: newMedicine.userId,
        childId: newMedicine.childId,
        name: newMedicine.name,
        description: newMedicine.description,
        days: newMedicine.days,
        times: newMedicine.times,
        createdAt: newMedicine.createdAt,
      },
    },
  });
});

// ✅ Get all medicines for a specific child
const getAllMedicines = asyncWrapper(async (req, res, next) => {
  const { childId } = req.params;
  const userId = req.user.id;

  const child = await Child.findOne({ _id: childId, parentId: userId });
  if (!child) {
    return next(
      appError.create(
        "Child not found or you are not authorized",
        404,
        httpStatusText.FAIL
      )
    );
  }

  const medicines = await Medicine.find({ childId, userId }).select(
    "_id name description days times createdAt"
  );

  if (!medicines.length) {
    return next(
      appError.create(
        "No medicines found for this child",
        404,
        httpStatusText.FAIL
      )
    );
  }

  res.json({
    status: httpStatusText.SUCCESS,
    data: medicines.map((medicine) => ({
      _id: medicine._id,
      name: medicine.name,
      description: medicine.description,
      days: medicine.days,
      times: medicine.times,
      createdAt: medicine.createdAt,
    })),
  });
});

// ✅ Get a single medicine record for a specific child
const getSingleMedicine = asyncWrapper(async (req, res, next) => {
  const { childId, medicineId } = req.params;
  const userId = req.user.id;

  const child = await Child.findOne({ _id: childId, parentId: userId });
  if (!child) {
    return next(
      appError.create(
        "Child not found or you are not authorized",
        404,
        httpStatusText.FAIL
      )
    );
  }

  const medicine = await Medicine.findOne({
    _id: medicineId,
    childId,
    userId,
  }).select("_id name description days times createdAt");

  if (!medicine) {
    return next(
      appError.create("Medicine not found", 404, httpStatusText.FAIL)
    );
  }

  res.json({
    status: httpStatusText.SUCCESS,
    data: {
      _id: medicine._id,
      name: medicine.name,
      description: medicine.description,
      days: medicine.days,
      times: medicine.times,
      createdAt: medicine.createdAt,
    },
  });
});

// ✅ Update a medicine record
const updateMedicine = asyncWrapper(async (req, res, next) => {
  const { childId, medicineId } = req.params;
  const userId = req.user.id;
  const { name, description, days, times } = req.body;

  const child = await Child.findOne({ _id: childId, parentId: userId });
  if (!child) {
    return next(
      appError.create(
        "Child not found or you are not authorized",
        404,
        httpStatusText.FAIL
      )
    );
  }

  const updatedMedicine = await Medicine.findOneAndUpdate(
    { _id: medicineId, childId, userId },
    { name, description, days, times },
    { new: true, runValidators: true }
  ).select("_id name description days times createdAt");

  if (!updatedMedicine) {
    return next(
      appError.create("Medicine not found", 404, httpStatusText.FAIL)
    );
  }

  // إرسال إشعار مختصر
  try {
    await sendNotification(
      userId,
      childId,
      null,
      "Medicine Updated",
      `${child.name}: ${updatedMedicine.name} updated.`,
      "medicine",
      "patient"
    );
    console.log(
      `Notification sent for updated medicine: ${updatedMedicine.name} for child: ${child.name}`
    );
  } catch (error) {
    console.error(
      `Failed to send notification for updated medicine: ${updatedMedicine.name}`,
      error
    );
  }

  res.json({
    status: httpStatusText.SUCCESS,
    data: {
      _id: updatedMedicine._id,
      name: updatedMedicine.name,
      description: updatedMedicine.description,
      days: updatedMedicine.days,
      times: updatedMedicine.times,
      createdAt: updatedMedicine.createdAt,
    },
  });
});

// ✅ Delete a medicine record
const deleteMedicine = asyncWrapper(async (req, res, next) => {
  const { childId, medicineId } = req.params;
  const userId = req.user.id;

  const child = await Child.findOne({ _id: childId, parentId: userId });
  if (!child) {
    return next(
      appError.create(
        "Child not found or you are not authorized",
        404,
        httpStatusText.FAIL
      )
    );
  }

  const deletedMedicine = await Medicine.findOneAndDelete({
    _id: medicineId,
    childId,
    userId,
  });

  if (!deletedMedicine) {
    return next(
      appError.create("Medicine not found", 404, httpStatusText.FAIL)
    );
  }

  // إرسال إشعار مختصر
  try {
    await sendNotification(
      userId,
      childId,
      null,
      "Medicine Removed",
      `${child.name}: ${deletedMedicine.name} removed.`,
      "medicine",
      "patient"
    );
    console.log(
      `Notification sent for deleted medicine: ${deletedMedicine.name} for child: ${child.name}`
    );
  } catch (error) {
    console.error(
      `Failed to send notification for deleted medicine: ${deletedMedicine.name}`,
      error
    );
  }

  res.json({
    status: httpStatusText.SUCCESS,
    message: "Medicine deleted successfully",
  });
});

module.exports = {
  createMedicine,
  getAllMedicines,
  getSingleMedicine,
  updateMedicine,
  deleteMedicine,
};