# Smart Watch Health Monitoring System

This project is a real-time health monitoring system for children using a smartwatch based on **ESP32**. The system collects sensor data (temperature, heart rate, SpO2, gyroscope, and location), sends it to a backend server via **MQTT**, stores it in **MongoDB**, and displays it in real-time on a frontend interface using **WebSocket**. The system also provides a REST API to retrieve historical data, with authentication and role-based access control.

## Table of Contents
1. [System Overview](#system-overview)
2. [Components](#components)
3. [Data Flow](#data-flow)
4. [Prerequisites](#prerequisites)
5. [Setup Instructions](#setup-instructions)
   - [Backend Setup](#backend-setup)
   - [ESP32 Smartwatch Setup](#esp32-smartwatch-setup)
   - [Frontend Setup](#frontend-setup)
6. [Usage](#usage)
   - [Running the Backend](#running-the-backend)
   - [Running the ESP32 Smartwatch](#running-the-esp32-smartwatch)
   - [Running the Frontend](#running-the-frontend)
   - [Using the API](#using-the-api)
7. [Testing](#testing)
8. [File Structure](#file-structure)
9. [Notes and Recommendations](#notes-and-recommendations)
10. [Contributing](#contributing)
11. [License](#license)

## System Overview
The Smart Watch Health Monitoring System is designed to:
- **Collect** health data (temperature, heart rate, SpO2, gyroscope, location) from a smartwatch using ESP32.
- **Transmit** data to a cloud MQTT broker (HiveMQ Cloud).
- **Store** data in MongoDB for historical analysis.
- **Display** data in real-time on a web interface using WebSocket.
- **Provide** a REST API for authorized users (Admin, Doctor, Patient) to retrieve historical data.
- **Secure** access with JWT authentication and role-based authorization.

The system is intended for parents and doctors to monitor children's health metrics in real-time and access historical data for medical analysis.

## Components
1. **Smartwatch (ESP32)**:
   - Hardware: ESP32 DevKitC, MAX30102 (heart rate & SpO2), DS18B20 (temperature), MPU6050 (gyroscope), optional NEO-6M GPS.
   - Software: Arduino code to collect sensor data and publish it to MQTT.
2. **Backend**:
   - Framework: Node.js with Express.js.
   - Database: MongoDB Atlas for storing sensor data and user/child information.
   - MQTT: Connects to HiveMQ Cloud to receive sensor data.
   - WebSocket: Socket.IO for real-time data broadcasting to the frontend.
   - Authentication: JWT with role-based access (Admin, Doctor, Patient).
3. **Frontend**:
   - A simple HTML page (`test_websocket.html`) using Socket.IO to display real-time sensor data.
4. **MQTT Broker**:
   - HiveMQ Cloud for reliable message delivery between the smartwatch and backend.
5. **Fake Data Publisher**:
   - A Node.js script (`fakeDataPublisher.js`) to simulate smartwatch data for testing.

## Data Flow
1. **Smartwatch (ESP32)**:
   - Collects sensor data (temperature, heart rate, SpO2, gyroscope, location).
   - Publishes data as JSON to the MQTT topic `sensors/data` on HiveMQ Cloud.
2. **Backend** (`mqtt.service.js`):
   - Subscribes to `sensors/data` via MQTT.
   - Validates `childId` against the `Child` model in MongoDB.
   - Stores data in the `sensordata` collection.
   - Broadcasts data to connected clients via WebSocket (Socket.IO).
3. **Frontend** (`test_websocket.html`):
   - Connects to the backend via WebSocket.
   - Displays sensor data in real-time as it arrives.
4. **REST API** (`sensorData.route.js` & `sensorData.controller.js`):
   - Provides endpoints to retrieve historical sensor data for a specific child.
   - Secured with JWT and role-based authorization.

## Prerequisites
### Backend
- **Node.js** (v16 or higher)
- **MongoDB Atlas** account
- **HiveMQ Cloud** account
- **npm** for installing dependencies
- **Postman** (optional, for testing API)

### ESP32 Smartwatch
- **ESP32 DevKitC** or compatible board
- **Sensors**: MAX30102, DS18B20, MPU6050, optional NEO-6M GPS
- **Arduino IDE** or **PlatformIO**
- **Arduino Libraries**:
  - `PubSubClient`
  - `ArduinoJson`
  - `MAX30105`
  - `DallasTemperature`
  - `OneWire`
  - `Adafruit MPU6050`
  - `TinyGPS++` (if using GPS)

### Frontend
- **Live Server** (VS Code extension or npm package `live-server`)
- **Modern web browser** (Chrome, Firefox, etc.)

## Setup Instructions

### Backend Setup
1. **Clone the Repository**:
   ```bash
   git clone <repository-url>
   cd <repository-folder>
   ```

2. **Install Dependencies**:
   ```bash
   npm install
   ```

3. **Configure Environment Variables**:
   - Create a `.env` file in the root directory.
   - Add the following:
     ```env
     PORT=8000
     DATA_BASE_URL=mongodb+srv://root:<PASSWORD>@gradulateproject.l52su.mongodb.net/<DATABASENAME>?retryWrites=true&w=majority
     DATA_BASE_NAME=Gradulate_Project
     DATA_BASE_PASSWORD=root
     TOKEN_SECRET_KEY=your_jwt_secret_key
     MQTT_HOST=3fa03e982e084ab8b46de99cad551082.s1.eu.hivemq.cloud
     MQTT_PORT=8883
     MQTT_USERNAME=Sigma
     MQTT_PASSWORD=jQ6h5iuiMsVsBj.
     MQTT_TOPIC=sensors/data
     ```
   - Replace `your_jwt_secret_key` with a secure key.
   - Update MongoDB credentials as needed.

4. **Verify MongoDB Connection**:
   - Ensure MongoDB Atlas is accessible.
   - Test connection using MongoDB Compass or CLI:
     ```javascript
     use Gradulate_Project
     ```

### ESP32 Smartwatch Setup
1. **Connect Sensors**:
   - **DS18B20** (Temperature):
     - Data Pin -> GPIO 4
     - VCC -> 3.3V
     - GND -> GND
     - 4.7kΩ resistor between Data and VCC
   - **MAX30102** (Heart Rate & SpO2):
     - SCL -> GPIO 22
     - SDA -> GPIO 21
     - VCC -> 3.3V
     - GND -> GND
   - **MPU6050** (Gyroscope):
     - SCL -> GPIO 22
     - SDA -> GPIO 21
     - VCC -> 3.3V
     - GND -> GND
   - **NEO-6M GPS** (optional):
     - TX -> GPIO 16
     - RX -> GPIO 17
     - VCC -> 3.3V
     - GND -> GND

2. **Install Arduino IDE**:
   - Download from [arduino.cc](https://www.arduino.cc/en/software).
   - Add ESP32 board support:
     - `File -> Preferences -> Additional Boards Manager URLs`:
       ```
       https://raw.githubusercontent.com/espressif/arduino-esp32/gh-pages/package_esp32_index.json
       ```
     - `Tools -> Board -> Boards Manager` -> Search for `esp32` -> Install.

3. **Install Libraries**:
   - `Tools -> Manage Libraries` -> Install:
     - `PubSubClient`
     - `ArduinoJson`
     - `MAX30105`
     - `DallasTemperature`
     - `OneWire`
     - `Adafruit MPU6050`
     - `TinyGPS++` (if using GPS)

4. **Update ESP32 Code**:
   - Open `esp32_sensor_mqtt.ino` (provided in the repository).
   - Update the following:
     - `ssid` and `password` with your Wi-Fi credentials.
     - `child_id` with a valid `ObjectId` from the `children` collection in MongoDB.
     - Example:
       ```cpp
       const char* ssid = "YourWiFiSSID";
       const char* password = "YourWiFiPassword";
       const char* child_id = "507f1f77bcf86cd799439012";
       ```

5. **Upload Code**:
   - Connect ESP32 to your computer via USB.
   - `Tools -> Board -> ESP32 Arduino -> ESP32 Dev Module`.
   - `Tools -> Port -> Select the correct port`.
   - Click `Upload`.

### Frontend Setup
1. **Install Live Server**:
   - If using VS Code, install the `Live Server` extension.
   - Or install globally via npm:
     ```bash
     npm install -g live-server
     ```

2. **Prepare Frontend File**:
   - Ensure `test_websocket.html` is in the `public` folder or a similar directory.
   - No additional setup is required (it uses Socket.IO from CDN).

## Usage

### Running the Backend
1. **Start the Server**:
   ```bash
   node src/index.js
   ```
   - Expected output:
     ```
     ✅ MongoDB connected
     ✅ app listening on port 8000
     Connected to MQTT Broker
     Subscribed to sensors/data
     ```

2. **Verify MQTT Connection**:
   - Ensure the backend is subscribed to `sensors/data`.
   - Check logs for `Received data on sensors/data` when data is published.

### Running the ESP32 Smartwatch
1. **Power the ESP32**:
   - Connect the ESP32 to a power source (USB or battery).
   - Open `Serial Monitor` in Arduino IDE (115200 baud rate).

2. **Monitor Output**:
   - Expected output:
     ```
     Connecting to WiFi...
     WiFi connected
     Connecting to MQTT...connected
     Data published: {"childId":"507f1f77bcf86cd799439012","temperature":36.5,...}
     ```

3. **Troubleshooting**:
   - If Wi-Fi fails: Check `ssid` and `password`.
   - If MQTT fails: Verify `mqtt_server`, `mqtt_user`, `mqtt_password`.
   - If sensors fail: Check wiring and test each sensor individually.

### Running the Frontend
1. **Start Live Server**:
   ```bash
   cd public  
   live-server
   ```
   - Opens a browser at `http://localhost:8080`.

2. **Verify Data Display**:
   - Open `test_websocket.html`.
   - Check browser console (F12 -> Console) for:
     ```
     Connected to WebSocket server
     Received sensor data: { ... }
     ```
   - Data should appear in formatted containers (Child ID, Temperature, etc.).

### Using the API
1. **Authenticate**:
   - Use the `/api/users/login` endpoint to get a JWT token:
     ```
     POST http://localhost:8000/api/users/login
     Body: { "email": "test@example.com", "password": "yourpassword" }
     ```
   - Copy the `token` from the response.

2. **Retrieve Sensor Data**:
   - **Get all sensor data for a child**:
     ```
     GET http://localhost:8000/api/sensor-data/507f1f77bcf86cd799439012
     Headers: Authorization: Bearer <your_jwt_token>
     ```
     - Response:
       ```json
       {
         "status": "SUCCESS",
         "data": [
           {
             "_id": "ObjectId",
             "childId": "507f1f77bcf86cd799439012",
             "temperature": 36.5,
             "heartRate": 80,
             ...
           },
           ...
         ]
       }
       ```
   - **Get single sensor data record**:
     ```
     GET http://localhost:8000/api/sensor-data/507f1f77bcf86cd799439012/507f1f77bcf86cd799439013
     Headers: Authorization: Bearer <your_jwt_token>
     ```
     - Response:
       ```json
       {
         "status": "SUCCESS",
         "data": {
           "_id": "507f1f77bcf86cd799439013",
           "childId": "507f1f77bcf86cd799439012",
           "temperature": 36.5,
           ...
         }
       }
       ```

3. **Test with Postman**:
   - Import the API endpoints into Postman.
   - Add the `Authorization` header with the JWT token.

## Testing
1. **Test Data Generation**:
   - Run `fakeDataPublisher.js` to simulate smartwatch data:
     ```bash
     node fakeDataPublisher.js
     ```
   - Verify in backend logs:
     ```
     Received data on sensors/data: { ... }
     Sensor data saved: { ... }
     ```

2. **Test MongoDB Storage**:
   - Connect to MongoDB Atlas using MongoDB Compass or CLI.
   - Check the `sensordata` collection:
     ```javascript
     db.sensordata.find({ childId: "507f1f77bcf86cd799439012" }).pretty();
     ```

3. **Test WebSocket**:
   - Open `test_websocket.html` via `live-server`.
   - Ensure data appears in real-time as the ESP32 or `fakeDataPublisher.js` sends it.

4. **Test API**:
   - Use Postman to test `GET /api/sensor-data/:childId` and `GET /api/sensor-data/:childId/:sensorDataId`.
   - Verify authentication and data retrieval.

## File Structure
```
├── public/
│   └── test_websocket.html      # Frontend interface for real-time data
├── src/
│   ├── config/
│   │   └── db.config.js        # MongoDB connection setup
│   ├── controllers/
│   │   └── sensorData.controller.js  # Sensor data API logic
│   │   └── ...                 # Other controllers (medicine, users, etc.)
│   ├── middlewares/
│   │   └── asyncWrapper.js     # Error handling wrapper
│   │   └── verifyToken.js      # JWT verification
│   │   └── allowedTo.js        # Role-based authorization
│   │   └── ...                 # Other middlewares
│   ├── models/
│   │   └── sensorData.model.js # Sensor data schema
│   │   └── child.model.js      # Child schema
│   │   └── ...                 # Other models
│   ├── routes/
│   │   └── sensorData.route.js # Sensor data API routes
│   │   └── ...                 # Other routes
│   ├── services/
│   │   └── mqtt.service.js     # MQTT client for receiving sensor data
│   ├── utils/
│   │   └── appError.js         # Custom error class
│   │   └── httpStatusText.js   # HTTP status constants
│   │   └── userRoles.js        # User role constants
│   ├── app.js                  # Express app setup
│   └── index.js                # Server entry point
├── fakeDataPublisher.js        # Script to simulate smartwatch data
├── esp32_sensor_mqtt.ino       # ESP32 code for smartwatch
├── .env                        # Environment variables
├── package.json                # Node.js dependencies
└── README.md                   # This file
```

## Notes and Recommendations
1. **ESP32 Improvements**:
   - Use a signal processing library for accurate MAX30102 readings (e.g., SparkFun MAX3010x).
   - Implement deep sleep to reduce power consumption:
     ```cpp
     #include <esp_deep_sleep.h>
     esp_deep_sleep_start();
     ```
   - Secure `childId` storage in EEPROM instead of hardcoding.

2. **Backend Enhancements**:
   - Add pagination to `getAllSensorData`:
     ```javascript
     const page = parseInt(req.query.page) || 1;
     const limit = parseInt(req.query.limit) || 50;
     const sensorData = await SensorData.find({ childId })
       .sort({ createdAt: -1 })
       .skip((page - 1) * limit)
       .limit(limit);
     ```
   - Implement notifications for abnormal data (e.g., high temperature).

3. **Frontend Development**:
   - Replace `test_websocket.html` with a React or Flutter app for a professional interface.
   - Example React component:
     ```jsx
     import io from 'socket.io-client';
     const socket = io('http://localhost:8000');
     socket.on('sensorData', (data) => {
       console.log('New data:', data);
       // Update UI
     });
     ```

4. **Security**:
   - Use SSL certificates for MQTT in production (remove `espClient.setInsecure()`).
   - Validate `childId` in ESP32 setup to prevent unauthorized data publishing.
   - Regularly rotate JWT secret key.

5. **Database Optimization**:
   - Add indexes for faster queries:
     ```javascript
     db.sensordata.createIndex({ childId: 1 });
     ```

## Contributing
1. Fork the repository.
2. Create a new branch (`git checkout -b feature/your-feature`).
3. Commit changes (`git commit -m 'Add your feature'`).
4. Push to the branch (`git push origin feature/your-feature`).
5. Open a Pull Request.

## License
This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.