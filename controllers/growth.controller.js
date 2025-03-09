const Growth = require("../models/growth.model");
const asyncWrapper = require("../middlewares/asyncWrapper");
const httpStatusText = require("../utils/httpStatusText");
const appError = require("../utils/appError");

// ✅ Create a new growth record for a specific child
const createGrowth = asyncWrapper(async (req, res, next) => {
  const { childId } = req.params; // Extract childId from URL params
  const { ageInMonths, height, weight, headCircumference } = req.body;

  if (!ageInMonths || !height || !weight || !headCircumference) {
    return next(
      appError.create(
        "ageInMonths, height, weight, and headCircumference are required",
        400,
        httpStatusText.FAIL
      )
    );
  }

  const newGrowth = new Growth({
    childId,
    ageInMonths,
    height,
    weight,
    headCircumference,
  });

  await newGrowth.save();
  res.status(201).json({
    status: httpStatusText.SUCCESS,
    data: { growth: newGrowth },
  });
});

// ✅ Get all growth records for a specific child
const getAllGrowth = asyncWrapper(async (req, res, next) => {
  const { childId } = req.params; // Extract childId from URL params

  const growthRecords = await Growth.find({ childId }).select(
    "_id ageInMonths height weight headCircumference createdAt"
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
      ageInMonths: record.ageInMonths,
      height: record.height,
      weight: record.weight,
      headCircumference: record.headCircumference,
      createdAt: record.createdAt,
    })),
  });
});

// ✅ Get a single growth record for a specific child
const getSingleGrowth = asyncWrapper(async (req, res, next) => {
  const { childId, growthId } = req.params;

  const growth = await Growth.findOne({ _id: growthId, childId }).select(
    "_id ageInMonths height weight headCircumference createdAt"
  );

  if (!growth) {
    return next(
      appError.create("Growth record not found", 404, httpStatusText.FAIL)
    );
  }

  res.json({
    status: httpStatusText.SUCCESS,
    data: {
      _id: growth._id,
      ageInMonths: growth.ageInMonths,
      height: growth.height,
      weight: growth.weight,
      headCircumference: growth.headCircumference,
      createdAt: growth.createdAt,
    },
  });
});

// ✅ Update a growth record
const updateGrowth = asyncWrapper(async (req, res, next) => {
  const { childId, growthId } = req.params;
  const { ageInMonths, height, weight, headCircumference } = req.body;

  const updatedGrowth = await Growth.findOneAndUpdate(
    { _id: growthId, childId },
    { ageInMonths, height, weight, headCircumference },
    { new: true, runValidators: true }
  ).select("_id ageInMonths height weight headCircumference createdAt");

  if (!updatedGrowth) {
    return next(
      appError.create("Growth record not found", 404, httpStatusText.FAIL)
    );
  }

  res.json({
    status: httpStatusText.SUCCESS,
    data: {
      _id: updatedGrowth._id,
      ageInMonths: updatedGrowth.ageInMonths,
      height: updatedGrowth.height,
      weight: updatedGrowth.weight,
      headCircumference: updatedGrowth.headCircumference,
      createdAt: updatedGrowth.createdAt,
    },
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

// ✅ Get the last growth record for a specific child
const getLastGrowthRecord = asyncWrapper(async (req, res, next) => {
  const { childId } = req.params;

  const lastGrowth = await Growth.findOne({ childId })
    .sort({ createdAt: -1 })
    .select("_id ageInMonths height weight headCircumference createdAt");

  if (!lastGrowth) {
    return next(
      appError.create(
        "No growth record found for this child",
        404,
        httpStatusText.FAIL
      )
    );
  }

  res.json({
    status: httpStatusText.SUCCESS,
    data: {
      _id: lastGrowth._id,
      ageInMonths: lastGrowth.ageInMonths,
      height: lastGrowth.height,
      weight: lastGrowth.weight,
      headCircumference: lastGrowth.headCircumference,
      createdAt: lastGrowth.createdAt,
    },
  });
});

// ✅ Get the last growth change for a specific child (assuming last update or difference)
const getLastGrowthChange = asyncWrapper(async (req, res, next) => {
  const { childId } = req.params;

  const growthRecords = await Growth.find({ childId })
    .sort({ createdAt: -1 })
    .limit(2)
    .select("ageInMonths height weight headCircumference createdAt");

  if (growthRecords.length < 2) {
    return next(
      appError.create(
        "Not enough growth records to calculate change",
        404,
        httpStatusText.FAIL
      )
    );
  }

  const [latest, previous] = growthRecords;
  const change = {
    ageInMonths: latest.ageInMonths - previous.ageInMonths,
    heightChange: latest.height - previous.height,
    weightChange: latest.weight - previous.weight,
    headCircumferenceChange:
      latest.headCircumference - previous.headCircumference,
    latestRecord: latest.createdAt,
    previousRecord: previous.createdAt,
  };

  res.json({
    status: httpStatusText.SUCCESS,
    data: change,
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
