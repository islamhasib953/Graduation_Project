const { v4: uuidv4 } = require("uuid");
const {
  putObject,
  getObject,
  deleteObject,
} = require("../utils/s3-operations");

exports.uploadToS3 = async (req, res, next) => {
  console.log("uploadToS3 started - req.files:", req.files);
  console.log("Model name:", req.modelName);
  let fileField = "avatar";
  if (req.modelName === "child") fileField = "photo";
  if (req.modelName === "history") fileField = "notesImage";
  if (req.modelName === "memory") fileField = "image";
  if (req.modelName === "UserVaccination") fileField = "image";
  if (req.modelName === "chat") fileField = "media";

  console.log(`Determined file field: ${fileField}`);

  if (!req.files || !req.files[fileField]) {
    console.log(`No ${fileField} uploaded, proceeding without S3 upload`);
    return next();
  }

  const file = req.files[fileField];
  console.log(`File received (${fileField}):`, {
    name: file.name,
    size: file.size,
    mimetype: file.mimetype,
  });
  const tempId = uuidv4();
  const fileName = `${req.modelName}s/${tempId}/${Date.now()}-${file.name}`;
  try {
    console.log("Attempting to upload to S3 with filename:", fileName);
    const fileData = file.data;
    console.log("File data length from file.data:", fileData.length);
    if (!Buffer.isBuffer(fileData) || fileData.length === 0) {
      throw new Error("File data is not a valid Buffer or is empty");
    }

    console.log("Checking AWS credentials:", {
      accessKeyId: process.env.AWS_ACCESS_KEY_ID ? "Set" : "Not set",
      secretAccessKey: process.env.AWS_SECRET_ACCESS_KEY ? "Set" : "Not set",
      region: process.env.AWS_REGION || "Not set",
      bucket: process.env.AWS_BUCKET_NAME || "Not set",
    });

    const { url, key } = await putObject(fileData, fileName);
    console.log("S3 Upload result - url:", url, "key:", key);
    if (!url || !key) {
      throw new Error("Failed to upload media to S3");
    }
    req.s3Data = { url, key, tempId };
    console.log("req.s3Data set successfully:", req.s3Data);
  } catch (err) {
    console.error("S3 Upload Error:", {
      message: err.message,
      stack: err.stack,
    });
    return next(err);
  }
  next();
};

exports.getFromS3 = async (req, res, next) => {
  console.log("getFromS3 started - req.modelName:", req.modelName);
  const modelName = req.modelName || "user";
  const model = req[modelName];
  const fieldName =
    modelName === "child"
      ? "photo"
      : modelName === "history"
      ? "notesImage"
      : modelName === "memory"
      ? "image"
      : modelName === "UserVaccination"
      ? "image"
      : modelName === "chat"
      ? "media"
      : "avatar";
  console.log(`Field name determined: ${fieldName}`);
  if (model && model[fieldName]) {
    const key = model[fieldName].split("/").pop();
    console.log(`Fetching from S3 - key: ${key}`);
    if (typeof getObject !== "function") {
      console.error("getObject is not a function - check import");
      return next(new Error("S3 getObject function is not defined"));
    }
    const data = await getObject(key);
    req.s3Data = { data };
    console.log("S3 data fetched successfully - data length:", data?.length);
  } else {
    console.log("No field or model data to fetch from S3");
  }
  next();
};

exports.deleteFromS3 = async (req, res, next) => {
  console.log("deleteFromS3 started - req.modelName:", req.modelName);
  const modelName = req.modelName || "user";
  const model = req[modelName];
  const fieldName =
    modelName === "child"
      ? "photo"
      : modelName === "history"
      ? "notesImage"
      : modelName === "memory"
      ? "image"
      : modelName === "UserVaccination"
      ? "image"
      : modelName === "chat"
      ? "media"
      : "avatar";
  console.log(`Field name for deletion: ${fieldName}`);
  if (model && model[fieldName]) {
    const key = model[fieldName].split("/").pop();
    console.log(`Deleting from S3 - key: ${key}`);
    await deleteObject(key);
    console.log("S3 deletion completed");
  } else {
    console.log("No field or model data to delete from S3");
  }
  next();
};
