// const SensorData = require("../models/sensorData.model");
// const Child = require("../models/child.model");
// const asyncWrapper = require("../middlewares/asyncWrapper");
// const httpStatusText = require("../utils/httpStatusText");
// const appError = require("../utils/appError");

// // ✅ Get all sensor data for a specific child
// const getAllSensorData = asyncWrapper(async (req, res, next) => {
//   const { childId } = req.params;
//   const userId = req.user.id; // جلب الـ userId من الـ JWT

//   // التحقق إن الـ childId ينتمي لليوزر اللي سجل دخول
//   const child = await Child.findOne({ _id: childId, parentId: userId });
//   if (!child) {
//     return next(
//       appError.create(
//         "Child not found or you are not authorized",
//         404,
//         httpStatusText.FAIL
//       )
//     );
//   }

//   const sensorData = await SensorData.find({ childId })
//     .sort({ createdAt: -1 })
//     .limit(50);

//   if (!sensorData.length) {
//     return next(
//       appError.create(
//         "No sensor data found for this child",
//         404,
//         httpStatusText.FAIL
//       )
//     );
//   }

//   res.json({
//     status: httpStatusText.SUCCESS,
//     data: sensorData,
//   });
// });

// // ✅ Get a single sensor data record for a specific child
// const getSingleSensorData = asyncWrapper(async (req, res, next) => {
//   const { childId, sensorDataId } = req.params;
//   const userId = req.user.id; // جلب الـ userId من الـ JWT

//   // التحقق إن الـ childId ينتمي لليوزر اللي سجل دخول
//   const child = await Child.findOne({ _id: childId, parentId: userId });
//   if (!child) {
//     return next(
//       appError.create(
//         "Child not found or you are not authorized",
//         404,
//         httpStatusText.FAIL
//       )
//     );
//   }

//   const sensorData = await SensorData.findOne({
//     _id: sensorDataId,
//     childId,
//   });

//   if (!sensorData) {
//     return next(
//       appError.create("Sensor data not found", 404, httpStatusText.FAIL)
//     );
//   }

//   res.json({
//     status: httpStatusText.SUCCESS,
//     data: sensorData,
//   });
// });

// module.exports = {
//   getAllSensorData,
//   getSingleSensorData,
// };


const SensorData = require("../models/sensorData.model");
const ValidatedSensorData = require("../models/validatedSensorData.model");
const Child = require("../models/child.model");
const asyncWrapper = require("../middlewares/asyncWrapper");
const httpStatusText = require("../utils/httpStatusText");
const appError = require("../utils/appError");

// Helper function to calculate age in years
const calculateAge = (birthDate) => {
  const today = new Date();
  const birth = new Date(birthDate);
  const ageInMilliseconds = today - birth;
  const ageInYears = ageInMilliseconds / (1000 * 60 * 60 * 24 * 365.25);
  return ageInYears;
};

// Helper function to validate sensor readings based on age
const validateReading = (reading, type, age) => {
  if (reading === null || reading === undefined) return false;
  if (type === "bpm") {
    if (age >= 0.5 && age < 1) return reading >= 90 && reading <= 120;
    if (age >= 1 && age < 3) return reading >= 70 && reading <= 110;
    if (age >= 3 && age < 5) return reading >= 65 && reading <= 100;
    if (age >= 5 && age <= 7) return reading >= 60 && reading <= 95;
    return false;
  }
  if (type === "spo2") return reading >= 90 && reading <= 100;
  if (type === "ir") {
    if (age >= 0.5 && age < 1) return reading >= 30 && reading <= 45;
    if (age >= 1 && age < 3) return reading >= 20 && reading <= 30;
    if (age >= 3 && age < 5) return reading >= 20 && reading <= 25;
    if (age >= 5 && age <= 7) return reading >= 14 && reading <= 22;
    return false;
  }
  if (type === "temperature") return reading >= 36.1 && reading <= 37.2;
  return true;
};

// Helper function to calculate average of valid readings
const calculateAverage = (readings) => {
  const validReadings = readings.filter((r) => r !== null && r !== undefined);
  if (validReadings.length === 0) return 0;
  return validReadings.reduce((sum, r) => sum + r, 0) / validReadings.length;
};

