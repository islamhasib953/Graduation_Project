const { v4: uuidv4 } = require("uuid");
const {
  putObject,
  getObject,
  deleteObject,
} = require("../utils/s3-operations");
const fs = require("fs");

exports.uploadToS3 = async (req, res, next) => {
  console.log("uploadToS3 started - req.files:", req.files); // Log 1
  let fileField = "avatar"; // Default
  if (req.modelName === "child") fileField = "photo";
  if (req.modelName === "history") fileField = "notesImage";
  if (req.modelName === "memory") fileField = "image";
  if (req.modelName === "UserVaccination") fileField = "image";
  if (req.modelName === "chat") fileField = "media"; // إضافة شرط لـ Chat
  if (!req.files || !req.files[fileField]) {
    console.log(`No ${fileField} uploaded, proceeding without S3 upload`); // Log 2
    return next();
  }

  const file = req.files[fileField];
  console.log(`File received (${fileField}):`, file); // Log 3
  const tempId = uuidv4(); // ID مؤقت
  const fileName = `${req.modelName}s/${tempId}/${Date.now()}-${file.name}`; // مسار يدعم أي نوع ملف
  try {
    console.log("Attempting to upload to S3 with filename:", fileName); // Log 4
    const fileData = fs.readFileSync(file.tempFilePath); // قراءة الملف من المسار المؤقت
    console.log("File data length from tempFilePath:", fileData.length);
    fs.writeFileSync("/tmp/test-upload.png", fileData); // كتابة البيانات لتأكيد (يمكن نعدلها لتدعم أنواع أخرى لاحقًا)
    console.log(
      "Test file size on disk:",
      fs.statSync("/tmp/test-upload.png").size
    );
    if (!Buffer.isBuffer(fileData) || fileData.length === 0) {
      throw new Error("File data is not a valid Buffer or is empty");
    }
    const { url, key } = await putObject(fileData, fileName); // إرسال Buffer مباشرة
    console.log("S3 Upload result - url:", url, "key:", key); // Log 5
    if (!url || !key) {
      throw new Error("Failed to upload media to S3");
    }
    req.s3Data = { url, key, tempId };
    console.log("req.s3Data set successfully:", req.s3Data); // Log 6
  } catch (err) {
    console.error("S3 Upload Error:", err); // Log 7
    return next(err);
  }
  next();
};

exports.getFromS3 = async (req, res, next) => {
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
      : "avatar"; // تحديد الحقل بدقة
  if (model && model[fieldName]) {
    const data = await getObject(model[fieldName].split("/").pop()); // استخراج Key من URL
    req.s3Data = { data };
  }
  next();
};

exports.deleteFromS3 = async (req, res, next) => {
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
      : "avatar"; // تحديد الحقل بدقة
  if (model && model[fieldName]) {
    const key = model[fieldName].split("/").pop(); // استخراج Key من URL
    await deleteObject(key);
  }
  next();
};
