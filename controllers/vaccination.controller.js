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

  // ✅ إنشاء سجل جديد في VaccineInfo بدون `childId`
  const vaccineInfo = await VaccineInfo.create({
    originalSchedule,
    doseName,
    disease,
    dosageAmount,
    administrationMethod,
    description,
  });

  // ✅ جلب جميع الأطفال المسجلين
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

  // ✅ إنشاء تطعيمات لكل طفل
  await Promise.all(
    children.map(async (child) => {
      const userVaccination = new UserVaccination({
        childId: child._id,
        vaccineInfoId: vaccineInfo._id,
      });

      await calculateDueDate.call(userVaccination, () => {});
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
  const { childId } = req.params; // استخراج childId من الطلب

  const vaccinations = await UserVaccination.find({ childId })
    .populate("childId", "name birthDate gender") // Populate child details
    .populate("vaccineInfoId"); // Populate all vaccine details

  if (!vaccinations.length) {
    return next(
      appError.create("No vaccinations found for this child", 404, httpStatusText.FAIL)
    );
  }

  res.status(200).json({
    status: httpStatusText.SUCCESS,
    data: vaccinations,
  });
});




// ✅ Get all vaccinations with child and vaccine details, including dueDate from UserVaccination
const getAllVaccinations = asyncWrapper(async (req, res, next) => {
  const vaccinations = await UserVaccination.find()
    .populate("childId", "name birthDate gender") // Populate child details
    .populate("vaccineInfoId"); // Populate all vaccine details

  if (!vaccinations.length) {
    return next(
      appError.create("No vaccinations found", 404, httpStatusText.FAIL)
    );
  }

  res.status(200).json({
    status: httpStatusText.SUCCESS,
    data: vaccinations,
  });
});

// ✅ Update actual vaccination date and adjust future vaccinations if delayed
const updateActualDate = asyncWrapper(async (req, res, next) => {
  const { vaccinationId } = req.params;
  const { actualDate } = req.body;

  if (!actualDate) {
    return next(
      appError.create("Actual date is required", 400, httpStatusText.FAIL)
    );
  }

  const vaccination = await UserVaccination.findById(vaccinationId);
  if (!vaccination) {
    return next(
      appError.create("Vaccination not found", 404, httpStatusText.FAIL)
    );
  }

  // Calculate delay in days
  const delay = Math.floor(
    (new Date(actualDate) - new Date(vaccination.dueDate)) /
      (1000 * 60 * 60 * 24)
  );

  if (delay > 0) {
    vaccination.delayDays = delay;
  }

  vaccination.actualDate = actualDate;
  await vaccination.save();

  res.json({
    status: httpStatusText.SUCCESS,
    data: vaccination,
  });
});

// ❌ Prevent vaccination deletion (only admin can delete)
const deleteVaccination = asyncWrapper(async (req, res, next) => {
  return next(
    appError.create(
      "Vaccination deletion is not allowed",
      403,
      httpStatusText.FAIL
    )
  );
});

module.exports = {
  createVaccinationForAllChildren,
  getVaccinationsByChildId,
  getAllVaccinations,
  // updateActualDate,
  // deleteVaccination,
};
