# Graduation Project - Notifications System

This document provides a comprehensive overview of the notifications system in the Graduation Project, including the types of notifications, project structure, setup instructions, and how to integrate notifications with Firebase and the frontend.

## Table of Contents
1. [Project Overview](#project-overview)
2. [Notifications System](#notifications-system)
   - [Types of Notifications](#types-of-notifications)
   - [Backend Implementation](#backend-implementation)
   - [Firebase Setup](#firebase-setup)
3. [Project Structure](#project-structure)
4. [Running the Notifications System](#running-the-notifications-system)
   - [Backend Setup](#backend-setup)
   - [Frontend Setup](#frontend-setup)
   - [Testing Notifications](#testing-notifications)
5. [Dependencies](#dependencies)
6. [Troubleshooting](#troubleshooting)
7. [Contact](#contact)

## Project Overview
The Graduation Project is a full-stack application with a backend built using Node.js, Express, and MongoDB, and a frontend (assumed to be built with a framework like React or similar). The project includes a notifications system powered by Firebase Cloud Messaging (FCM) to send push notifications to users. The system supports real-time notifications and scheduled notifications using `node-cron`.

## Notifications System

### Types of Notifications
The project supports the following types of notifications:
1. **Push Notifications (Real-Time)**:
   - Sent to users' devices via Firebase Cloud Messaging (FCM).
   - Used for immediate alerts, such as new messages, updates, or events.
   - Example: A user receives a notification when a new task is assigned.
2. **Scheduled Notifications**:
   - Managed using the `node-cron` library for periodic or time-based notifications.
   - Example: Daily reminders or weekly summaries.
3. **In-App Notifications** (Assumed):
   - Displayed within the frontend interface (e.g., a notification bell or toast messages).
   - Synced with push notifications for a seamless user experience.

### Backend Implementation
The backend handles sending push notifications using Firebase Admin SDK. The key components are:
- **Firebase Configuration** (`config/firebase-config.js`):
  - Initializes Firebase Admin SDK with service account credentials.
  - Provides a `sendPushNotification` function to send notifications to devices via FCM tokens.
  - Example usage:
    ```javascript
    const { sendPushNotification } = require('./config/firebase-config');
    sendPushNotification(fcmToken, 'New Task', 'You have a new task assigned!', { taskId: '123' });
    ```
- **Notifications Controller** (`controllers/notifications.controller.js`):
  - Handles the logic for triggering notifications based on events (e.g., user actions).
- **Scheduled Notifications** (`utils/scheduleNotifications.js`):
  - Uses `node-cron` to schedule notifications at specific times or intervals.
  - Example: Sending a daily reminder at 9 AM.

### Firebase Setup
Firebase Cloud Messaging (FCM) is used to deliver push notifications to client devices (web, iOS, Android). The setup involves:
1. **Firebase Project**:
   - Create a project in [Firebase Console](https://console.firebase.google.com/).
   - Enable Cloud Messaging in the Firebase project settings.
2. **Service Account Key**:
   - Go to **Project Settings > Service Accounts**.
   - Generate a new private key (JSON file).
   - Save the file as `backend/config/firebase-service-account.json`.
   - Update the `.env` file with the path:
     ```
     FIREBASE_CREDENTIALS_PATH=./config/firebase-service-account.json
     ```
3. **FCM Tokens**:
   - Each client device generates an FCM token via the Firebase SDK on the frontend.
   - Tokens are sent to the backend and stored (e.g., in MongoDB with the user’s profile) for sending notifications.

## Project Structure
The backend project is organized as follows:
```
backend/
├── config/
│   ├── firebase-config.js          # Firebase Admin SDK setup and notification logic
│   └── firebase-service-account.json # Firebase service account credentials (not in Git)
├── controllers/
│   └── notifications.controller.js # Notification-related business logic
├── utils/
│   └── scheduleNotifications.js    # Scheduled notifications using node-cron
├── app.js                         # Express app setup
├── index.js                       # Entry point
├── package.json                   # Project dependencies and scripts
├── .env                           # Environment variables (not in Git)
└── node_modules/                  # Installed dependencies
```

**Notes**:
- The `firebase-service-account.json` and `.env` files are sensitive and should be added to `.gitignore`.
- The frontend structure is assumed to be in a separate directory (e.g., `frontend/`) with a typical setup for React or similar.

## Running the Notifications System

### Backend Setup
1. **Prerequisites**:
   - Node.js v20.x (current: v20.12.2).
   - npm v10.x (current: v10.8.2).
   - MongoDB (local or cloud, configured via `.env`).
   - Firebase project with Cloud Messaging enabled.

2. **Install Dependencies**:
   ```bash
   cd backend
   npm install
   ```

3. **Configure Environment Variables**:
   - Create a `.env` file in the `backend/` directory with the following:
     ```
     FIREBASE_CREDENTIALS_PATH=./config/firebase-service-account.json
     MONGODB_URI=mongodb://localhost:27017/graduation_project
     PORT=3000
     ```
   - Replace `MONGODB_URI` with your MongoDB connection string.

4. **Add Firebase Service Account**:
   - Place the `firebase-service-account.json` file in `backend/config/`.
   - Ensure it is a valid JSON file with keys like `project_id`, `private_key`, and `client_email`.

5. **Run the Backend**:
   - For development (with auto-restart):
     ```bash
     npm run dev
     ```
   - For production:
     ```bash
     npm start
     ```

### Frontend Setup
The frontend is assumed to use a framework like React with Firebase SDK for handling push notifications. Steps:
1. **Install Firebase SDK**:
   - Add Firebase to your frontend project:
     ```bash
     npm install firebase
     ```
2. **Initialize Firebase**:
   - Create a file (e.g., `src/firebase.js`):
     ```javascript
     import { initializeApp } from 'firebase/app';
     import { getMessaging, getToken, onMessage } from 'firebase/messaging';

     const firebaseConfig = {
       apiKey: 'your-api-key',
       authDomain: 'your-project-id.firebaseapp.com',
       projectId: 'your-project-id',
       storageBucket: 'your-project-id.appspot.com',
       messagingSenderId: 'your-sender-id',
       appId: 'your-app-id',
     };

     const app = initializeApp(firebaseConfig);
     const messaging = getMessaging(app);

     export { messaging, getToken, onMessage };
     ```
   - Get `firebaseConfig` from **Firebase Console > Project Settings**.

3. **Request Notification Permission**:
   - Request permission to send notifications and retrieve the FCM token:
     ```javascript
     import { messaging, getToken } from './firebase';

     async function requestNotificationPermission() {
       try {
         const permission = await Notification.requestPermission();
         if (permission === 'granted') {
           const token = await getToken(messaging, { vapidKey: 'your-vapid-key' });
           console.log('FCM Token:', token);
           // Send token to backend to store it
           fetch('/api/save-fcm-token', {
             method: 'POST',
             headers: { 'Content-Type': 'application/json' },
             body: JSON.stringify({ token }),
           });
         }
       } catch (error) {
         console.error('Error getting FCM token:', error);
       }
     }

     requestNotificationPermission();
     ```
   - Replace `your-vapid-key` with the VAPID key from **Firebase Console > Project Settings > Cloud Messaging > Web Push Certificates**.

4. **Handle Incoming Notifications**:
   - Listen for incoming messages:
     ```javascript
     import { onMessage } from './firebase';

     onMessage(messaging, (payload) => {
       console.log('Message received:', payload);
       // Display notification in the UI (e.g., toast or bell icon)
       const { title, body } = payload.notification;
       // Example: Show a toast notification
       alert(`${title}: ${body}`);
     });
     ```

5. **Run the Frontend**:
   - Start the frontend development server (e.g., for React):
     ```bash
     cd frontend
     npm install
     npm start
     ```

### Testing Notifications
1. **Send a Test Notification from Backend**:
   - Use a tool like Postman to call an endpoint that triggers a notification (e.g., `/api/send-notification`).
   - Example payload:
     ```json
     {
       "fcmToken": "user-fcm-token",
       "title": "Test Notification",
       "body": "This is a test notification!",
       "data": { "key": "value" }
     }
     ```
2. **Verify on Frontend**:
   - Ensure the frontend receives the notification and displays it (e.g., as a toast or in-app alert).
3. **Test Scheduled Notifications**:
   - Check logs to verify that `node-cron` tasks in `utils/scheduleNotifications.js` are running as expected.

## Dependencies
Key backend dependencies related to notifications:
- `firebase-admin`: ^13.3.0 (for sending push notifications)
- `node-cron`: ^3.0.3 (for scheduled notifications)
- `dotenv`: ^16.4.7 (for environment variables)

Frontend dependencies (assumed):
- `firebase`: Latest version for FCM integration

Full list in `package.json`.

## Troubleshooting
- **Error: Cannot find module './firebase-service-account.json'**:
  - Ensure the file exists in `backend/config/`.
  - Verify the path in `.env` or `firebase-config.js`.
- **SyntaxError: Unexpected end of JSON input**:
  - Check `firebase-service-account.json` for valid JSON format.
  - Re-download the file from Firebase Console if corrupted.
- **Notifications not received on frontend**:
  - Verify FCM token is sent to the backend.
  - Ensure notification permissions are granted in the browser.
  - Check Firebase Console for FCM configuration issues.
- **Scheduled notifications not working**:
  - Verify `node-cron` schedules in `utils/scheduleNotifications.js`.
  - Check server logs for errors.

## Contact
For issues or inquiries, contact:
- **Author**: Islam Hasib
- **Email**: [Add your email here]
- **GitHub**: [Add your GitHub repo link here]