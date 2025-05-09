const SensorData = require("../models/sensorData.model");
const ValidatedSensorData = require("../models/validatedSensorData.model");
const BabyActivity = require("../models/babyActivity.model");
const SleepQuality = require("../models/sleepQuality.model");
const Child = require("../models/child.model");
const {
  calculateActivity,
  calculateSleepQuality,
} = require("../utils/activityLogic");
const asyncWrapper = require("../middlewares/asyncWrapper");
const httpStatusText = require("../utils/httpStatusText");
const appError = require("../utils/appError");
const winston = require("winston");

const logger = winston.createLogger({
  level: "info",
  format: winston.format.combine(
    winston.format.timestamp(),
    winston.format.json()
  ),
  transports: [new winston.transports.Console()],
});

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
  if (reading === null || reading === undefined || reading < 0) return false;
  if (type === "bpm") {
    if (age >= 0.5 && age < 1) return reading >= 80 && reading <= 170;
    if (age >= 1 && age < 3) return reading >= 80 && reading <= 150;
    if (age >= 3 && age < 5) return reading >= 70 && reading <= 130;
    if (age >= 5 && age <= 7) return reading >= 65 && reading <= 120;
    return false;
  }
  if (type === "spo2") return reading >= 90 && reading <= 100;
  if (type === "ir") {
    if (age >= 0.5 && age < 1) return reading >= 30 && reading <= 55;
    if (age >= 1 && age < 3) return reading >= 20 && reading <= 30;
    if (age >= 3 && age < 5) return reading >= 20 && reading <= 25;
    if (age >= 5 && age <= 7) return reading >= 14 && reading <= 22;
    return false;
  }
  if (type === "temperature") return reading >= 36.1 && reading <= 37.9;
  return true;
};

// Helper function to calculate average of valid readings
const calculateAverage = (readings) => {
  const validReadings = readings.filter(
    (r) => r !== null && r !== undefined && r >= 0
  );
  if (validReadings.length === 0) return null;
  return validReadings.reduce((sum, r) => sum + r, 0) / validReadings.length;
};

// Function to validate and store sensor data
// const validateAndStoreSensorData = asyncWrapper(async (req, res, next) => {
//   const { childId } = req.params;
//   const userId = req.user.id;
//   const io = req.app.get("io");

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

//   const age = calculateAge(child.birthDate);
//   if (age < 0.5 || age > 7) {
//     return next(
//       appError.create(
//         "Child's age must be between 6 months and 7 years",
//         400,
//         httpStatusText.FAIL
//       )
//     );
//   }

//   const sensorData = await SensorData.find({ childId })
//     .sort({ createdAt: -1 })
//     .limit(10);

//   if (!sensorData.length) {
//     return next(
//       appError.create(
//         "No sensor data found for this child",
//         404,
//         httpStatusText.FAIL
//       )
//     );
//   }

//   let validatedRecord = { childId };
//   let hasInvalidReadings = false;
//   let allInvalid = true;

//   // التحقق من BPM
//   const bpmReadings = sensorData.map((data) => data.bpm);
//   const validBpmReadings = bpmReadings.filter((bpm) =>
//     validateReading(bpm, "bpm", age)
//   );
//   validatedRecord.bpm = calculateAverage(validBpmReadings);
//   if (validBpmReadings.length === 0) hasInvalidReadings = true;
//   if (validBpmReadings.length > 0) allInvalid = false;

//   // التحقق من SpO2
//   const spo2Readings = sensorData.map((data) => data.spo2);
//   const validSpo2Readings = spo2Readings.filter((spo2) =>
//     validateReading(spo2, "spo2", age)
//   );
//   validatedRecord.spo2 = calculateAverage(validSpo2Readings);
//   if (validSpo2Readings.length === 0) hasInvalidReadings = true;
//   if (validSpo2Readings.length > 0) allInvalid = false;

//   // التحقق من IR
//   const irReadings = sensorData.map((data) => data.ir);
//   const validIrReadings = irReadings.filter((ir) =>
//     validateReading(ir, "ir", age)
//   );
//   validatedRecord.ir = calculateAverage(validIrReadings);
//   if (validIrReadings.length === 0) hasInvalidReadings = true;
//   if (validIrReadings.length > 0) allInvalid = false;

//   // التحقق من Red
//   const redReadings = sensorData.map((data) => data.red);
//   const validRedReadings = redReadings.filter((red) =>
//     validateReading(red, "red", age)
//   );
//   validatedRecord.red = calculateAverage(validRedReadings);
//   if (validRedReadings.length === 0) hasInvalidReadings = true;
//   if (validRedReadings.length > 0) allInvalid = false;

//   // التحقق من Temperature
//   const tempReadings = sensorData.map((data) => data.temperature);
//   const validTempReadings = tempReadings.filter((temp) =>
//     validateReading(temp, "temperature", age)
//   );
//   validatedRecord.temperature = calculateAverage(validTempReadings);
//   if (validTempReadings.length === 0 && tempReadings.some((t) => t != null))
//     hasInvalidReadings = true;
//   if (validTempReadings.length > 0) allInvalid = false;

