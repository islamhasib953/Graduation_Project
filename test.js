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
    originalSchedule,
    doseName,
    disease,
    dosageAmount,
    administrationMethod,
    description,
  } = req.body;

  if (
    !originalSchedule ||
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
    data: vaccinations,
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
  });
  if (!vaccination) {
    return next(
      appError.create("Vaccination record not found", 404, httpStatusText.FAIL)
    );
  }

  const delayDays = Math.max(
    0,
    Math.floor(
      (new Date(actualDate) - new Date(vaccination.dueDate)) /
        (1000 * 60 * 60 * 24)
    )
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
  }).sort("dueDate");
  // console.log(futureVaccinations);
  if (futureVaccinations.length > 0) {
    let accumulatedDelay = delayDays > 0 ? delayDays : 1;
    // let lastDueDate = new Date(vaccination.dueDate);

    for (let future of futureVaccinations) {
      let newDueDate = new Date(future.dueDate);
      console.log(newDueDate);
      let lastnewdate = newDueDate.setDate(
        newDueDate.getDate() + accumulatedDelay
      );
      let storeDueDate = new Date(lastnewdate);
      console.log(storeDueDate);
      console.log(future._id);
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
    data: vaccination,
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
    data: vaccination,
  });
});

module.exports = {
  createVaccinationForAllChildren,
  getVaccinationsByChildId,
  getAllVaccinations,
  updateUserVaccination,
  getUserVaccination,
};

//راجع جزء جزء واشوف ال response وكمان اظبط الداتا اللى انا محتاجها فقط