// Function to validate and store sensor data
const validateAndStoreSensorData = asyncWrapper(async (req, res, next) => {
  const { childId } = req.params;
  const userId = req.user.id;
  const io = req.app.get("io");

  const child = await Child.findOne({ _id: childId, parentId: userId });
  if (!child) {
    return next(
      appError.create(
        "Child not found or you are not authorized",
        404,
        httpStatusText.FAIL
      )
    );
  }

  const age = calculateAge(child.birthDate);
  if (age < 0.5 || age > 7) {
    return next(
      appError.create(
        "Child's age must be between 6 months and 7 years",
        400,
        httpStatusText.FAIL
      )
    );
  }

  const sensorData = await SensorData.find({ childId })
    .sort({ createdAt: -1 })
    .limit(10);

  if (!sensorData.length) {
    return next(
      appError.create(
        "No sensor data found for this child",
        404,
        httpStatusText.FAIL
      )
    );
  }

  let validatedRecord = { childId };
  let hasInvalidReadings = false;
  let allInvalid = true;

  const bpmReadings = sensorData.map((data) => data.bpm);
  const validBpmReadings = bpmReadings.filter((bpm) =>
    validateReading(bpm, "bpm", age)
  );
  validatedRecord.bpm = calculateAverage(validBpmReadings);
  if (validBpmReadings.length === 0) hasInvalidReadings = true;
  if (validBpmReadings.length > 0) allInvalid = false;

  const spo2Readings = sensorData.map((data) => data.spo2);
  const validSpo2Readings = spo2Readings.filter((spo2) =>
    validateReading(spo2, "spo2", age)
  );
  validatedRecord.spo2 = calculateAverage(validSpo2Readings);
  if (validSpo2Readings.length === 0) hasInvalidReadings = true;
  if (validSpo2Readings.length > 0) allInvalid = false;

  const irReadings = sensorData.map((data) => data.ir);
  const validIrReadings = irReadings.filter((ir) =>
    validateReading(ir, "ir", age)
  );
  validatedRecord.ir = calculateAverage(validIrReadings);
  if (validIrReadings.length === 0) hasInvalidReadings = true;
  if (validIrReadings.length > 0) allInvalid = false;

  const tempReadings = sensorData.map((data) => data.temperature);
  const validTempReadings = tempReadings.filter((temp) =>
    validateReading(temp, "temperature", age)
  );
  validatedRecord.temperature = calculateAverage(validTempReadings);
  if (validTempReadings.length === 0) hasInvalidReadings = true;
  if (validTempReadings.length > 0) allInvalid = false;

  const noValidationFields = [
    "accX",
    "accY",
    "accZ",
    "status",
    "gyroX",
    "gyroY",
    "gyroZ",
    "latitude",
    "longitude",
    "red",
  ];
  noValidationFields.forEach((field) => {
    const readings = sensorData.map((data) => data[field]);
    validatedRecord[field] = calculateAverage(readings);
  });

  validatedRecord.red = sensorData[0].red;
  validatedRecord.timestamp = sensorData[0].timestamp;
  validatedRecord.status = sensorData[0].status;

  if (allInvalid) validatedRecord.validationStatus = "Invalid";
  else if (hasInvalidReadings)
    validatedRecord.validationStatus = "PartiallyValidated";
  else validatedRecord.validationStatus = "Validated";

  const validatedData = new ValidatedSensorData(validatedRecord);
  await validatedData.save();
  io.emit("validatedSensorData", validatedData);

  res.json({
    status: httpStatusText.SUCCESS,
    data: validatedData,
  });
});

// Start validation every 30 seconds for all children
const startContinuousValidation = (io) => {
  setInterval(async () => {
    const children = await Child.find();
    for (const child of children) {
      await validateAndStoreSensorData(
        { params: { childId: child._id }, app: { get: () => io } },
        null,
        null
      );
    }
  }, 10000);
};

// API to get all sensor data
const getAllSensorData = asyncWrapper(async (req, res, next) => {
  const { childId } = req.params;
  const userId = req.user.id;

  const child = await Child.findOne({ _id: childId, parentId: userId });
  if (!child) {
    return next(
      appError.create(
        "Child not found or you are not authorized",
        404,
        httpStatusText.FAIL
      )
    );
  }

  const sensorData = await ValidatedSensorData.find({ childId })
    .sort({ createdAt: -1 })
    .limit(50);

  if (!sensorData.length) {
    return next(
      appError.create(
        "No validated sensor data found for this child",
        404,
        httpStatusText.FAIL
      )
    );
  }

  res.json({
    status: httpStatusText.SUCCESS,
    data: sensorData,
  });
});

// API to get a single sensor data record
const getSingleSensorData = asyncWrapper(async (req, res, next) => {
  const { childId, sensorDataId } = req.params;
  const userId = req.user.id;

  const child = await Child.findOne({ _id: childId, parentId: userId });
  if (!child) {
    return next(
      appError.create(
        "Child not found or you are not authorized",
        404,
        httpStatusText.FAIL
      )
    );
  }

  const sensorData = await ValidatedSensorData.findOne({
    _id: sensorDataId,
    childId,
  });

  if (!sensorData) {
    return next(
      appError.create(
        "Validated sensor data not found",
        404,
        httpStatusText.FAIL
      )
    );
  }

  res.json({
    status: httpStatusText.SUCCESS,
    data: sensorData,
  });
});

module.exports = {
  validateAndStoreSensorData,
  getAllSensorData,
  getSingleSensorData,
  startContinuousValidation,
};