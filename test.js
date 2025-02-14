const UserVaccination = require("../models/UserVaccination.model");
const VaccineInfo = require("../models/vaccineInfo.model");
const Child = require("../models/child.model");
const asyncWrapper = require("../middlewares/asyncWrapper");
const appError = require("../utils/appError");
const httpStatusText = require("../utils/httpStatusText");

const {
  calculateDueDate,
  updateDelayDays,
} = require("../utils/calculateVaccinationDate");

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
  const { childId } = req.params;

  const vaccinations = await UserVaccination.find({ childId })
    .populate("childId", "name birthDate gender") // Get child details
    .populate(
      "vaccineInfoId",
      "originalSchedule doseName disease dosageAmount administrationMethod description"
    ) // Get vaccine details
    .select("childId dueDate actualDate delayDays vaccineInfoId"); // Select only required fields

  if (!vaccinations.length) {
    return next(
      appError.create(
        "No vaccinations found for this child",
        404,
        httpStatusText.FAIL
      )
    );
  }

  // Transform response to include only required fields
  const formattedData = vaccinations.map((vaccination) => ({
    vaccinationId: vaccination._id, // Added vaccinationId
    childId: vaccination.childId._id,
    childName: vaccination.childId.name,
    dueDate: vaccination.dueDate,
    actualDate: vaccination.actualDate || null, // In case actualDate is not present
    delayDays: vaccination.delayDays,
    originalSchedule: vaccination.vaccineInfoId.originalSchedule,
    doseName: vaccination.vaccineInfoId.doseName,
    disease: vaccination.vaccineInfoId.disease,
    dosageAmount: vaccination.vaccineInfoId.dosageAmount,
    administrationMethod: vaccination.vaccineInfoId.administrationMethod,
    description: vaccination.vaccineInfoId.description,
  }));

  res.status(200).json({
    status: httpStatusText.SUCCESS,
    data: formattedData,
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




const createUserVaccination = asyncWrapper(async (req, res, next) => {
  const { childId, vaccineInfoId } = req.params;
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

  const vaccination = await UserVaccination.findOne({ childId, vaccineInfoId });

  if (!vaccination) {
    return next(
      appError.create("Vaccination record not found", 404, httpStatusText.FAIL)
    );
  }

  const delay = Math.floor(
    (new Date(actualDate) - new Date(vaccination.dueDate)) /
      (1000 * 60 * 60 * 24)
  );

  vaccination.actualDate = actualDate;
  vaccination.delayDays = delay > 0 ? delay : 0;
  vaccination.status = status || "Pending";
  vaccination.notes = notes;
  vaccination.image = image || "uploads/vaccination.jpg";

  await vaccination.save();

  res.status(200).json({
    status: httpStatusText.SUCCESS,
    message: "Vaccination record updated successfully",
    data: vaccination,
  });
});



const updateUserVaccination = asyncWrapper(async (req, res, next) => {
  const { childId, vaccineInfoId } = req.params;
  const { actualDate, status, notes, image } = req.body;

  if (!actualDate || !status) {
    return next(appError.create("Vaccination details are required", 400, httpStatusText.FAIL));
  }

  const vaccination = await UserVaccination.findOne({ childId, vaccineInfoId });

  if (!vaccination) {
    return next(appError.create("Vaccination record not found", 404, httpStatusText.FAIL));
  }

  // ✅ حساب `delayDays` بناءً على الفرق بين `actualDate` و `dueDate`
  const delay = Math.floor((new Date(actualDate) - new Date(vaccination.dueDate)) / (1000 * 60 * 60 * 24));
  const appliedDelay = delay > 0 ? delay : 0; // تأكد أن التأخير لا يكون سالبًا

  // ✅ تحديث الجرعة الحالية
  vaccination.actualDate = new Date(actualDate);
  vaccination.delayDays = appliedDelay;
  vaccination.status = status || vaccination.status;
  vaccination.notes = notes || vaccination.notes;
  vaccination.image = image || vaccination.image;
  await vaccination.save();

  // ✅ جلب بيانات الطفل للحصول على `birthDate`
  const child = await Child.findById(childId);
  if (!child) {
    return next(appError.create("Child record not found", 404));
  }
  const birthDate = new Date(child.birthDate);

  // ✅ جلب جميع الجرعات المستقبلية
  const futureVaccinations = await UserVaccination.find({
    childId: vaccination.childId,
    dueDate: { $gt: vaccination.dueDate },
  })
    .populate("vaccineInfoId")
    .sort({ dueDate: 1 });

  console.log("Number of future vaccinations:", futureVaccinations.length);

  let accumulatedDelay = appliedDelay; // ✅ تعميم التأخير على كل الجرعات التالية

  for (let futureVaccination of futureVaccinations) {
    let originalSchedule = futureVaccination.vaccineInfoId?.originalSchedule || 1;

    let newDueDate = new Date(birthDate);
    newDueDate.setMonth(newDueDate.getMonth() + originalSchedule);
    newDueDate.setDate(newDueDate.getDate() + accumulatedDelay);

    console.log(`Updating dueDate for vaccination ${futureVaccination._id}:`, newDueDate);

    // ✅ تحديث `dueDate` و `delayDays` مباشرة في قاعدة البيانات
    await UserVaccination.findByIdAndUpdate(
      futureVaccination._id,
      {
        $set: {
          dueDate: newDueDate,
          delayDays: appliedDelay, // ✅ تعيين نفس التأخير لجميع الجرعات القادمة
        },
      },
      { new: true }
    );

    accumulatedDelay += appliedDelay; // ✅ إضافة التأخير إلى كل الجرعات التالية
  }

res.status(200).json({
  status: "success",
  message: "Vaccination record and future due dates updated successfully",
  data: vaccination,
});
});


// res.status(200).json({
//   status: "success",
//   message: "Vaccination record and future due dates updated successfully",
//   data: vaccination,
// });
// });






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
  createUserVaccination,
  updateUserVaccination,
  // deleteVaccination,
};




// {
//   "name": "MMR Vaccine",
//   "description": "A vaccine for measles, mumps, and rubella",
//   "ageInMonths": 12,
//   "dosesRequired": 2,
//   "doseIntervalDays": 28,
//   "sideEffects": ["Fever", "Mild rash"],
//   "manufacturer": "Pfizer",
//   "batchNumber": "MMR-12345",
//   "administeredBy": "Dr. Ahmed",
//   "dateGiven": "2025-02-14",
//   "nextDoseDate": "2025-03-14",
//   "childId": "65abf12345cde6789fgh0123"
// }
