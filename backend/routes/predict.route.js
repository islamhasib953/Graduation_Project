const express = require("express");
const { predictDisease } = require("../controllers/predict.controller");

const router = express.Router();

// Dynamic route for all disease predictions
router.post("/predict/:disease", predictDisease);

module.exports = router;
