// const Child = require("../models/child.model");
// const User = require("../models/user.model");
// const asyncWrapper = require("../middlewares/asyncWrapper");
// const httpStatusText = require("../utils/httpStatusText");
// const appError = require("../utils/appError");
// const VaccineInfo = require("../models/vaccineInfo.model");
// const UserVaccination = require("../models/UserVaccination.model");
// const { sendNotification } = require("../controllers/notifications.controller");

// const createChild = asyncWrapper(async (req, res, next) => {
//   const {
//     name,
//     gender,
//     birthDate,
//     bloodType,
//     heightAtBirth,
//     weightAtBirth,
//     headCircumferenceAtBirth,
//   } = req.body;

//   const parentId = req.user.id;

//   if (
//     !name ||
//     !gender ||
//     !birthDate ||
//     !bloodType ||
//     !heightAtBirth ||
//     !weightAtBirth ||
//     !headCircumferenceAtBirth
//   ) {
//     return next(
//       appError.create("All fields are required", 400, httpStatusText.FAIL)
//     );
//   }

//   const parent = await User.findById(parentId);
//   if (!parent) {
//     return next(
//       appError.create("Parent does not exist", 404, httpStatusText.FAIL)
//     );
//   }

//   const childPhoto = req.file
//     ? `/uploads/${req.file.filename}`
//     : "Uploads/child.jpg";

//   const newChild = new Child({
//     name,
//     gender,
//     photo: childPhoto,
//     parentId,
//     birthDate,
//     bloodType,
//     heightAtBirth,
//     weightAtBirth,
//     headCircumferenceAtBirth,
//   });

//   await newChild.save();

//   const allVaccines = await VaccineInfo.find();

//   if (allVaccines.length > 0) {
//     const vaccinationsToCreate = allVaccines.map((vaccine) => {
//       const dueDate = new Date(birthDate);
//       dueDate.setMonth(dueDate.getMonth() + vaccine.originalSchedule);

//       return {
//         childId: newChild._id,
//         vaccineInfoId: vaccine._id,
//         dueDate,
//       };
//     });

//     await UserVaccination.insertMany(vaccinationsToCreate);
//   }

//   await sendNotification(
//     parentId,
//     newChild._id,
//     null,
//     "Child Added",
//     `${newChild.name} added.`,
//     "child",
//     "patient"
//   );

//   res.status(201).json({
//     status: httpStatusText.SUCCESS,
//     message: "Child created successfully and assigned vaccinations.",
//     data: {
//       child: newChild,
//       parentPhone: parent.phone,
//     },
//   });
// });

// const getAllChildren = asyncWrapper(async (req, res) => {
//   const children = await Child.find({}, "_id name birthDate photo");
//   res.json({
//     status: httpStatusText.SUCCESS,
//     data: children.map((child) => ({
//       id: child._id,
//       name: child.name,
//       birthDate: child.birthDate,
//       photo: child.photo,
//     })),
//   });
// });

// const getChildrenForUser = asyncWrapper(async (req, res, next) => {
//   const userId = req.user.id;
//   const children = await Child.find({ parentId: userId })
//     .select(
//       "_id name gender birthDate heightAtBirth weightAtBirth headCircumferenceAtBirth bloodType photo parentId"
//     )
//     .populate("parentId", "phone");

//   if (!children.length) {
//     return next(
//       appError.create(
//         "No children found for this user",
//         404,
//         httpStatusText.FAIL
//       )
//     );
//   }

//   res.json({
//     status: httpStatusText.SUCCESS,
//     data: children.map((child) => ({
//       _id: child._id,
//       name: child.name,
//       gender: child.gender,
//       birthDate: child.birthDate,
//       heightAtBirth: child.heightAtBirth,
//       weightAtBirth: child.weightAtBirth,
//       headCircumferenceAtBirth: child.headCircumferenceAtBirth,
//       bloodType: child.bloodType,
//       photo: child.photo,
//       parentPhone: child.parentId?.phone || null,
//       parentId: child.parentId?._id || null,
//     })),
//   });
// });

// const getSingleChild = asyncWrapper(async (req, res, next) => {
//   const { childId } = req.params;

