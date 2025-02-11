const { body, validationResult } = require("express-validator");

const validationSchema = () => [
  body("name").notEmpty().withMessage("Medicine name is required"),
  body("days").isArray().withMessage("Days should be an array"),
  body("times").isArray().withMessage("Times should be an array"),
  (req, res, next) => {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({ status: "FAIL", errors: errors.array() });
    }
    next();
  },
];

module.exports = { validationSchema };
