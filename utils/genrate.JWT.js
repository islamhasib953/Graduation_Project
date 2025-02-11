const JWT = require('jsonwebtoken');

module.exports = async(payload)=>{
  const token = await JWT.sign(payload, process.env.TOKEN_SECRET_KEY, {expiresIn: '10min'});
  return token;
}

//payload like this ==> {email: newUser.email, id: newUser._id }