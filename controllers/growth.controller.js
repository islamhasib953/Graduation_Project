const Growth = require("../models/growth.model");
const asyncWrapper = require("../middlewares/asyncWrapper");
const httpStatusText = require("../utils/httpStatusText");
const appError = require("../utils/appError");

const createGrowth = asyncWrapper(async (req, res, next) => {
  const { childId } = req.params;
  const { weight, height, headCircumference, date, time, notes, notesImage } =
    req.body;

  if (!weight || !height || !headCircumference || !date || !time) {
    return next(
      appError.create(
        "All required fields must be provided",
        400,
        httpStatusText.FAIL
      )
    );
  }

  const newGrowth = new Growth({
    childId,
    parentId: req.user.id, // Store the logged-in user's ID
    weight,
    height,
    headCircumference,
    date,
    time,
    notes: notes || "",
    notesImage: notesImage || null,
  });

  await newGrowth.save();

  res.json({
    status: httpStatusText.SUCCESS,
    data: newGrowth,
  });
});

// ✅ Get all growth records for a specific child
const getAllGrowth = asyncWrapper(async (req, res, next) => {
  const { childId } = req.params;

  const growthRecords = await Growth.find({ childId }).sort({ date: -1 });

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
    data: growthRecords,
  });
});

// ✅ Get a single growth record for a specific child
const getSingleGrowth = asyncWrapper(async (req, res, next) => {
  const { childId, growthId } = req.params;

  const growth = await Growth.findOne({ _id: growthId, childId });

  if (!growth) {
    return next(
      appError.create("Growth record not found", 404, httpStatusText.FAIL)
    );
  }

  res.json({
    status: httpStatusText.SUCCESS,
    data: growth,
  });
});

// ✅ Get a last growth record for a specific child

const getLastGrowthRecord = asyncWrapper(async (req, res, next) => {
  const { childId } = req.params;

  const lastGrowth = await Growth.findOne({ childId })
    .populate("parentId", "name email") // Fetch the user details who recorded it
    .sort({ date: -1, time: -1 }); // Sort by latest date & time

  if (!lastGrowth) {
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
    data: lastGrowth,
  });
});

// ✅ Get a last growth Change for a specific child

const getLastGrowthChange = asyncWrapper(async (req, res, next) => {
  const { childId } = req.params;

  // Fetch the last two growth records for the child
  const lastTwoRecords = await Growth.find({ childId })
    .sort({ date: -1, time: -1 }) // Sort by latest date and time
    .limit(2); // Get only the last two records

  // If there are no records or only one record, return null
  if (lastTwoRecords.length < 2) {
    return res.json({
      status: httpStatusText.SUCCESS,
      data: {
        weightChange: null,
        heightChange: null,
        headCircumferenceChange: null,
      },
    });
  }

  // Extract values from the last two records
  const latestRecord = lastTwoRecords[0];
  const previousRecord = lastTwoRecords[1];

  // Calculate changes in weight, height, and head circumference
  const weightChange = latestRecord.weight - previousRecord.weight;
  const heightChange = latestRecord.height - previousRecord.height;
  const headCircumferenceChange =
    latestRecord.headCircumference - previousRecord.headCircumference;

  res.json({
    status: httpStatusText.SUCCESS,
    data: {
      weightChange,
      heightChange,
      headCircumferenceChange,
    },
  });
});


// ✅ Update a growth record
const updateGrowth = asyncWrapper(async (req, res, next) => {
  const { childId, growthId } = req.params;
  const { weight, height, headCircumference, date, time, notes, notesImage } =
    req.body;

  const updatedGrowth = await Growth.findOneAndUpdate(
    { _id: growthId, childId },
    { weight, height, headCircumference, date, time, notes, notesImage },
    { new: true, runValidators: true }
  );

  if (!updatedGrowth) {
    return next(
      appError.create("Growth record not found", 404, httpStatusText.FAIL)
    );
  }

  res.json({
    status: httpStatusText.SUCCESS,
    data: updatedGrowth,
  });
});

// ✅ Delete a growth record
const deleteGrowth = asyncWrapper(async (req, res, next) => {
  const { childId, growthId } = req.params;

  const deletedGrowth = await Growth.findOneAndDelete({
    _id: growthId,
    childId,
  });

  if (!deletedGrowth) {
    return next(
      appError.create("Growth record not found", 404, httpStatusText.FAIL)
    );
  }

  res.json({
    status: httpStatusText.SUCCESS,
    message: "Growth record deleted successfully",
  });
});

module.exports = {
  createGrowth,
  getAllGrowth,
  getSingleGrowth,
  getLastGrowthRecord,
  getLastGrowthChange,
  updateGrowth,
  deleteGrowth,
};
