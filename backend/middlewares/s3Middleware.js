const { v4: uuidv4 } = require("uuid");
const {
  putObject,
  getObject,
  deleteObject,
} = require("../utils/s3-operations");

exports.uploadToS3 = async (req, res, next) => {
  console.log("uploadToS3 started - req.files:", req.files); // Log 1
  console.log("Model name:", req.modelName); // Log جديد: عرض اسم الموديل
  let fileField = "avatar"; // Default
  if (req.modelName === "child") fileField = "photo";
  if (req.modelName === "history") fileField = "notesImage";
  if (req.modelName === "memory") fileField = "image";
  if (req.modelName === "UserVaccination") fileField = "image";
  if (req.modelName === "chat") fileField = "media";

  console.log(`Determined file field: ${fileField}`); // Log جديد: عرض حقل الملف

  if (!req.files || !req.files[fileField]) {
    console.log(`No ${fileField} uploaded, proceeding without S3 upload`); // Log 2
    return next();
  }

  const file = req.files[fileField];
  console.log(`File received (${fileField}):`, {
    name: file.name,
    size: file.size,
    mimetype: file.mimetype,
  }); // Log 3 معاد صياغته
  const tempId = uuidv4();
  const fileName = `${req.modelName}s/${tempId}/${Date.now()}-${file.name}`;
  try {
    console.log("Attempting to upload to S3 with filename:", fileName); // Log 4
    const fileData = file.data; // Buffer مباشرة من express-fileupload
    console.log("File data length from file.data:", fileData.length); // Log 5
    if (!Buffer.isBuffer(fileData) || fileData.length === 0) {
      throw new Error("File data is not a valid Buffer or is empty");
    }

    // فحص إعدادات AWS
    console.log("Checking AWS credentials:", {
      accessKeyId: process.env.AWS_ACCESS_KEY_ID ? "Set" : "Not set",
      secretAccessKey: process.env.AWS_SECRET_ACCESS_KEY ? "Set" : "Not set",
      region: process.env.AWS_REGION || "Not set",
      bucket: process.env.AWS_BUCKET_NAME || "Not set",
    }); // Log جديد: فحص متغيرات البيئة

    const { url, key } = await putObject(fileData, fileName);
    console.log("S3 Upload result - url:", url, "key:", key); // Log 6
    if (!url || !key) {
      throw new Error("Failed to upload media to S3");
    }
    req.s3Data = { url, key, tempId };
    console.log("req.s3Data set successfully:", req.s3Data); // Log 7
  } catch (err) {
    console.error("S3 Upload Error:", {
      message: err.message,
      stack: err.stack,
    }); // Log 8 معاد صياغته
    return next(err);
  }
  next();
};

exports.getFromS3 = async (req, res, next) => {
  console.log("getFromS3 started - req.modelName:", req.modelName); // Log 9
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
  console.log(`Field name determined: ${fieldName}`); // Log 10
  if (model && model[fieldName]) {
    const key = model[fieldName].split("/").pop();
    console.log(`Fetching from S3 - key: ${key}`); // Log 11
    if (typeof getObject !== "function") {
      console.error("getObject is not a function - check import"); // Log 12
      return next(new Error("S3 getObject function is not defined"));
    }
    const data = await getObject(key);
    req.s3Data = { data };
    console.log("S3 data fetched successfully - data length:", data?.length); // Log 12 معدّل
  } else {
    console.log("No field or model data to fetch from S3"); // Log 13
  }
  next();
};

exports.deleteFromS3 = async (req, res, next) => {
  console.log("deleteFromS3 started - req.modelName:", req.modelName); // Log 14
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
  console.log(`Field name for deletion: ${fieldName}`); // Log 15
  if (model && model[fieldName]) {
    const key = model[fieldName].split("/").pop();
    console.log(`Deleting from S3 - key: ${key}`); // Log 16
    await deleteObject(key);
    console.log("S3 deletion completed"); // Log 17
  } else {
    console.log("No field or model data to delete from S3"); // Log 18
  }
  next();
};
