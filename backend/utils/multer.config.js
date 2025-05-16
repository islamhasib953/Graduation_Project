const multer = require("multer");
const path = require("path");
const fs = require("fs");
const appError = require("./appError");

const storage = multer.diskStorage({
  destination: (req, file, cb) => {
    const uploadPath = path.join(__dirname, "..", "Uploads");
    if (!fs.existsSync(uploadPath)) {
      fs.mkdirSync(uploadPath, { recursive: true });
    }
    cb(null, uploadPath);
  },
  filename: (req, file, cb) => {
    const modelName = req.modelName || "default"; // اسم الموديل من الـ request
    const ext = file.mimetype.split("/")[1];
    cb(null, `${modelName}-${Date.now()}.${ext}`); // اسم الملف هيبقى مثل "child-169987654321.jpg"
  },
});

const fileFilter = (req, file, cb) => {
  const allowedTypes = /jpg|jpeg|png|gif|pdf|doc|docx/;
  const mimetype = file.mimetype.split("/")[1];
  if (allowedTypes.test(mimetype)) {
    cb(null, true);
  } else {
    cb(
      appError.create("Only images, PDFs, or documents are allowed", 400),
      false
    );
  }
};

const upload = multer({
  storage,
  fileFilter,
  limits: { fileSize: 10 * 1024 * 1024 }, // 10MB حد أقصى
});

module.exports = upload;
