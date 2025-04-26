const axios = require("axios");
const httpStatusText = require("../utils/httpStatusText");
const AppError = require("../utils/appError");

const FASTAPI_URL = process.env.FASTAPI_URL || "http://localhost:8000";

const predictAsthma = async (req, res, next) => {
  try {
    // Validate input
    const requiredFields = [
      "Age",
      "Gender",
      "Ethnicity",
      "EducationLevel",
      "BMI",
      "Smoking",
      "PhysicalActivity",
      "DietQuality",
      "SleepQuality",
      "PollutionExposure",
      "PollenExposure",
      "DustExposure",
      "PetAllergy",
      "FamilyHistoryAsthma",
      "HistoryOfAllergies",
      "Eczema",
      "HayFever",
      "GastroesophagealReflux",
      "LungFunctionFEV1",
      "LungFunctionFVC",
      "Wheezing",
      "ShortnessOfBreath",
      "ChestTightness",
      "Coughing",
      "NighttimeSymptoms",
      "ExerciseInduced",
    ];

    for (const field of requiredFields) {
      if (!(field in req.body)) {
        return next(new AppError(`Missing required field: ${field}`, 400));
      }
    }

    // Send request to FastAPI
    const response = await axios.post(
      `${FASTAPI_URL}/predict/asthma`,
      req.body
    );

    res.status(200).json({
      status: httpStatusText.SUCCESS,
      data: response.data,
    });
  } catch (error) {
    return next(
      new AppError(`Failed to get prediction: ${error.message}`, 500)
    );
  }
};

module.exports = { predictAsthma };
