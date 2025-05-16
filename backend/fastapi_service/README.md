# Asthma Prediction System

This project is a full-stack application that integrates a **Node.js/Express backend** with a **FastAPI service** to provide machine learning-based predictions for asthma diagnosis. The system uses a trained Random Forest model (`RandomForest_Asthma-model.pkl`) and a scaler (`scaler.pkl`) to predict asthma based on patient data. The architecture is designed to be modular and scalable, supporting additional ML models in the future.

## Table of Contents
1. [Project Structure](#project-structure)
2. [Prerequisites](#prerequisites)
3. [Setup Instructions](#setup-instructions)
   - [Environment Variables](#environment-variables)
   - [Node.js Backend Setup](#nodejs-backend-setup)
   - [FastAPI Service Setup](#fastapi-service-setup)
4. [Running the System](#running-the-system)
   - [Running Locally](#running-locally)
   - [Running with Docker](#running-with-docker)
5. [Testing the System](#testing-the-system)
   - [Testing FastAPI Directly](#testing-fastapi-directly)
   - [Testing Node.js Endpoint](#testing-nodejs-endpoint)
6. [Adding New Models](#adding-new-models)
7. [Troubleshooting](#troubleshooting)
8. [Deployment Notes](#deployment-notes)
9. [Contributing](#contributing)

## Project Structure

The project is organized as follows:

```
graduation_project/
├── backend/                      # Node.js/Express backend
│   ├── config/                   # Database configuration
│   │   └── db.config.js
│   ├── controllers/              # API logic
│   │   ├── prediction.controller.js
│   │   └── ...                   # Other controllers
│   ├── models/                   # MongoDB models
│   ├── routes/                   # API routes
│   │   ├── prediction.route.js
│   │   └── ...                   # Other routes
│   ├── services/                 # Services (e.g., MQTT)
│   ├── utils/                    # Utilities
│   ├── uploads/                  # Static files
│   ├── app.js                    # Main Express app
│   ├── index.js                  # Server entry point
│   ├── package.json
│   ├── package-lock.json
│   └── Dockerfile
├── ml_service/                   # FastAPI service for ML models
│   ├── models/                   # ML models and scalers
│   │   ├── asthma/
│   │   │   ├── RandomForest_Asthma-model.pkl
│   │   │   └── scaler.pkl
│   │   └── future_models/        # Placeholder for future models
│   ├── src/
│   │   ├── models/               # Pydantic models
│   │   │   └── asthma.py
│   │   ├── services/             # ML model logic
│   │   │   └── model_manager.py
│   │   └── main.py               # FastAPI main app
│   ├── requirements.txt
│   └── Dockerfile
├── docker-compose.yml            # Docker Compose configuration
├── .env                          # Environment variables
└── README.md                     # This file
```

- **backend/**: Contains the Node.js/Express backend, handling API requests, MongoDB integration, and communication with the FastAPI service.
- **ml_service/**: Contains the FastAPI service, responsible for loading and serving ML models (e.g., Asthma prediction).
- **docker-compose.yml**: Configures both services to run together.

## Prerequisites

Before setting up the project, ensure you have the following installed:
- **Node.js** (v20.x or higher)
- **Python** (v3.9 or higher)
- **Docker** and **Docker Compose** (optional, for containerized deployment)
- **MongoDB** (local or cloud-based, e.g., MongoDB Atlas)
- **Git** (to clone the repository)

Additionally, ensure you have the ML model files:
- `RandomForest_Asthma-model.pkl`
- `scaler.pkl`

These should be placed in `ml_service/models/asthma/`.

## Setup Instructions

### Environment Variables
Create a `.env` file in the project root (`graduation_project/`) with the following variables:

```
# Node.js
PORT=8000
MONGODB_URI=mongodb://localhost:27017/your_database  # Replace with your MongoDB URI
NODE_ENV=development
FASTAPI_URL=http://localhost:8001

# FastAPI (optional)
FASTAPI_PORT=8001
```

- Replace `MONGODB_URI` with your MongoDB connection string.
- Update `FASTAPI_URL` if FastAPI runs on a different host/port (e.g., `http://ml_service:8000` for Docker).

### Node.js Backend Setup
1. Navigate to the `backend` directory:
   ```bash
   cd backend
   ```
2. Install dependencies:
   ```bash
   npm install
   ```
3. Ensure MongoDB is running and `MONGODB_URI` is correctly set in `.env`.

### FastAPI Service Setup
1. Navigate to the `ml_service` directory:
   ```bash
   cd ml_service
   ```
2. Create a Python virtual environment:
   ```bash
   python -m venv venv
   source venv/bin/activate  # Linux/Mac
   venv\Scripts\activate     # Windows
   ```
3. Install dependencies:
   ```bash
   pip install -r requirements.txt
   ```
4. Ensure the model files (`RandomForest_Asthma-model.pkl` and `scaler.pkl`) are in `ml_service/models/asthma/`.

## Running the System

### Running Locally
1. **Start FastAPI**:
   In the `ml_service` directory (with the virtual environment activated):
   ```bash
   uvicorn src.main:app --host 0.0.0.0 --port 8001
   ```
   - FastAPI will run on `http://localhost:8001`.
   - Verify by visiting `http://localhost:8001/` (should return `{"message": "ML Prediction API is running"}`).

2. **Start Node.js**:
   In the `backend` directory:
   ```bash
   npm run dev
   ```
   - Node.js will run on `http://localhost:8000`.
   - Verify by visiting `http://localhost:8000/` (should return your root endpoint response).

### Running with Docker
1. Ensure Docker and Docker Compose are installed.
2. In the project root (`graduation_project/`):
   ```bash
   docker-compose up --build
   ```
   - FastAPI will run on `http://localhost:8001`.
   - Node.js will run on `http://localhost:8000`.
3. To stop the services:
   ```bash
   docker-compose down
   ```

## Testing the System

### Testing FastAPI Directly
Send a POST request to the FastAPI endpoint to test the asthma prediction model:

```bash
curl -X POST "http://localhost:8001/predict/asthma" \
-H "Content-Type: application/json" \
-d '{
    "Age": 45,
    "Gender": 1,
    "Ethnicity": 0,
    "EducationLevel": 2,
    "BMI": 25.5,
    "Smoking": 0,
    "PhysicalActivity": 1,
    "DietQuality": 2,
    "SleepQuality": 2,
    "PollutionExposure": 3,
    "PollenExposure": 2,
    "DustExposure": 1,
    "PetAllergy": 0,
    "FamilyHistoryAsthma": 1,
    "HistoryOfAllergies": 1,
    "Eczema": 0,
    "HayFever": 1,
    "GastroesophagealReflux": 0,
    "LungFunctionFEV1": 2.5,
    "LungFunctionFVC": 3.8,
    "Wheezing": 1,
    "ShortnessOfBreath": 1,
    "ChestTightness": 0,
    "Coughing": 1,
    "NighttimeSymptoms": 1,
    "ExerciseInduced": 0
}'
```

**Expected Response**:
```json
{
  "prediction": 1,
  "probability": 0.85,
  "diagnosis": "Asthma"
}
```

### Testing Node.js Endpoint
Send a POST request to the Node.js endpoint, which communicates with FastAPI:

```bash
curl -X POST "http://localhost:8000/api/predictions/predict/asthma" \
-H "Content-Type: application/json" \
-d '{
    "Age": 45,
    "Gender": 1,
    "Ethnicity": 0,
    "EducationLevel": 2,
    "BMI": 25.5,
    "Smoking": 0,
    "PhysicalActivity": 1,
    "DietQuality": 2,
    "SleepQuality": 2,
    "PollutionExposure": 3,
    "PollenExposure": 2,
    "DustExposure": 1,
    "PetAllergy": 0,
    "FamilyHistoryAsthma": 1,
    "HistoryOfAllergies": 1,
    "Eczema": 0,
    "HayFever": 1,
    "GastroesophagealReflux": 0,
    "LungFunctionFEV1": 2.5,
    "LungFunctionFVC": 3.8,
    "Wheezing": 1,
    "ShortnessOfBreath": 1,
    "ChestTightness": 0,
    "Coughing": 1,
    "NighttimeSymptoms": 1,
    "ExerciseInduced": 0
}'
```

**Expected Response**:
```json
{
  "status": "success",
  "data": {
    "prediction": 1,
    "probability": 0.85,
    "diagnosis": "Asthma"
  }
}
```

You can also use **Postman**:
1. Create a POST request to `http://localhost:8000/api/predictions/predict/asthma`.
2. Set the body to `raw` JSON and paste the above data.
3. Send the request and verify the response.

## Adding New Models
The system is designed to support additional ML models (e.g., Diabetes Prediction). To add a new model:

1. **Create a Pydantic Model**:
   - Add a new file in `ml_service/src/models/` (e.g., `diabetes.py`):
     ```python
     from pydantic import BaseModel

     class DiabetesPatientData(BaseModel):
         feature1: float
         feature2: int
         # Define features for the new model
     ```
2. **Update Model Manager**:
   - In `ml_service/src/services/model_manager.py`, add the new model configuration:
     ```python
     'diabetes': {
         'model_path': 'models/diabetes/model.pkl',
         'scaler_path': 'models/diabetes/scaler.pkl',
         'numerical_cols': ['feature1', 'feature2'],
         'feature_order': ['feature1', 'feature2', ...]
     }
     ```
3. **Update FastAPI**:
   - In `ml_service/src/main.py`, import the new Pydantic model and update the `Union`:
     ```python
     from src.models.diabetes import DiabetesPatientData
     async def predict(model_name: str, data: Union[AsthmaPatientData, DiabetesPatientData]):
     ```
4. **Add Model Files**:
   - Place the new model and scaler files in `ml_service/models/diabetes/`.
5. **Update Node.js**:
   - Add a new function in `backend/controllers/prediction.controller.js`:
     ```javascript
     const predictDiabetes = async (req, res, next) => {
         try {
             const response = await axios.post(`${FASTAPI_URL}/predict/diabetes`, req.body);
             res.status(200).json({
                 status: httpStatusText.SUCCESS,
                 data: response.data
             });
         } catch (error) {
             return next(new AppError(`Failed to get prediction: ${error.message}`, 500));
         }
     };
     ```
   - Add a new route in `backend/routes/prediction.route.js`:
     ```javascript
     router.post('/predict/diabetes', predictDiabetes);
     ```
6. **Test the New Model**:
   - Send a POST request to `http://localhost:8000/api/predictions/predict/diabetes` with the appropriate input data.

## Troubleshooting

### FastAPI Errors
- **ModuleNotFoundError** or **FileNotFoundError**:
  - Ensure all dependencies are installed (`pip install -r requirements.txt`).
  - Verify that `RandomForest_Asthma-model.pkl` and `scaler.pkl` are in `ml_service/models/asthma/`.
- **Feature Names Mismatch**:
  - If you see an error like `The feature names should match those that were passed during fit`:
    - Check the `feature_order` in `ml_service/src/services/model_manager.py`.
    - Compare with the features used during model training (use `model.feature_names_in_` in Python).
    - Example:
      ```python
      import joblib
      model = joblib.load('ml_service/models/asthma/RandomForest_Asthma-model.pkl')
      print(model.feature_names_in_)
      ```
    - Update `feature_order` to match the model's expectations.

### Node.js Errors
- **Connection Error (ECONNREFUSED)**:
  - Ensure FastAPI is running on `http://localhost:8001`.
  - Verify `FASTAPI_URL` in `.env` (`http://localhost:8001` locally, `http://ml_service:8000` in Docker).
- **400/500 Errors**:
  - Check Node.js logs (`npm run dev`) for details.
  - Ensure the POST request includes all required fields (26 for asthma).

### Docker Errors
- **Container Exits**:
  - Run `docker-compose logs` to view errors.
  - Check if all files (`requirements.txt`, `package.json`) are present.
  - Verify `MONGODB_URI` is correct.

## Deployment Notes
- **Cloud Deployment**:
  - Use AWS ECS, Google Cloud Run, or Kubernetes to deploy the Docker containers.
  - Ensure MongoDB is accessible (e.g., via MongoDB Atlas).
- **Security**:
  - Add API key or JWT authentication for Node.js-to-FastAPI communication.
  - Use HTTPS for all endpoints.
- **Performance**:
  - Use `gunicorn` for FastAPI in production:
    ```bash
    gunicorn -w 4 -k uvicorn.workers.UvicornWorker main:app
    ```
  - Consider caching (e.g., Redis) for frequent predictions.
- **Logging**:
  - Add logging in FastAPI (`logging` module) and Node.js (`winston` package).

## Contributing
To contribute:
1. Fork the repository.
2. Create a feature branch (`git checkout -b feature/new-feature`).
3. Commit changes (`git commit -m 'Add new feature'`).
4. Push to the branch (`git push origin feature/new-feature`).
5. Create a pull request.

For issues or suggestions, open an issue on the repository.

---

**Author**: Islam Hasib  
**License**: ISC