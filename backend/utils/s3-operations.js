const { PutObjectCommand } = require("@aws-sdk/client-s3");
const { s3Client } = require("../config/s3-credentials");
const { PassThrough } = require("stream");

exports.putObject = async (fileData, fileName) => {
  try {
    const passThrough = new PassThrough();
    passThrough.end(fileData); // تحويل Buffer لـ Stream
    const params = {
      Bucket: process.env.AWS_S3_BUCKET,
      Key: `${fileName}`,
      Body: passThrough,
      ContentType: fileData.mimetype || "image/png",
    };

    const command = new PutObjectCommand(params);
    const data = await s3Client.send(command);

    if (data.$metadata.httpStatusCode !== 200) {
      return;
    }
    let url = `https://${process.env.AWS_S3_BUCKET}.s3.${process.env.AWS_REGION}.amazonaws.com/${params.Key}`;
    console.log(url);
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
