const JWT = require("jsonwebtoken");

module.exports = async (payload, expiresIn) => {
  return JWT.sign(payload, process.env.TOKEN_SECRET_KEY, { expiresIn });
};


