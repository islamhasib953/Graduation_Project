const mongoose = require("mongoose");
require("dotenv").config();

const connectDB = async () => {
  try {
    await mongoose.connect(
      process.env.DATA_BASE_URL.replace(
        "<DATABASENAME>",
        process.env.DATA_BASE_NAME
      ).replace("<PASSWORD>", process.env.DATA_BASE_PASSWORD)
    );
    console.log("✅ MongoDB connected");
  } catch (err) {
    console.error("🚨 MongoDB connection error:", err);
    process.exit(1);
  }
};

module.exports = connectDB;
 