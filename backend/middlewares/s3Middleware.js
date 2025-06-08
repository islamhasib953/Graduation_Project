const {
  putObject,
  getObject,
  deleteObject,
} = require("../utils/s3-operations");

exports.uploadToS3 = async (req, res, next) => {
  if (!req.file) return next();

  const fileName = `avatars/${req.user.id}/${Date.now()}-${
    req.file.originalname
  }`;
  const { url, key } = await putObject(req.file.buffer, fileName);
  req.s3Data = { url, key };
  next();
};

exports.getFromS3 = async (req, res, next) => {
  const modelName = req.modelName || "user";
  const model = req[modelName];
  if (model && model.avatar) {
    const data = await getObject(model.avatar.split("/").pop()); // استخراج Key من URL
    req.s3Data = { data };
  }
  next();
};

exports.deleteFromS3 = async (req, res, next) => {
  const modelName = req.modelName || "user";
  const model = req[modelName];
  if (model && model.avatar) {
    const key = model.avatar.split("/").pop(); // استخراج Key من URL
    await deleteObject(key);
  }
  next();
};
