const axios = require("axios");
const httpStatusText = require("../utils/httpStatusText");

const predict = async (req, res) => {
  try {
    const { input } = req.body;
    if (!input || !Array.isArray(input)) {
      return res.status(400).json({
        status: httpStatusText.ERROR,
        message: "Invalid input: Expected an array",
      });
    }

    const response = await axios.post(
      process.env.FASTAPI_URL + "/predict",
      { input },
      { headers: { "X-API-Key": process.env.API_KEY } }
    );

    return res.status(200).json({
      status: httpStatusText.SUCCESS,
      data: response.data,
    });
  } catch (error) {
    return res.status(500).json({
      status: httpStatusText.ERROR,
      message: error.message || "Error connecting to model API",
    });
  }
};

module.exports = { predict };
