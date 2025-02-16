const UserVaccination = require("../models/UserVaccination.model");
const VaccineInfo = require("../models/vaccineInfo.model");
const Child = require("../models/child.model");
const asyncWrapper = require("../middlewares/asyncWrapper");
const appError = require("../utils/appError");
const httpStatusText = require("../utils/httpStatusText");
const { calculateDueDate } = require("../utils/calculateVaccinationDate");

// ✅ Admin creates a new vaccine and assigns it to all children
const createVaccinationForAllChildren = asyncWrapper(async (req, res, next) => {
  const {
    ageVaccine,
    originalSchedule,
    doseName,
    disease,
    dosageAmount,
    administrationMethod,
    description,
  } = req.body;

  if (
    !ageVaccine ||
    !(originalSchedule + 1) ||
    !doseName ||
    !disease ||
    !dosageAmount ||
    !administrationMethod ||
    !description
  ) {
    return next(
      appError.create(
        "All vaccine details are required.",
        400,
        httpStatusText.FAIL
      )
    );
  }

  const vaccineInfo = await VaccineInfo.create({
    ageVaccine,
    originalSchedule,
    doseName,
    disease,
    dosageAmount,
    administrationMethod,
    description,
  });
  const children = await Child.find();
  if (!children.length) {
    return next(
      appError.create(
        "No children found in the system.",
        404,
        httpStatusText.FAIL
      )
    );
  }

  await Promise.all(
    children.map(async (child) => {
      const dueDate = new Date(child.birthDate);
      dueDate.setMonth(dueDate.getMonth() + originalSchedule);
      const lastVaccination = await UserVaccination.findOne({
        childId: child._id,
      }).sort({ dueDate: -1 });
      let previousDelay = lastVaccination ? lastVaccination.delayDays : 0;
      dueDate.setDate(dueDate.getDate() + previousDelay);

      const userVaccination = new UserVaccination({
        childId: child._id,
        vaccineInfoId: vaccineInfo._id,
        dueDate,
      });
      await userVaccination.save();
    })
  );
  res.status(201).json({
    status: httpStatusText.SUCCESS,
    message: "Vaccination added successfully for all children.",
    data: vaccineInfo,
  });
});

// ✅ Get all vaccinations
const getAllVaccinations = asyncWrapper(async (req, res, next) => {
  const vaccinations = await UserVaccination.find()
    .populate("childId", "name birthDate gender")
    .populate("vaccineInfoId");

  if (!vaccinations.length) {
    return next(
      appError.create("No vaccinations found", 404, httpStatusText.FAIL)
    );
  }

  res.status(200).json({ status: httpStatusText.SUCCESS, data: vaccinations });
});

// ✅ Admin deletes a vaccination for all children
const deleteVaccinationForAllChildren = asyncWrapper(async (req, res, next) => {
  const { vaccinationId } = req.params;

  // Check if the vaccine exists
  const vaccine = await VaccineInfo.findById(vaccinationId);
  if (!vaccine) {
    return next(appError.create("Vaccine not found", 404, httpStatusText.FAIL));
  }

  // Delete all user vaccinations associated with this vaccine
  const deletedVaccinations = await UserVaccination.deleteMany({
    vaccineInfoId: vaccinationId,
  });

  // Delete the vaccine itself
  await VaccineInfo.findByIdAndDelete(vaccinationId);

  res.status(200).json({
    status: "success",
    message: "Vaccine and all associated records deleted successfully",
    deletedVaccinationsCount: deletedVaccinations.deletedCount,
  });
});

// ✅ Get all vaccinations for a specific child using childId
const getVaccinationsByChildId = asyncWrapper(async (req, res, next) => {
  const { childId } = req.params;
  const vaccinations = await UserVaccination.find({ childId })
    .populate("childId", "name birthDate gender")
    .populate("vaccineInfoId");

  if (!vaccinations.length) {
    return next(
      appError.create(
        "No vaccinations found for this child",
        404,
        httpStatusText.FAIL
      )
    );
  }

  res.status(200).json({
    status: httpStatusText.SUCCESS,
    data: vaccinations.map((vaccination) => ({
      _id: vaccination.vaccineInfoId._id,
      userVaccinationId: vaccination._id,
      ageVaccine: vaccination.vaccineInfoId.ageVaccine,
      doseName: vaccination.vaccineInfoId.doseName,
      disease: vaccination.vaccineInfoId.disease,
      dosageAmount: vaccination.vaccineInfoId.dosageAmount,
      administrationMethod: vaccination.vaccineInfoId.administrationMethod,
      description: vaccination.vaccineInfoId.description,
      dueDate: vaccination.dueDate,
    })),
  });
});

