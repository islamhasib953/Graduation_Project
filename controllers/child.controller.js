const Child = require("../models/child.model");
const User = require("../models/user.model");
const asyncWrapper = require("../middlewares/asyncWrapper");
const httpStatusText = require("../utils/httpStatusText");
const appError = require("../utils/appError");

// ✅ create new child
const createChild = asyncWrapper(async (req, res, next) => {
  const {
    name,
    gender,
    photo,
    birthDate,
    bloodType,
    heightAtBirth,
    weightAtBirth,
  } = req.body;

  const parentId = req.user.id; // Get parentId from logged-in user

  if (
    !name ||
    !gender ||
    !birthDate ||
    !bloodType ||
    !heightAtBirth ||
    !weightAtBirth
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

  const childPhoto = photo || "uploads/child.jpg";

  const newChild = new Child({
    name,
    gender,
    photo: childPhoto,
    parentId,
    birthDate,
    bloodType,
    heightAtBirth,
    weightAtBirth,
  });

  await newChild.save();

  res.status(201).json({
    status: httpStatusText.SUCCESS,
    data: {
      child: newChild,
      parentPhone: parent.phone,
    },
  });
});

// ✅ Get all children
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

// ✅ Get single child with all details
const getSingleChild = asyncWrapper(async (req, res, next) => {
  const { childId } = req.params;
  const child = await Child.findById(childId).populate("parentId", "phone");

  if (!child) {
    const error = appError.create("Child not found", 404, httpStatusText.FAIL);
    return next(error);
  }

  res.json({
    status: httpStatusText.SUCCESS,
    data: {
      child,
      parentPhone: child.parentId.phone,
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
    photo,
  } = req.body;

  const updatedChild = await Child.findByIdAndUpdate(
    childId,
    { name, gender, birthDate, bloodType, heightAtBirth, weightAtBirth, photo },
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
  getSingleChild,
  updateChild,
  deleteChild,
};