//   // الحقول بدون تحقق
//   const noValidationFields = [
//     "accX",
//     "accY",
//     "accZ",
//     "gyroX",
//     "gyroY",
//     "gyroZ",
//     "latitude",
//     "longitude",
//   ];
//   noValidationFields.forEach((field) => {
//     const readings = sensorData
//       .map((data) => data[field])
//       .filter((r) => r !== null && r !== undefined && !isNaN(r));
//     validatedRecord[field] =
//       readings.length > 0 ? calculateAverage(readings) : null;
//   });

//   // أحدث قيمة لـ status
//   validatedRecord.status = sensorData[0].status || "Unknown";

//   // تحديد حالة التحقق
//   if (allInvalid) validatedRecord.validationStatus = "Invalid";
//   else if (hasInvalidReadings)
//     validatedRecord.validationStatus = "PartiallyValidated";
//   else validatedRecord.validationStatus = "Validated";

//   const validatedData = new ValidatedSensorData(validatedRecord);
//   await validatedData.save();

//   // التحقق من وجود عملاء متصلين
//   if (io.engine.clientsCount > 0) {
//     io.emit("validatedSensorData", validatedData);
//   }

//   // حساب Baby Activity
//   try {
//     const activityData = calculateActivity(validatedData, age);
//     if (activityData.activityStage === "Insufficient Data") {
//       logger.warn(`Insufficient data for BabyActivity for child: ${childId}`);
//     } else {
//       const newActivity = new BabyActivity({ childId, ...activityData });
//       await newActivity.save();
//       if (io.engine.clientsCount > 0) {
//         io.emit("babyActivityUpdate", newActivity);
//       }
//       logger.info(`BabyActivity saved for child: ${childId}`, {
//         activityStage: activityData.activityStage,
//       });
//     }
//   } catch (error) {
//     logger.error(
//       `Error saving BabyActivity for child ${childId}:`,
//       error.message
//     );
//   }

//   // حساب Sleep Quality
//   try {
//     const sleepData = calculateSleepQuality(validatedData, age);
//     if (sleepData.sleepStage === "Insufficient Data") {
//       logger.warn(`Insufficient data for SleepQuality for child: ${childId}`);
//     } else {
//       const newSleep = new SleepQuality({ childId, ...sleepData });
//       await newSleep.save();
//       if (io.engine.clientsCount > 0) {
//         io.emit("sleepQualityUpdate", newSleep);
//       }
//       logger.info(`SleepQuality saved for child: ${childId}`, {
//         sleepStage: sleepData.sleepStage,
//       });
//     }
//   } catch (error) {
//     logger.error(
//       `Error saving SleepQuality for child ${childId}:`,
//       error.message
//     );
//   }

//   logger.info(`Validated sensor data saved for child: ${childId}`, {
//     validationStatus: validatedData.validationStatus,
//   });

//   res.json({
//     status: httpStatusText.SUCCESS,
//     data: validatedData,
//   });
// });

