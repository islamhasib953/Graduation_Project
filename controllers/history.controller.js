const History = require("../models/history.model");
const asyncWrapper = require("../middlewares/asyncWrapper");
const httpStatusText = require("../utils/httpStatusText");
const appError = require("../utils/appError");

// ✅ Create a new history record
const createHistory = asyncWrapper(async (req, res, next) => {
  const { childId } = req.params; // Extract childId from URL params
  const { diagnosis, disease, treatment, notes, date, time, notesImage } =
    req.body;

  if (!diagnosis || !disease || !treatment || !date || !time) {
    return next(
      appError.create(
        "All required fields must be provided",
        400,
        httpStatusText.FAIL
      )
    );
  }

  const newHistory = new History({
    childId,
    diagnosis,
    disease,
    treatment,
    notes,
    date,
    time,
    notesImage: notesImage || null,
  });

  await newHistory.save();

  res.status(201).json({
    status: httpStatusText.SUCCESS,
    data: { history: newHistory },
  });
});

// ✅ Get all history records for a specific child
const getAllHistory = asyncWrapper(async (req, res, next) => {
  const { childId } = req.params;

  const history = await History.find({ childId }).populate(
    "childId",
    "name birthDate photo"
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
    data: history,
  });
});

// ✅ Get a single history record for a specific child
const getSingleHistory = asyncWrapper(async (req, res, next) => {
  const { childId, historyId } = req.params;

  const history = await History.findOne({ _id: historyId, childId }).populate(
    "childId",
    "name birthDate photo"
  );

  if (!history) {
    return next(
      appError.create("History record not found", 404, httpStatusText.FAIL)
    );
  }

  res.json({
    status: httpStatusText.SUCCESS,
    data: { history },
  });
});

// ✅ Update a history record
const updateHistory = asyncWrapper(async (req, res, next) => {
  const { childId, historyId } = req.params;
  const { diagnosis, disease, treatment, notes, date, time, notesImage } =
    req.body;

  const updatedHistory = await History.findOneAndUpdate(
    { _id: historyId, childId },
    { diagnosis, disease, treatment, notes, date, time, notesImage },
    { new: true, runValidators: true }
  );

  if (!updatedHistory) {
    return next(
      appError.create("History record not found", 404, httpStatusText.FAIL)
    );
  }

  res.json({
    status: httpStatusText.SUCCESS,
    data: { history: updatedHistory },
  });
});

// ✅ Delete a history record
const deleteHistory = asyncWrapper(async (req, res, next) => {
  const { childId, historyId } = req.params;

  const deletedHistory = await History.findOneAndDelete({
    _id: historyId,
    childId,
  });

  if (!deletedHistory) {
    return next(
      appError.create("History record not found", 404, httpStatusText.FAIL)
    );
  }

  res.json({
    status: httpStatusText.SUCCESS,
    message: "History record deleted successfully",
  });
});

module.exports = {
  createHistory,
  getAllHistory,
  getSingleHistory,
  updateHistory,
  deleteHistory,
};
