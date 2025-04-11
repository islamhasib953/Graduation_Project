const SensorData = require("../models/SensorData");
const { spawn } = require("child_process");

let pendingReadings = []; // Queue for unconfirmed abnormal readings
let confirmedAbnormalPattern = false; // Flag to confirm abnormal pattern

async function processSensorData(data) {
  const lastReadings = await SensorData.find().sort({ timestamp: -1 }).limit(5);
  if (lastReadings.length === 0) return data; // Accept the first reading without comparison

  return new Promise((resolve, reject) => {
    // Run AI validation script
    const pythonProcess = spawn("python3", [
      "ai/validate.py",
      JSON.stringify(data),
      JSON.stringify(lastReadings),
    ]);

    pythonProcess.stdout.on("data", (output) => {
      const isValid = output.toString().trim() === "1"; // AI returns "1" for valid, "0" for abnormal

      if (isValid) {
        pendingReadings = []; // Clear any unconfirmed abnormal readings
        confirmedAbnormalPattern = false;
        resolve(data);
      } else {
        pendingReadings.push(data);

        if (pendingReadings.length >= 3) {
          const allSame = pendingReadings.every(
            (d) => JSON.stringify(d) === JSON.stringify(pendingReadings[0])
          );

          if (allSame) {
            console.log(
              "📌 3 consecutive abnormal readings with the same pattern detected. Storing data."
            );
            confirmedAbnormalPattern = true;
            resolve(pendingReadings.shift()); // Store the first unconfirmed reading
          } else {
            console.log(
              "⚠️ Inconsistent abnormal readings detected. Discarding all."
            );
            pendingReadings = []; // Reset queue
            confirmedAbnormalPattern = false;
            resolve(null);
          }
        } else {
          console.log(
            `⚠️ Abnormal data detected, waiting for ${
              3 - pendingReadings.length
            } more confirmations.`
          );
          resolve(null);
        }
      }
    });

    pythonProcess.stderr.on("data", (error) => {
      console.error("❌ AI Model Error:", error.toString());
      reject(error);
    });
  });
}

module.exports = processSensorData;
