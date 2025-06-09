const { PutObjectCommand } = require("@aws-sdk/client-s3");
const { s3Client } = require("../config/s3-credentials");

exports.putObject = async (fileData, fileName) => {
  try {
    console.log("putObject started - fileData length:", fileData.length); // Log 1
    const params = {
      Bucket: process.env.AWS_S3_BUCKET,
      Key: `${fileName}`,
      Body: fileData,
      ContentType: fileData.mimetype || "image/jpeg", // استخدام mimetype من الملف
    };
    console.log("S3 params prepared:", params); // Log 2
    const command = new PutObjectCommand(params);
    const data = await s3Client.send(command);
    console.log("S3 response metadata:", data.$metadata); // Log 3
    if (data.$metadata.httpStatusCode !== 200) {
      console.log("S3 upload failed - status not 200"); // Log 4
      return;
    }
    let url = `https://${process.env.AWS_S3_BUCKET}.s3.${process.env.AWS_REGION}.amazonaws.com/${params.Key}`;
    console.log("S3 upload successful - URL:", url); // Log 5
    return { url, key: params.Key };
  } catch (err) {
    console.error("putObject Error:", err); // Log 6
  }
};

const { GetObjectCommand } = require("@aws-sdk/client-s3");
exports.getObject = async (key) => {
  try {
    console.log("getObject started - key:", key); // Log 7
    const params = {
      Bucket: process.env.AWS_S3_BUCKET,
      Key: key,
    };
    console.log("S3 get params:", params); // Log 8
    const command = new GetObjectCommand(params);
    const data = await s3Client.send(command);
    console.log("S3 get response:", data); // Log 9
    return data;
  } catch (err) {
    console.error("getObject Error:", err); // Log 10
  }
};

const { DeleteObjectCommand } = require("@aws-sdk/client-s3");
exports.deleteObject = async (key) => {
  try {
    console.log("deleteObject started - key:", key); // Log 11
    const params = {
      Bucket: process.env.AWS_S3_BUCKET,
      Key: key,
    };
    console.log("S3 delete params:", params); // Log 12
    const command = new DeleteObjectCommand(params);
    const data = await s3Client.send(command);
    console.log("S3 delete response:", data.$metadata); // Log 13
    if (data.$metadata.httpStatusCode !== 204) {
      console.log("S3 delete failed - status not 204"); // Log 14
      return { status: 400, data };
    }
    console.log("S3 delete successful"); // Log 15
    return { status: 204 };
  } catch (err) {
    console.error("deleteObject Error:", err); // Log 16
  }
};