//   const child = await Child.findById(childId)
//     .select(
//       "_id name gender birthDate heightAtBirth weightAtBirth headCircumferenceAtBirth bloodType photo parentId"
//     )
//     .populate("parentId", "phone");

//   if (!child) {
//     return next(appError.create("Child not found", 404, httpStatusText.FAIL));
//   }

//   res.json({
//     status: httpStatusText.SUCCESS,
//     data: {
//       _id: child._id,
//       name: child.name,
//       gender: child.gender,
//       birthDate: child.birthDate,
//       heightAtBirth: child.heightAtBirth,
//       weightAtBirth: child.weightAtBirth,
//       headCircumferenceAtBirth: child.headCircumferenceAtBirth,
//       bloodType: child.bloodType,
//       photo: child.photo,
//       parentPhone: child.parentId?.phone || null,
//     },
//   });
// });

// const updateChild = asyncWrapper(async (req, res, next) => {
//   const { childId } = req.params;
//   const {
//     name,
//     gender,
//     birthDate,
//     bloodType,
//     heightAtBirth,
//     weightAtBirth,
//     headCircumferenceAtBirth,
//   } = req.body;

//   const child = await Child.findById(childId);
//   if (!child) {
//     return next(appError.create("Child not found", 404, httpStatusText.FAIL));
//   }

//   const changes = [];
//   if (name && name !== child.name) {
//     changes.push(`name to ${name}`);
//     child.name = name;
//   }
//   if (gender && gender !== child.gender) {
//     changes.push(`gender to ${gender}`);
//     child.gender = gender;
//   }
//   if (birthDate && birthDate !== child.birthDate.toISOString()) {
//     changes.push(`birth date to ${birthDate}`);
//     child.birthDate = birthDate;
//   }
//   if (bloodType && bloodType !== child.bloodType) {
//     changes.push(`blood type to ${bloodType}`);
//     child.bloodType = bloodType;
//   }
//   if (heightAtBirth && heightAtBirth !== child.heightAtBirth) {
//     changes.push(`birth height to ${heightAtBirth}`);
//     child.heightAtBirth = heightAtBirth;
//   }
//   if (weightAtBirth && weightAtBirth !== child.weightAtBirth) {
//     changes.push(`birth weight to ${weightAtBirth}`);
//     child.weightAtBirth = weightAtBirth;
//   }
//   if (
//     headCircumferenceAtBirth &&
//     headCircumferenceAtBirth !== child.headCircumferenceAtBirth
//   ) {
//     changes.push(`birth head circumference to ${headCircumferenceAtBirth}`);
//     child.headCircumferenceAtBirth = headCircumferenceAtBirth;
//   }
//   if (req.file) {
//     changes.push(`photo updated`);
//     child.photo = `/uploads/${req.file.filename}`;
//   }

//   await child.save();

//   if (changes.length > 0) {
//     await sendNotification(
//       child.parentId,
//       childId,
//       null,
//       "Child Updated",
//       `${child.name} updated: ${changes.join(", ")}`,
//       "child",
//       "patient"
//     );
//   }

//   res.json({
//     status: httpStatusText.SUCCESS,
//     data: { child },
//   });
// });

// const deleteChild = asyncWrapper(async (req, res, next) => {
//   const { childId } = req.params;
//   const userId = req.user.id;

//   const child = await Child.findById(childId);
//   if (!child) {
//     return next(appError.create("Child not found", 404, httpStatusText.FAIL));
//   }

//   if (child.parentId.toString() !== userId.toString()) {
//     return next(
//       appError.create(
//         "Unauthorized: You cannot delete this child",
//         403,
//         httpStatusText.FAIL
//       )
//     );
//   }

//   await sendNotification(
//     userId,
//     childId,
//     null,
//     "Child Removed",
//     `${child.name} removed.`,
//     "child",
//     "patient"
//   );

//   await Child.findByIdAndDelete(childId);

//   res.json({
//     status: httpStatusText.SUCCESS,
//     message: "Child deleted successfully",
//   });
// });

// module.exports = {
//   createChild,
//   getAllChildren,
//   getChildrenForUser,
//   getSingleChild,
//   updateChild,
//   deleteChild,
// };


