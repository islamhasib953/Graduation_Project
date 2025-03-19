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
      },
    });
});


// ✅ Get all history records for a specific child
const getAllHistory = asyncWrapper(async (req, res, next) => {
  const { childId } = req.params;

  const history = await History.find({ childId }).select(
    "diagnosis disease treatment date childId"
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
  // res.json({
  //   status: httpStatusText.SUCCESS,
  //   data: history.map((record) => ({
  //     _id: record._id, // Child's ID
  //     diagnosis: record.diagnosis,
  //     disease: record.disease,
  //     treatment: record.treatment,
  //     notes: record.notes,
  //     date: record.date,
  //     time: record.time,
  //     notesImage: record.notes
  //   })),
  // });
  res.json({
    status: httpStatusText.SUCCESS,
    data: history.map((record) => ({
      _id: record._id,
      diagnosis: record.diagnosis,
      disease: record.disease,
      treatment: record.treatment,
      notes: record.notes || "No notes available", // إذا لم تكن موجودة تعطي قيمة افتراضية
      notesImage: record.notesImage || "No image available",
      date: record.date,
      time: record.time || "No time recorded",
    })),
  });
});


// ✅ Get a single history record for a specific child
const getSingleHistory = asyncWrapper(async (req, res, next) => {
  const { childId, historyId } = req.params;

  const history = await History.findOne({ _id: historyId, childId }).select(
    "_id diagnosis disease treatment notes notesImage date time"
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
    },
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


// ✅ Filter history records using query parameters
const filterHistory = asyncWrapper(async (req, res, next) => {
  const { childId } = req.params;
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

  // if (doctor) {
  //   query.doctor = { $regex: doctor, $options: "i" };
  // }

  if (fromDate && toDate) {
    query.date = { $gte: new Date(fromDate), $lte: new Date(toDate) };
  }

  let sortOption = { date: -1 };
  if (sortBy === "oldest") {
    sortOption = { date: 1 };
  }

  const history = await History.find(query)
    .sort(sortOption)
    .select("_id diagnosis disease treatment date");

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
