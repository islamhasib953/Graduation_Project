# Healthcare Chat Application

This is a healthcare application built with Node.js, Express, and MongoDB, designed to facilitate real-time communication between children (patients) and doctors. The application supports appointment scheduling, chat functionality with media sharing (e.g., images, PDFs), and multi-user management.

## Project Idea

The core idea is to create a secure and efficient chat system where:
- A child (represented by the current user) can communicate directly with a doctor.
- Communication is enabled only if the child has at least one accepted appointment with the doctor in the past (no need for a new appointment each time).
- The system supports multiple doctors, users (parents), and children per user.
- Users can send text messages and media (e.g., images, documents) with timestamps, similar to WhatsApp.
- Media files are stored as URLs in the database, with the actual files uploaded to a local `Uploads` folder (or an external storage solution in the future).

## Project Structure
project/
├── config/              # Database configuration (e.g., db.config.js)
├── controllers/         # Business logic for routes (e.g., chat.controller.js)
├── models/              # Mongoose schemas (e.g., chat.model.js)
├── middlewares/         # Middleware functions (e.g., virifyToken.js)
├── routes/              # API endpoints (e.g., chat.route.js)
├── services/            # External services (e.g., websocket.service.js, mqtt.service.js)
├── utils/               # Utility functions (e.g., appError.js)
├── uploads/             # Storage for uploaded media files
├── .env                 # Environment variables
├── index.js             # Main server file
└── package.json         # Project dependencies


## Features

- **Real-Time Chat**: Uses WebSocket for live communication between children and doctors.
- **Media Sharing**: Supports uploading and sharing images, PDFs, or documents via a dedicated API endpoint.
- **Appointment Verification**: Ensures chat access only if an accepted appointment exists.
- **Chat History**: Retrieves and displays previous messages with timestamps.
- **Multi-User Support**: Handles multiple doctors, users, and children per user.

## What We Did

### Initial Setup
- Started with an existing Express server, MongoDB integration, and basic routes for users, children, and doctors.
- Added Multer for handling file uploads and storing them in the `Uploads` folder.

### Chat Implementation
1. **Created Chat Model**:
   - Added a `Chat` model (`chat.model.js`) to store messages between a child and a doctor.
   - Included fields for `doctorId`, `childId`, and an array of `messages` with `sender`, `content`, `media` (URL), and `timestamp`.

2. **Added Chat Controller**:
   - Implemented `checkChatEligibility` to verify if a child can chat with a doctor based on past accepted appointments.
   - Added `getChatHistory` to retrieve previous messages.

3. **Integrated WebSocket**:
   - Initially added WebSocket logic in `index.js` for real-time messaging.
   - Later moved it to a separate `services/websocket.service.js` file for better organization.
   - Supported sending text and media, with messages saved to the database and broadcasted to the relevant chat room.

4. **Media Support**:
   - Added a `media` field to the `Chat` model with validation for file types (e.g., jpg, png, pdf).
   - Created a `/api/chats/:childId/:doctorId/upload` endpoint using Multer to handle media uploads.
   - Stored media URLs in the database and emitted them via WebSocket.

5. **Updated Routes**:
   - Added endpoints in `chat.route.js` for eligibility check, history retrieval, and media upload.

6. **Project Refactoring**:
   - Organized the project structure with a new `services` folder.
   - Updated `index.js` to use the `WebSocketService` class.

## Installation

1. Clone the repository:
   ```bash
   git clone <repository-url>
   cd project
   Install dependencies:
bash

نسخ
npm install
Set up environment variables in .env:
text

نسخ
PORT=3000
MONGO_URI=your_mongodb_uri
Run the application:
bash

npm start
API Endpoints
GET /api/chats/:childId/:doctorId/eligibility: Checks if the child can chat with the doctor.
GET /api/chats/:childId/:doctorId/history: Retrieves chat history with messages and media.
POST /api/chats/:childId/:doctorId/upload: Uploads media to the chat (multipart/form-data with media field).
Dependencies
Express
Socket.io
Mongoose
Multer
MQTT
CORS
Morgan
Usage
Frontend Integration
Use socket.io-client to connect to the WebSocket server.
Fetch chat history with /api/chats/:childId/:doctorId/history.
Send messages via the sendMessage event and media via the upload endpoint.
Example Workflow
A parent logs in and selects a child.
The system checks eligibility using the appointment history.
If eligible, the child joins a chat room with the doctor.
The child sends a text message or uploads a photo, which is saved and displayed in real-time.
Contributing
Feel free to open issues or submit pull requests for improvements!

License
[Add your license here, e.g., MIT]


### كيفية التنزيل:
- انسخ النص ده في ملف جديد اسمه `README.md` جوا مجلد المشروع الرئيسي (`project/`).
- احفظ الملف، وهيبقى جاهز للاستخدام مع المشروع.
- لو عايز تضيف حاجة زيادة زي صور توضيحية أو أمثلة كود، قولي وأضيفها.

خبرني لو عايز تعديل أو زيادة في الـ README أو في أي حاجة تانية!