// ✅ updates a vaccination record
const updateUserVaccination = asyncWrapper(async (req, res, next) => {
  const { childId, vaccinationId } = req.params;
  const { actualDate, status, notes, image } = req.body;

  if (!actualDate || !status) {
    return next(
      appError.create(
        "Vaccination details are required",
        400,
        httpStatusText.FAIL
      )
    );
  }

  const vaccination = await UserVaccination.findOne({
    _id: vaccinationId,
    childId,
  }).populate("vaccineInfoId"); // ✅ Populate vaccine details

  if (!vaccination) {
    return next(
      appError.create("Vaccination record not found", 404, httpStatusText.FAIL)
    );
  }

  const child = await Child.findById(childId);

  if (!child || !child.birthDate) {
    return next(
      appError.create(
        "Child record not found or birthDate is missing",
        404,
        httpStatusText.FAIL
      )
    );
  }
  const dueDate = new Date(child.birthDate);
  dueDate.setMonth(
    dueDate.getMonth() + vaccination.vaccineInfoId.originalSchedule
  );
  // let calcduedate = new Date(child.birthDate);
  const delayDays = Math.max(
    0,
    Math.floor(
      (new Date(actualDate) - new Date(dueDate)) / (1000 * 60 * 60 * 24)
    ) + 1
  );

  vaccination.actualDate = new Date(actualDate);
  vaccination.delayDays = delayDays;
  vaccination.status = status;
  vaccination.notes = notes;
  vaccination.image = image || vaccination.image;
  await vaccination.save();

  const futureVaccinations = await UserVaccination.find({
    childId,
    dueDate: { $gt: vaccination.dueDate },
  })
    .populate("vaccineInfoId")
    .sort("dueDate");

  if (futureVaccinations.length > 0) {
    let accumulatedDelay = delayDays > 0 ? delayDays : 0;
    for (let future of futureVaccinations) {
      let dueDate = new Date(child.birthDate);
      dueDate.setMonth(
        dueDate.getMonth() + future.vaccineInfoId.originalSchedule
      );
      let newDueDate = new Date(dueDate);
      let lastnewdate = dueDate.setDate(
        newDueDate.getDate() + accumulatedDelay
      );
      let storeDueDate = new Date(lastnewdate);

      await UserVaccination.updateOne(
        { _id: future._id },
        {
          $set: {
            dueDate: storeDueDate,
            delayDays: accumulatedDelay,
          },
        }
      );

      accumulatedDelay = delayDays;
    }
  }

  res.status(200).json({
    status: "success",
    message: "Vaccination record and future due dates updated successfully",
    data: {
      vaccineInfoId: vaccination.vaccineInfoId._id,
      userVaccineId: vaccination._id,
      dueDate: vaccination.dueDate,
      actualDate: vaccination.actualDate,
      delayDays: vaccination.delayDays,
      status: vaccination.status,
      notes: vaccination.notes,
      image: vaccination.image,
    },
  });
});

// ✅ Get a specific user vaccination record
const getUserVaccination = asyncWrapper(async (req, res, next) => {
  const { vaccinationId } = req.params;

  const vaccination = await UserVaccination.findById(vaccinationId).populate(
    "childId vaccineInfoId"
  );
  if (!vaccination) {
    return next(
      appError.create("Vaccination record not found", 404, httpStatusText.FAIL)
    );
  }
  res.status(200).json({
    status: "success",
    message: "Vaccination record and future due dates updated successfully",
    data: {
      vaccineInfoId: vaccination.vaccineInfoId._id,
      userVaccineId: vaccination._id,
      dueDate: vaccination.dueDate,
      actualDate: vaccination.actualDate,
      delayDays: vaccination.delayDays,
      status: vaccination.status,
      notes: vaccination.notes,
      image: vaccination.image,
    },
  });
});

// ✅ Delete a specific user vaccination record
const deleteUserVaccination = asyncWrapper(async (req, res, next) => {
  const { vaccinationId } = req.params;

  // Find the vaccination record
  const vaccination = await UserVaccination.findById(vaccinationId);
  if (!vaccination) {
    return next(
      appError.create("Vaccination record not found", 404, httpStatusText.FAIL)
    );
  }

  // Delete the vaccination record
  await UserVaccination.findByIdAndDelete(vaccinationId);

  res.status(200).json({
    status: "success",
    message: "Vaccination record deleted successfully",
    data: null,
  });
});

module.exports = {
  createVaccinationForAllChildren,
  getAllVaccinations,
  deleteVaccinationForAllChildren,
  getVaccinationsByChildId,
  updateUserVaccination,
  getUserVaccination,
  deleteUserVaccination,
};
