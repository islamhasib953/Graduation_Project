const Medicine = require("../models/medicine.model");
const asyncWrapper = require("../middlewares/asyncWrapper");
const httpStatusText = require("../utils/httpStatusText");
const appError = require("../utils/appError");
const bcrypt = require("bcryptjs");
const genrateJWT = require("../utils/genrate.JWT");


// ✅ Create a new medicine
const createMedicine = asyncWrapper(async (req, res, next) => {
    const { name, description, days, times } = req.body;

    if (!name || !days || !times) {
        const error = appError.create("Name, days, and times are required", 400, httpStatusText.FAIL);
        return next(error);
    }

    const newMedicine = new Medicine({
        name,
        description,
        days,
        times
    });

    await newMedicine.save();
    res.status(201).json({
        status: httpStatusText.SUCCESS,
        data: { medicine: newMedicine },
    });
});


// ✅ Get all medicines (with pagination)
const getAllMedicines = asyncWrapper(async (req, res) => {
    const medicines = await Medicine.find({}, { __v: 0 });
    res.json({
        status: httpStatusText.SUCCESS,
        data: { medicines },
    });
});


// ✅ Update a medicine
const updateMedicine = asyncWrapper(async (req, res, next) => {
   const { medicineId } = req.params;

    const updatedMedicine = await Medicine.findByIdAndUpdate(medicineId, req.body, {
      new: true,
    });
    if (!updatedMedicine) {
        const error = appError.create("Medicine not found", 404, httpStatusText.FAIL);
        return next(error);
    }

    res.json({
        status: httpStatusText.SUCCESS,
        data: { medicine: updatedMedicine },
    });
});


// ✅ Delete a medicine
const deleteMedicine = asyncWrapper(async (req, res, next) => {
    const deletedMedicine = await Medicine.findByIdAndDelete(
      req.params.medicineId
    );

    if (!deletedMedicine) {
        const error = appError.create("Medicine not found", 404, httpStatusText.FAIL);
        return next(error);
    }

    res.json({
        status: httpStatusText.SUCCESS,
        message: "Medicine deleted successfully",
    });
});

module.exports = {
  getAllMedicines,
  createMedicine,
  updateMedicine,
  deleteMedicine,
};