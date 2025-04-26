const SensorData = require("../models/sensorData.model");
const Child = require("../models/child.model");
const asyncWrapper = require("../middlewares/asyncWrapper");
const httpStatusText = require("../utils/httpStatusText");
const appError = require("../utils/appError");

// ✅ Get all sensor data for a specific child
const getAllSensorData = asyncWrapper(async (req, res, next) => {
  const { childId } = req.params;
  const userId = req.user.id; // جلب الـ userId من الـ JWT

  // التحقق إن الـ childId ينتمي لليوزر اللي سجل دخول
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

  const sensorData = await SensorData.find({ childId })
    .sort({ createdAt: -1 })
    .limit(50)
    .select(
      "childId temperature heartRate spo2 latitude longitude gyroX gyroY gyroZ timestamp createdAt"
    );

  if (!sensorData.length) {
    return next(
      appError.create(
        "No sensor data found for this child",
        404,
        httpStatusText.FAIL
      )
    );
  }

  res.json({
    status: httpStatusText.SUCCESS,
    data: sensorData.map((data) => ({
      _id: data._id,
      childId: data.childId,
      temperature: data.temperature,
      heartRate: data.heartRate,
      spo2: data.spo2,
      latitude: data.latitude,
      longitude: data.longitude,
      gyroX: data.gyroX,
      gyroY: data.gyroY,
      gyroZ: data.gyroZ,
      timestamp: data.timestamp,
      createdAt: data.createdAt,
    })),
  });
});

// ✅ Get a single sensor data record for a specific child
const getSingleSensorData = asyncWrapper(async (req, res, next) => {
  const { childId, sensorDataId } = req.params;
  const userId = req.user.id; // جلب الـ userId من الـ JWT

  // التحقق إن الـ childId ينتمي لليوزر اللي سجل دخول
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

  const sensorData = await SensorData.findOne({
    _id: sensorDataId,
    childId,
  }).select(
    "childId temperature heartRate spo2 latitude longitude gyroX gyroY gyroZ timestamp createdAt"
  );

  if (!sensorData) {
    return next(
      appError.create("Sensor data not found", 404, httpStatusText.FAIL)
    );
  }

  res.json({
    status: httpStatusText.SUCCESS,
    data: {
      _id: sensorData._id,
      childId: sensorData.childId,
      temperature: sensorData.temperature,
      heartRate: sensorData.heartRate,
      spo2: sensorData.spo2,
      latitude: sensorData.latitude,
      longitude: sensorData.longitude,
      gyroX: sensorData.gyroX,
      gyroY: sensorData.gyroY,
      gyroZ: sensorData.gyroZ,
      timestamp: sensorData.timestamp,
      createdAt: sensorData.createdAt,
    },
  });
});

module.exports = {
  getAllSensorData,
  getSingleSensorData,
};