// Start validation every 30 seconds for active children
const startContinuousValidation = (io) => {
  setInterval(async () => {
    try {
      const oneHourAgo = new Date(Date.now() - 60 * 60 * 1000);
      const recentSensorData = await SensorData.find({
        createdAt: { $gte: oneHourAgo },
      }).distinct("childId");
      const children = await Child.find({ _id: { $in: recentSensorData } });

      for (const child of children) {
        try {
          const childId = child._id;
          const userId = child.parentId;

          const childData = await Child.findOne({
            _id: childId,
            parentId: userId,
          });
          if (!childData) {
            logger.error(`Child not found or unauthorized: ${childId}`);
            continue;
          }

          const age = calculateAge(childData.birthDate);
          if (age < 0.5 || age > 7) {
            logger.error(`Child's age out of range: ${childId}, Age: ${age}`);
            continue;
          }

          const sensorData = await SensorData.find({ childId })
            .sort({ createdAt: -1 })
            .limit(10);

          if (!sensorData.length) {
            logger.error(`No sensor data found for child: ${childId}`);
            continue;
          }

          let validatedRecord = { childId };
          let hasInvalidReadings = false;
          let allInvalid = true;

          // التحقق من BPM
          const bpmReadings = sensorData.map((data) => data.bpm);
          const validBpmReadings = bpmReadings.filter((bpm) =>
            validateReading(bpm, "bpm", age)
          );
          validatedRecord.bpm = calculateAverage(validBpmReadings);
          if (validBpmReadings.length === 0) hasInvalidReadings = true;
          if (validBpmReadings.length > 0) allInvalid = false;

          // التحقق من SpO2
          const spo2Readings = sensorData.map((data) => data.spo2);
          const validSpo2Readings = spo2Readings.filter((spo2) =>
            validateReading(spo2, "spo2", age)
          );
          validatedRecord.spo2 = calculateAverage(validSpo2Readings);
          if (validSpo2Readings.length === 0) hasInvalidReadings = true;
          if (validSpo2Readings.length > 0) allInvalid = false;

          // التحقق من IR
          const irReadings = sensorData.map((data) => data.ir);
          const validIrReadings = irReadings.filter((ir) =>
            validateReading(ir, "ir", age)
          );
          validatedRecord.ir = calculateAverage(validIrReadings);
          if (validIrReadings.length === 0) hasInvalidReadings = true;
          if (validIrReadings.length > 0) allInvalid = false;

          // التحقق من Red
          const redReadings = sensorData.map((data) => data.red);
          const validRedReadings = redReadings.filter((red) =>
            validateReading(red, "red", age)
          );
          validatedRecord.red = calculateAverage(validRedReadings);
          if (validRedReadings.length === 0) hasInvalidReadings = true;
          if (validRedReadings.length > 0) allInvalid = false;

          // التحقق من Temperature
          const tempReadings = sensorData.map((data) => data.temperature);
          const validTempReadings = tempReadings.filter((temp) =>
            validateReading(temp, "temperature", age)
          );
          validatedRecord.temperature = calculateAverage(validTempReadings);
          if (
            validTempReadings.length === 0 &&
            tempReadings.some((t) => t != null)
          )
            hasInvalidReadings = true;
          if (validTempReadings.length > 0) allInvalid = false;

          // الحقول بدون تحقق
          const noValidationFields = [
            "accX",
            "accY",
            "accZ",
            "gyroX",
            "gyroY",
            "gyroZ",
            "latitude",
            "longitude",
          ];
          noValidationFields.forEach((field) => {
            const readings = sensorData
              .map((data) => data[field])
              .filter((r) => r !== null && r !== undefined && !isNaN(r));
            validatedRecord[field] =
              readings.length > 0 ? calculateAverage(readings) : null;
          });

          // أحدث قيمة لـ status
          validatedRecord.status = sensorData[0].status || "Unknown";

          // تحديد حالة التحقق
          if (allInvalid) validatedRecord.validationStatus = "Invalid";
          else if (hasInvalidReadings)
            validatedRecord.validationStatus = "PartiallyValidated";
          else validatedRecord.validationStatus = "Validated";

          const validatedData = new ValidatedSensorData(validatedRecord);
          await validatedData.save();

          // التحقق من وجود عملاء متصلين
          if (io.engine.clientsCount > 0) {
            io.emit("validatedSensorData", validatedData);
          }

          // حساب Baby Activity
          try {
            const activityData = calculateActivity(validatedData, age);
            if (activityData.activityStage === "Insufficient Data") {
              logger.warn(
                `Insufficient data for BabyActivity for child: ${childId}`
              );
            } else {
              const newActivity = new BabyActivity({
                childId,
                ...activityData,
              });
              await newActivity.save();
              if (io.engine.clientsCount > 0) {
                io.emit("babyActivityUpdate", newActivity);
              }
              logger.info(`BabyActivity saved for child: ${childId}`, {
                activityStage: activityData.activityStage,
              });
            }
          } catch (error) {
            logger.error(
              `Error saving BabyActivity for child ${childId}:`,
              error.message
            );
          }

          // حساب Sleep Quality
          try {
            const sleepData = calculateSleepQuality(validatedData, age);
            if (sleepData.sleepStage === "Insufficient Data") {
              logger.warn(
                `Insufficient data for SleepQuality for child: ${childId}`
              );
            } else {
              const newSleep = new SleepQuality({ childId, ...sleepData });
              await newSleep.save();
              if (io.engine.clientsCount > 0) {
                io.emit("sleepQualityUpdate", newSleep);
              }
              logger.info(`SleepQuality saved for child: ${childId}`, {
                sleepStage: sleepData.sleepStage,
              });
            }
          } catch (error) {
            logger.error(
              `Error saving SleepQuality for child ${childId}:`,
              error.message
            );
          }

          logger.info(`Validated data saved for child: ${childId}`, {
            validationStatus: validatedData.validationStatus,
          });
        } catch (error) {
          logger.error(
            `Error validating data for child ${child._id}:`,
            error.message
          );
        }
      }
    } catch (error) {
      logger.error("Error in continuous validation:", error.message);
    }
  }, 11000);
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

// API to get Baby Activity records for the last 24 hours
const getActivitiesForLastDay = asyncWrapper(async (req, res, next) => {
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

  const oneDayAgo = new Date(Date.now() - 24 * 60 * 60 * 1000);
  const activities = await BabyActivity.find({
    childId,
    createdAt: { $gte: oneDayAgo },
  }).sort({ createdAt: -1 });

  res.json({
    status: httpStatusText.SUCCESS,
    data: activities,
  });
});

// API to get Sleep Quality records for the last 24 hours
const getSleepQualitiesForLastDay = asyncWrapper(async (req, res, next) => {
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

  const oneDayAgo = new Date(Date.now() - 24 * 60 * 60 * 1000);
  const sleepQualities = await SleepQuality.find({
    childId,
    createdAt: { $gte: oneDayAgo },
  }).sort({ createdAt: -1 });

  res.json({
    status: httpStatusText.SUCCESS,
    data: sleepQualities,
  });
});

module.exports = {
  // validateAndStoreSensorData,
  getAllSensorData,
  getSingleSensorData,
  startContinuousValidation,
  getActivitiesForLastDay,
  getSleepQualitiesForLastDay,
};
