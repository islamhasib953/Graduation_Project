const express = require("express");
const { predictAsthma } = require("../controllers/predict.controller");

const router = express.Router();

router.post("/predict/asthma", predictAsthma);

module.exports = router;
