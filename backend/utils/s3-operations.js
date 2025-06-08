const { PutObjectCommand } = require("@aws-sdk/client-s3");
const { s3Client } = require("../config/s3-credentials");

exports.putObject = async (file, fileName) => {
  try {
    const contentTypes = {
      "image/jpeg": "image/jpeg",
      "image/png": "image/png",
      "image/gif": "image/gif",
    };
    const fileType = file.mimetype || "image/jpeg"; // افتراضي إذا مفيش mimetype
    const contentType = contentTypes[fileType] || "application/octet-stream";

    const params = {
      Bucket: process.env.AWS_S3_BUCKET,
      Key: `${fileName}`,
      Body: file,
      ContentType: contentType,
    };

    const command = new PutObjectCommand(params);
    const data = await s3Client.send(command);

    if (data.$metadata.httpStatusCode !== 200) {
      return;
    }
    let url = `https://${process.env.AWS_S3_BUCKET}.s3.${process.env.AWS_REGION}.amazonaws.com/${params.Key}`;
    return { url, key: params.Key };
  } catch (err) {
    console.error(err);
  }
};

const { GetObjectCommand } = require("@aws-sdk/client-s3");
exports.getObject = async (key) => {
  try {
    const params = {
      Bucket: process.env.AWS_S3_BUCKET,
      Key: key,
    };
    const command = new GetObjectCommand(params);
    const data = await s3Client.send(command);
    console.log(data);
    return data; // إرجاع البيانات عشان تستخدميها لو محتاجة
  } catch (err) {
    console.error(err);
  }
};

const { DeleteObjectCommand } = require("@aws-sdk/client-s3");
exports.deleteObject = async (key) => {
  try {
    const params = {
      Bucket: process.env.AWS_S3_BUCKET,
      Key: key,
    };
    const command = new DeleteObjectCommand(params);
    const data = await s3Client.send(command);

    if (data.$metadata.httpStatusCode !== 204) {
      return { status: 400, data };
    }
    return { status: 204 };
  } catch (err) {
    console.error(err);
  }
};
