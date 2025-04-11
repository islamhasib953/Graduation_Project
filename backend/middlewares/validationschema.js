const { body } = require("express-validator");
const userRoles = require("../utils/userRoles");


// ✅ child validation
const validateChild = [
  body("name").notEmpty().withMessage("Name is required").trim(),
  body("gender").isIn(["Boy", "Girl"]).withMessage("Invalid gender"),
  body("heightAtBirth")
    .optional()
    .isFloat({ min: 0 })
    .withMessage("Height must be positive"),
  body("weightAtBirth")
    .optional()
    .isFloat({ min: 0 })
    .withMessage("Weight must be positive"),
  body("bloodType")
    .optional()
    .matches(/^(A|B|AB|O)[+-]$/)
    .withMessage("Invalid blood type"),
];

// ✅ history validation
const validateHistory = [
  body("diagnosis")
    .isLength({ min: 3 })
    .withMessage("Diagnosis must be at least 3 characters"),
  body("disease")
    .isLength({ min: 3 })
    .withMessage("Disease must be at least 3 characters"),
  body("treatment")
    .isLength({ min: 5 })
    .withMessage("Treatment must be at least 5 characters"),
  body("time").notEmpty().withMessage("Time is required"),
];


// ✅ medicine validation
const validateMedicine = [
  body("name").notEmpty().withMessage("Medicine name is required"),
  body("days").isArray().withMessage("Days must be an array"),
  body("times").isArray().withMessage("Times must be an array"),
];


// ✅ memory validation
const validateMemory = [
  body("description").notEmpty().withMessage("Description is required"),
  body("time").notEmpty().withMessage("Time is required"),
];


// ✅ vaccineInfo validation
const validateVaccineInfo = [
  body("originalSchedule").isInt({ min: 0 }).withMessage("Invalid schedule"),
  body("doseName").notEmpty().withMessage("Dose name is required"),
  body("disease").notEmpty().withMessage("Disease is required"),
  body("dosageAmount").notEmpty().withMessage("Dosage amount is required"),
  body("administrationMethod")
    .notEmpty()
    .withMessage("Administration method is required"),
  body("description").notEmpty().withMessage("Description is required"),
];


// ✅ vaccine validation
const validateUserVaccination = [
  body("status")
    .isIn(["Pending", "Taken", "Missed"])
    .withMessage("Invalid status"),
];


// ✅ user register validation
const validateRegister = [
  body("firstName")
    .isString()
    .withMessage("First name must be a string.")
    .isLength({ min: 2, max: 255 })
    .withMessage("First name must be between 2 and 255 characters.")
    .trim(),

  body("lastName")
    .isString()
    .withMessage("Last name must be a string.")
    .isLength({ min: 2, max: 255 })
    .withMessage("Last name must be between 2 and 255 characters.")
    .trim(),

  body("gender")
    .isIn(["Male", "Female"])
    .withMessage("Gender must be either Male or Female."),

  body("phone")
    .matches(/^01[0-2,5]\d{8}$/)
    .withMessage("Invalid Egyptian phone number format.")
    .trim(),

  body("address")
    .isString()
    .withMessage("Address must be a string.")
    .isLength({ min: 2, max: 255 })
    .withMessage("Address must be between 2 and 255 characters.")
    .trim(),

  body("email")
    .isEmail()
    .withMessage("Invalid email format.")
    .isLength({ min: 2, max: 255 })
    .withMessage("Email must be between 2 and 255 characters.")
    .normalizeEmail(),

  body("password")
    .isLength({ min: 6 })
    .withMessage("Password must be at least 6 characters long."),

  body("role")
    .optional()
    .isIn([userRoles.ADMIN, userRoles.DOCTOR, userRoles.PATIENT])
    .withMessage(
      `Role must be one of: ${userRoles.ADMIN}, ${userRoles.DOCTOR}, ${userRoles.PATIENT}`
    ),

  body("avatar").optional().isString().withMessage("Avatar must be a string."),
];


// ✅ user login validation
const validateLogin = [
  body("email").isEmail().withMessage("Invalid email format."),
  body("password").notEmpty().withMessage("Password is required."),
];


// ✅ update user validation
const validateUpdateUser = [
  body("firstName")
    .optional()
    .isString()
    .withMessage("First name must be a string.")
    .isLength({ min: 2, max: 255 })
    .withMessage("First name must be between 2 and 255 characters.")
    .trim(),

  body("lastName")
    .optional()
    .isString()
    .withMessage("Last name must be a string.")
    .isLength({ min: 2, max: 255 })
    .withMessage("Last name must be between 2 and 255 characters.")
    .trim(),

  body("gender")
    .optional()
    .isIn(["Male", "Female"])
    .withMessage("Gender must be either Male or Female."),

  body("phone")
    .optional()
    .matches(/^01[0-2,5]\d{8}$/)
    .withMessage("Invalid Egyptian phone number format.")
    .trim(),

  body("address")
    .optional()
    .isString()
    .withMessage("Address must be a string.")
    .isLength({ min: 2, max: 255 })
    .withMessage("Address must be between 2 and 255 characters.")
    .trim(),

  body("email")
    .optional()
    .isEmail()
    .withMessage("Invalid email format.")
    .isLength({ min: 2, max: 255 })
    .withMessage("Email must be between 2 and 255 characters.")
    .normalizeEmail(),

  body("password")
    .optional()
    .isLength({ min: 6 })
    .withMessage("Password must be at least 6 characters long."),

  body("avatar").optional().isString().withMessage("Avatar must be a string."),
];



module.exports = {
  validateChild,
  validateHistory,
  validateMedicine,
  validateMemory,
  validateVaccineInfo,
  validateUserVaccination,
  validateRegister,
  validateLogin,
  validateUpdateUser
};