const Child = require("../models/child.model");
const User = require("../models/user.model");
const asyncWrapper = require("../middlewares/asyncWrapper");
const httpStatusText = require("../utils/httpStatusText");
const appError = require("../utils/appError");
const VaccineInfo = require("../models/vaccineInfo.model");
const UserVaccination = require("../models/UserVaccination.model");
const {
  sendNotificationCore,
} = require("../controllers/notifications.controller");

const createChild = asyncWrapper(async (req, res, next) => {
  const {
    name,
    gender,
    birthDate,
    bloodType,
    heightAtBirth,
    weightAtBirth,
    headCircumferenceAtBirth,
  } = req.body;

  const parentId = req.user.id;

  if (
    !name ||
    !gender ||
    !birthDate ||
    !bloodType ||
    !heightAtBirth ||
    !weightAtBirth ||
    !headCircumferenceAtBirth
  ) {
    return next(
      appError.create("All fields are required", 400, httpStatusText.FAIL)
    );
  }

  const parent = await User.findById(parentId);
  if (!parent) {
    return next(
      appError.create("Parent does not exist", 404, httpStatusText.FAIL)
    );
  }

  const childPhoto = req.file
    ? `/uploads/${req.file.filename}`
    : "Uploads/child.jpg";

  const newChild = new Child({
    name,
    gender,
    photo: childPhoto,
    parentId,
    birthDate,
    bloodType,
    heightAtBirth,
    weightAtBirth,
    headCircumferenceAtBirth,
  });

  await newChild.save();

  const allVaccines = await VaccineInfo.find();

  if (allVaccines.length > 0) {
    const vaccinationsToCreate = allVaccines.map((vaccine) => {
      const dueDate = new Date(birthDate);
      dueDate.setMonth(dueDate.getMonth() + vaccine.originalSchedule);

      return {
        childId: newChild._id,
        vaccineInfoId: vaccine._id,
        dueDate,
      };
    });

    await UserVaccination.insertMany(vaccinationsToCreate);
  }

  try {
    await sendNotificationCore(
      parentId,
      newChild._id,
      null,
      "Child Added",
      `${newChild.name} added.`,
      "child",
      "patient"
    );
    console.log(`Notification sent for new child: ${newChild.name}`);
  } catch (error) {
    console.error(
      `Failed to send notification for new child: ${newChild.name}`,
      error
    );
  }

  res.status(201).json({
    status: httpStatusText.SUCCESS,
    message: "Child created successfully and assigned vaccinations.",
    data: {
      child: newChild,
      parentPhone: parent.phone,
    },
  });
});

const getAllChildren = asyncWrapper(async (req, res) => {
  const children = await Child.find({}, "_id name birthDate photo");
  res.json({
    status: httpStatusText.SUCCESS,
    data: children.map((child) => ({
      id: child._id,
      name: child.name,
      birthDate: child.birthDate,
      photo: child.photo,
    })),
  });
});

const getChildrenForUser = asyncWrapper(async (req, res, next) => {
  const userId = req.user.id;
  const children = await Child.find({ parentId: userId })
    .select(
      "_id name gender birthDate heightAtBirth weightAtBirth headCircumferenceAtBirth bloodType photo parentId"
    )
    .populate("parentId", "phone");

  if (!children.length) {
    return next(
      appError.create(
        "No children found for this user",
        404,
        httpStatusText.FAIL
      )
    );
  }

  res.json({
    status: httpStatusText.SUCCESS,
    data: children.map((child) => ({
      _id: child._id,
      name: child.name,
      gender: child.gender,
      birthDate: child.birthDate,
      heightAtBirth: child.heightAtBirth,
      weightAtBirth: child.weightAtBirth,
      headCircumferenceAtBirth: child.headCircumferenceAtBirth,
      bloodType: child.bloodType,
      photo: child.photo,
      parentPhone: child.parentId?.phone || null,
      parentId: child.parentId?._id || null,
    })),
  });
});

