const Medicine = require("../models/medicine.model");
const asyncWrapper = require("../middlewares/asyncWrapper");
const httpStatusText = require("../utils/httpStatusText");
const appError = require("../utils/appError");

// ✅ Create a new medicine for a specific child
const createMedicine = asyncWrapper(async (req, res, next) => {
  const { childId } = req.params; // Extract childId from URL params
  const { name, description, days, times } = req.body;

  if (!name || !days || !times) {
    return next(
      appError.create(
        "Name, days, and times are required",
        400,
        httpStatusText.FAIL
      )
    );
  }

  const newMedicine = new Medicine({
    childId,
    name,
    description,
    days,
    times,
  });

  await newMedicine.save();
  res.status(201).json({
    status: httpStatusText.SUCCESS,
    data: { medicine: newMedicine },
  });
});

// ✅ Get all medicines for a specific child
const getAllMedicines = asyncWrapper(async (req, res, next) => {
  const { childId } = req.params; // Assuming you pass childId in the URL

  const medicines = await Medicine.find({ childId }).select(
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

  const medicine = await Medicine.findOne({ _id: medicineId, childId }).select(
    "_id name description days times createdAt"
  );

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
  const { name, description, days, times } = req.body;

  const updatedMedicine = await Medicine.findOneAndUpdate(
    { _id: medicineId, childId },
    { name, description, days, times },
    { new: true, runValidators: true }
  ).select("_id name description days times createdAt");

  if (!updatedMedicine) {
    return next(
      appError.create("Medicine not found", 404, httpStatusText.FAIL)
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

  const deletedMedicine = await Medicine.findOneAndDelete({
    _id: medicineId,
    childId,
  });

  if (!deletedMedicine) {
    return next(
      appError.create("Medicine not found", 404, httpStatusText.FAIL)
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
