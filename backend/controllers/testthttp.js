const WatchData = require("../models/watchModel");

// 🟢 حفظ البيانات المستلمة من ESP
exports.saveWatchData = async (req, res) => {
  try {
    const { heartRate, temperature, spo2 } = req.body;

    // التحقق من صحة البيانات
    if (!heartRate || !temperature || !spo2) {
      return res
        .status(400)
        .json({ status: "error", message: "Missing data fields" });
    }

    // حفظ البيانات في MongoDB
    const newData = new WatchData({ heartRate, temperature, spo2 });
    await newData.save();

    res
      .status(201)
      .json({ status: "success", message: "Data saved successfully" });
  } catch (error) {
    res.status(500).json({ status: "error", message: error.message });
  }
};

// 🟢 جلب جميع البيانات
exports.getAllData = async (req, res) => {
  try {
    const data = await WatchData.find().sort({ timestamp: -1 }); // ترتيب تنازلي
    res.status(200).json({ status: "success", data });
  } catch (error) {
    res.status(500).json({ status: "error", message: error.message });
  }
};

// 🟢 جلب أحدث قراءة فقط
exports.getLatestData = async (req, res) => {
  try {
    const latestData = await WatchData.findOne().sort({ timestamp: -1 });
    res.status(200).json({ status: "success", data: latestData });
  } catch (error) {
    res.status(500).json({ status: "error", message: error.message });
  }
};
