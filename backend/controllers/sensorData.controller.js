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
    .limit(50);

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
    data: sensorData,
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
  });

  if (!sensorData) {
    return next(
      appError.create("Sensor data not found", 404, httpStatusText.FAIL)
    );
  }

  res.json({
    status: httpStatusText.SUCCESS,
    data: sensorData,
  });
});

module.exports = {
  getAllSensorData,
  getSingleSensorData,
};