const getSingleChild = asyncWrapper(async (req, res, next) => {
  const { childId } = req.params;

  const child = await Child.findById(childId)
    .select(
      "_id name gender birthDate heightAtBirth weightAtBirth headCircumferenceAtBirth bloodType photo parentId"
    )
    .populate("parentId", "phone");

  if (!child) {
    return next(appError.create("Child not found", 404, httpStatusText.FAIL));
  }

  res.json({
    status: httpStatusText.SUCCESS,
    data: {
      _id: child._id,
      name: child.name,
      gender: child.gender,
      birthDate: child.birthDate,
      heightAtBirth: child.heightAtBirth,
      weightAtBirth: child.weightAtBirth,
      headCircumferenceAtBirth: child.headCircumferenceAtBirth,
      bloodType: child.bloodType,
      photo: child.photo,
      parentPhone: child.parentId?.phone || null,
    },
  });
});

const updateChild = asyncWrapper(async (req, res, next) => {
  const { childId } = req.params;
  const {
    name,
    gender,
    birthDate,
    bloodType,
    heightAtBirth,
    weightAtBirth,
    headCircumferenceAtBirth,
  } = req.body;

  const child = await Child.findById(childId);
  if (!child) {
    return next(appError.create("Child not found", 404, httpStatusText.FAIL));
  }

  const changes = [];
  if (name && name !== child.name) {
    changes.push(`name to ${name}`);
    child.name = name;
  }
  if (gender && gender !== child.gender) {
    changes.push(`gender to ${gender}`);
    child.gender = gender;
  }
  if (birthDate && birthDate !== child.birthDate.toISOString()) {
    changes.push(`birth date to ${birthDate}`);
    child.birthDate = birthDate;
  }
  if (bloodType && bloodType !== child.bloodType) {
    changes.push(`blood type to ${bloodType}`);
    child.bloodType = bloodType;
  }
  if (heightAtBirth && heightAtBirth !== child.heightAtBirth) {
    changes.push(`birth height to ${heightAtBirth}`);
    child.heightAtBirth = heightAtBirth;
  }
  if (weightAtBirth && weightAtBirth !== child.weightAtBirth) {
    changes.push(`birth weight to ${weightAtBirth}`);
    child.weightAtBirth = weightAtBirth;
  }
  if (
    headCircumferenceAtBirth &&
    headCircumferenceAtBirth !== child.headCircumferenceAtBirth
  ) {
    changes.push(`birth head circumference to ${headCircumferenceAtBirth}`);
    child.headCircumferenceAtBirth = headCircumferenceAtBirth;
  }
  if (req.file) {
    changes.push(`photo updated`);
    child.photo = `/uploads/${req.file.filename}`;
  }

  await child.save();

  if (changes.length > 0) {
    try {
      await sendNotificationCore(
        child.parentId,
        childId,
        null,
        "Child Updated",
        `${child.name} updated: ${changes.join(", ")}`,
        "child",
        "patient"
      );
      console.log(`Notification sent for updated child: ${child.name}`);
    } catch (error) {
      console.error(
        `Failed to send notification for updated child: ${child.name}`,
        error
      );
    }
  }

  res.json({
    status: httpStatusText.SUCCESS,
    data: { child },
  });
});

const deleteChild = asyncWrapper(async (req, res, next) => {
  const { childId } = req.params;
  const userId = req.user.id;

  const child = await Child.findById(childId);
  if (!child) {
    return next(appError.create("Child not found", 404, httpStatusText.FAIL));
  }

  if (child.parentId.toString() !== userId.toString()) {
    return next(
      appError.create(
        "Unauthorized: You cannot delete this child",
        403,
        httpStatusText.FAIL
      )
    );
  }

  try {
    await sendNotificationCore(
      userId,
      childId,
      null,
      "Child Removed",
      `${child.name} removed.`,
      "child",
      "patient"
    );
    console.log(`Notification sent for deleted child: ${child.name}`);
  } catch (error) {
    console.error(
      `Failed to send notification for deleted child: ${child.name}`,
      error
    );
  }

  await Child.findByIdAndDelete(childId);

  res.json({
    status: httpStatusText.SUCCESS,
    message: "Child deleted successfully",
  });
});

module.exports = {
  createChild,
  getAllChildren,
  getChildrenForUser,
  getSingleChild,
  updateChild,
  deleteChild,
};