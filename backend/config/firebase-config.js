// const admin = require("firebase-admin");
// const dotenv = require("dotenv");
// const path = require("path");

// dotenv.config();

// let serviceAccount;

// // التحقق مما إذا كان التطبيق يعمل محليًا (باستخدام FIREBASE_CREDENTIALS_PATH)
// if (process.env.FIREBASE_CREDENTIALS_PATH) {
//   try {
//     const absolutePath = path.resolve(
//       __dirname,
//       process.env.FIREBASE_CREDENTIALS_PATH
//     );
//     console.log("Loading Firebase credentials from:", absolutePath);
//     serviceAccount = require(absolutePath);
//   } catch (error) {
//     console.error("Error loading Firebase credentials file:", error);
//     throw new Error("Failed to load Firebase credentials file");
//   }
// } else {
//   // استخدام متغيرات البيئة (للنشر على Vercel)
//   console.log("Using environment variables for Firebase credentials");
//   serviceAccount = {
//     type: process.env.FIREBASE_TYPE,
//     project_id: process.env.FIREBASE_PROJECT_ID,
//     private_key_id: process.env.FIREBASE_PRIVATE_KEY_ID,
//     private_key: process.env.FIREBASE_PRIVATE_KEY.replace(/\\n/g, "\n"), // تحويل \n النصية إلى فواصل أسطر فعلية
//     client_email: process.env.FIREBASE_CLIENT_EMAIL,
//     client_id: process.env.FIREBASE_CLIENT_ID,
//     auth_uri: process.env.FIREBASE_AUTH_URI,
//     token_uri: process.env.FIREBASE_TOKEN_URI,
//     auth_provider_x509_cert_url:
//       process.env.FIREBASE_AUTH_PROVIDER_X509_CERT_URL,
//     client_x509_cert_url: process.env.FIREBASE_CLIENT_X509_CERT_URL,
//     universe_domain: process.env.FIREBASE_UNIVERSE_DOMAIN,
//   };
//   console.log(
//     "FIREBASE_PRIVATE_KEY (after replacement):",
//     serviceAccount.private_key
//   );
// }

// // تهيئة Firebase Admin SDK
// admin.initializeApp({
//   credential: admin.credential.cert(serviceAccount),
// });

// const sendPushNotification = async (fcmToken, title, body, data = {}) => {
//   if (!fcmToken) {
//     console.error("No FCM token provided");
//     return;
//   }

//   const message = {
//     notification: {
//       title,
//       body,
//     },
//     data,
//     token: fcmToken,
//   };

//   try {
//     await admin.messaging().send(message);
//     console.log("Push notification sent successfully");
//   } catch (error) {
//     console.error("Error sending push notification:", error);
//   }
// };

// module.exports = { sendPushNotification };


const admin = require("firebase-admin");
const dotenv = require("dotenv");
const path = require("path");

dotenv.config();

let serviceAccount;

// التحقق مما إذا كان التطبيق يعمل محليًا (باستخدام FIREBASE_CREDENTIALS_PATH)
if (process.env.FIREBASE_CREDENTIALS_PATH) {
  try {
    const absolutePath = path.resolve(
      __dirname,
      process.env.FIREBASE_CREDENTIALS_PATH
    );
    console.log("Loading Firebase credentials from:", absolutePath);
    serviceAccount = require(absolutePath);
  } catch (error) {
    console.error("Error loading Firebase credentials file:", error);
    throw new Error("Failed to load Firebase credentials file");
  }
} else {
  // استخدام متغيرات البيئة (للنشر على Vercel)
  console.log("Using environment variables for Firebase credentials");
  serviceAccount = {
    type: process.env.FIREBASE_TYPE,
    project_id: process.env.FIREBASE_PROJECT_ID,
    private_key_id: process.env.FIREBASE_PRIVATE_KEY_ID,
    private_key: process.env.FIREBASE_PRIVATE_KEY.replace(/\\n/g, "\n"),
    client_email: process.env.FIREBASE_CLIENT_EMAIL,
    client_id: process.env.FIREBASE_CLIENT_ID,
    auth_uri: process.env.FIREBASE_AUTH_URI,
    token_uri: process.env.FIREBASE_TOKEN_URI,
    auth_provider_x509_cert_url:
      process.env.FIREBASE_AUTH_PROVIDER_X509_CERT_URL,
    client_x509_cert_url: process.env.FIREBASE_CLIENT_X509_CERT_URL,
    universe_domain: process.env.FIREBASE_UNIVERSE_DOMAIN,
  };
  console.log(
    "FIREBASE_PRIVATE_KEY (after replacement):",
    serviceAccount.private_key
  );
}

// تهيئة Firebase Admin SDK
admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
});

const sendPushNotification = async (fcmToken, title, body, data = {}) => {
  if (!fcmToken || typeof fcmToken !== "string") {
    throw new Error("Invalid or missing FCM token");
  }

  const message = {
    notification: {
      title,
      body,
    },
    data,
    token: fcmToken,
  };

  try {
    await admin.messaging().send(message);
    console.log("Push notification sent successfully");
  } catch (error) {
    console.error("Error sending push notification:", error);
    throw error; // إرجاع الخطأ للتعامل معه في الدالة المستدعية
  }
};

module.exports = { sendPushNotification };