const Child = require("../models/child.model");
const User = require("../models/user.model");
const asyncWrapper = require("../middlewares/asyncWrapper");
const httpStatusText = require("../utils/httpStatusText");
const appError = require("../utils/appError");
const VaccineInfo = require("../models/vaccineInfo.model");
const UserVaccination = require("../models/UserVaccination.model");

// ✅ Create new child and assign all existing vaccinations
const createChild = asyncWrapper(async (req, res, next) => {
  const {
    name,
    gender,
    photo,
    birthDate,
    bloodType,
    heightAtBirth,
    weightAtBirth,
    headCircumferenceAtBirth,
  } = req.body;

  const parentId = req.user.id; // Get parentId from logged-in user

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

  const childPhoto = photo || "Uploads/child.jpg";

  // إنشاء الطفل الجديد
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

  // ✅ جلب جميع التطعيمات من قاعدة البيانات
  const allVaccines = await VaccineInfo.find();

  // ✅ إذا كان هناك تطعيمات، أضفها للطفل الجديد
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

  res.status(201).json({
    status: httpStatusText.SUCCESS,
    message: "Child created successfully and assigned vaccinations.",
    data: {
      child: newChild,
      parentPhone: parent.phone,
    },
  });
});

// ✅ Get all children for admin
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

// ✅ Get all children for a specific user (logged-in user)
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

// ✅ Get single child with all details
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

// ✅ Update a child
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
    photo,
  } = req.body;

  const updatedChild = await Child.findByIdAndUpdate(
    childId,
    {
      name,
      gender,
      birthDate,
      bloodType,
      heightAtBirth,
      weightAtBirth,
      headCircumferenceAtBirth,
      photo,
    },
    { new: true }
  );

  if (!updatedChild) {
    return next(appError.create("Child not found", 404, httpStatusText.FAIL));
  }

  res.json({
    status: httpStatusText.SUCCESS,
    data: { child: updatedChild },
  });
});

// ✅ Delete a child
const deleteChild = asyncWrapper(async (req, res, next) => {
  const deletedChild = await Child.findByIdAndDelete(req.params.childId);

  if (!deletedChild) {
    return next(appError.create("Child not found", 404, httpStatusText.FAIL));
  }

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
