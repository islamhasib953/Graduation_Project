const express = require("express");
const { predictDisease } = require("../controllers/predict.controller");

const router = express.Router();

router.post("/predict/:disease", predictDisease);

module.exports = router;
