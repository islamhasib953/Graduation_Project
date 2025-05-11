// const axios = require("axios");
// const winston = require("winston");
// const httpStatusText = require("../utils/httpStatusText");
// const AppError = require("../utils/appError");

// const FASTAPI_URL = process.env.FASTAPI_URL || "http://localhost:8001";

// // Configure logging
// const logger = winston.createLogger({
//   level: "info",
//   format: winston.format.combine(
//     winston.format.timestamp(),
//     winston.format.json()
//   ),
//   transports: [
//     new winston.transports.Console(), // دايمًا استخدم Console Transport
//   ],
// });

// // إضافة File Transport بس لو مش على Vercel
// // if (!process.env.VERCEL) {
// //   logger.add(new winston.transports.File({ filename: "logs/predict.log" }));
// // }

// // Required fields for each model
// const requiredFields = {
//   asthma: [
//     "Age",
//     "Gender",
//     "Ethnicity",
//     "EducationLevel",
//     "BMI",
//     "Smoking",
//     "PhysicalActivity",
//     "DietQuality",
//     "SleepQuality",
//     "PollutionExposure",
//     "PollenExposure",
//     "DustExposure",
//     "PetAllergy",
//     "FamilyHistoryAsthma",
//     "HistoryOfAllergies",
//     "Eczema",
//     "HayFever",
//     "GastroesophagealReflux",
//     "LungFunctionFEV1",
//     "LungFunctionFVC",
//     "Wheezing",
//     "ShortnessOfBreath",
//     "ChestTightness",
//     "Coughing",
//     "NighttimeSymptoms",
//     "ExerciseInduced",
//   ],
//   autism: [
//     "A1",
//     "A2",
//     "A3",
//     "A4",
//     "A5",
//     "A6",
//     "A7",
//     "A8",
//     "A9",
//     "A10",
//     "Age_Mons",
//     "Sex",
//     "Ethnicity",
//     "Jaundice",
//     "Family_mem_with_ASD",
//     "Who_completed_the_test",
//   ],
//   stroke: [
//     "gender",
//     "age",
//     "hypertension",
//     "heart_disease",
//     "ever_married",
//     "work_type",
//     "Residence_type",
//     "avg_glucose_level",
//     "bmi",
//     "smoking_status",
//   ],
// };

// const predictDisease = async (req, res, next) => {
//   try {
//     const { disease } = req.params;

//     // Validate disease
//     if (!["asthma", "autism", "stroke"].includes(disease)) {
//       logger.error(`Invalid disease requested: ${disease}`);
//       return next(new AppError(`Invalid disease: ${disease}`, 400));
//     }

//     // Validate input fields
//     const fields = requiredFields[disease];
//     for (const field of fields) {
//       if (!(field in req.body)) {
//         logger.error(`Missing required field: ${field} for ${disease}`);
//         return next(new AppError(`Missing required field: ${field}`, 400));
//       }
//     }

//     // Log the prediction request
//     logger.info(`Prediction request for ${disease}`, { input: req.body });

//     // Send request to FastAPI
//     const response = await axios.post(
//       `${FASTAPI_URL}/predict/${disease}`,
//       req.body
//     );

//     // Log successful prediction
//     logger.info(`Prediction successful for ${disease}`, {
//       response: response.data,
//     });

//     res.status(200).json({
//       status: httpStatusText.SUCCESS,
//       data: response.data,
//     });
//   } catch (error) {
//     logger.error(
//       `Failed to get prediction for ${req.params.disease}: ${error.message}`
//     );
//     return next(
//       new AppError(
//         `Failed to get prediction: ${error.message}`,
//         error.response?.status || 500
//       )
//     );
//   }
// };

// module.exports = { predictDisease };


const axios = require("axios");
const FormData = require("form-data"); // Added for file upload
const fs = require("fs");
const winston = require("winston");
const httpStatusText = require("../utils/httpStatusText");
const AppError = require("../utils/appError");

const FASTAPI_URL = process.env.FASTAPI_URL || "http://localhost:8001";

// Configure logging
const logger = winston.createLogger({
  level: "info",
  format: winston.format.combine(
    winston.format.timestamp(),
    winston.format.json()
  ),
  transports: [new winston.transports.Console()],
});

// Required fields for each model
const requiredFields = {
  asthma: [
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
  ],
  autism: [
    "A1",
    "A2",
    "A3",
    "A4",
    "A5",
    "A6",
    "A7",
    "A8",
    "A9",
    "A10",
    "Age_Mons",
    "Sex",
    "Ethnicity",
    "Jaundice",
    "Family_mem_with_ASD",
    "Who_completed_the_test",
  ],
  stroke: [
    "gender",
    "age",
    "hypertension",
    "heart_disease",
    "ever_married",
    "work_type",
    "Residence_type",
    "avg_glucose_level",
    "bmi",
    "smoking_status",
  ],
  chatbot: ["msg"],
};

const predictDisease = async (req, res, next) => {
  try {
    const { disease } = req.params;

    // Validate disease
    if (!["asthma", "autism", "stroke", "chatbot"].includes(disease)) {
      logger.error(`Invalid disease requested: ${disease}`);
      return next(new AppError(`Invalid disease: ${disease}`, 400));
    }

    // Validate input fields
    const fields = requiredFields[disease];
    for (const field of fields) {
      if (!(field in req.body) && disease !== "chatbot") {
        logger.error(`Missing required field: ${field} for ${disease}`);
        return next(new AppError(`Missing required field: ${field}`, 400));
      }
    }

    // Log the prediction request
    logger.info(`Prediction request for ${disease}`, { input: req.body });

    // Send request to FastAPI
    let endpoint = `${FASTAPI_URL}/predict/${disease}`;
    if (disease === "chatbot") {
      if (req.file && req.file.fieldname === "audio") {
        // Handle voice input (WAV file)
        const formData = new FormData();
        formData.append("file", fs.createReadStream(req.file.path), {
          filename: req.file.originalname,
        });
        endpoint = `${FASTAPI_URL}/medi_voice`; // Voice endpoint
        const response = await axios.post(endpoint, formData, {
          headers: formData.getHeaders(),
        });
        logger.info(`Prediction successful for ${disease} (voice)`, {
          response: response.data,
        });
        return res.status(200).json({
          status: httpStatusText.SUCCESS,
          data: response.data,
        });
      } else if (req.body.msg) {
        // Handle text input
        endpoint = `${FASTAPI_URL}/medi_text`; // Text endpoint
        const response = await axios.post(endpoint, req.body);
        logger.info(`Prediction successful for ${disease} (text)`, {
          response: response.data,
        });
        return res.status(200).json({
          status: httpStatusText.SUCCESS,
          data: response.data,
        });
      } else {
        logger.error(`No msg or audio file provided for chatbot`);
        return next(new AppError(`No message or audio file provided`, 400));
      }
    } else {
      const response = await axios.post(endpoint, req.body);
      logger.info(`Prediction successful for ${disease}`, {
        response: response.data,
      });
      return res.status(200).json({
        status: httpStatusText.SUCCESS,
        data: response.data,
      });
    }
  } catch (error) {
    logger.error(
      `Failed to get prediction for ${req.params.disease}: ${error.message}`
    );
    return next(
      new AppError(
        `Failed to get prediction: ${error.message}`,
        error.response?.status || 500
      )
    );
  }
};

module.exports = { predictDisease };
