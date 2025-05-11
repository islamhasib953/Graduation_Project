# from fastapi import FastAPI, HTTPException
# from pydantic import BaseModel
# from typing import Literal, Union
# from src.services.model_manager import ModelManager
# import logging

# # Configure logging
# logging.basicConfig(level=logging.INFO)
# logger = logging.getLogger(__name__)

# app = FastAPI(title="Disease Prediction API")

# # Pydantic models for input validation


# class AutismInput(BaseModel):
#     A1: int
#     A2: int
#     A3: int
#     A4: int
#     A5: int
#     A6: int
#     A7: int
#     A8: int
#     A9: int
#     A10: int
#     Age_Mons: int
#     Sex: str
#     Ethnicity: str
#     Jaundice: str
#     Family_mem_with_ASD: str
#     Who_completed_the_test: str


# class AsthmaInput(BaseModel):
#     Age: int
#     Gender: int
#     Ethnicity: int
#     EducationLevel: int
#     BMI: float
#     Smoking: int
#     PhysicalActivity: float
#     DietQuality: float
#     SleepQuality: float
#     PollutionExposure: float
#     PollenExposure: float
#     DustExposure: float
#     PetAllergy: int
#     FamilyHistoryAsthma: int
#     HistoryOfAllergies: int
#     Eczema: int
#     HayFever: int
#     GastroesophagealReflux: int
#     LungFunctionFEV1: float
#     LungFunctionFVC: float
#     Wheezing: int
#     ShortnessOfBreath: int
#     ChestTightness: int
#     Coughing: int
#     NighttimeSymptoms: int
#     ExerciseInduced: int


# class StrokeInput(BaseModel):
#     gender: str
#     age: float
#     hypertension: int
#     heart_disease: int
#     ever_married: str
#     work_type: str
#     Residence_type: str
#     avg_glucose_level: float
#     bmi: float
#     smoking_status: str


# # Model managers
# model_managers = {}


# @app.on_event("startup")
# async def startup_event():
#     try:
#         model_managers["asthma"] = ModelManager("asthma")
#         model_managers["autism"] = ModelManager("autism")
#         model_managers["stroke"] = ModelManager("stroke")
#         logger.info("Model managers initialized successfully")
#     except Exception as e:
#         logger.error(f"Error initializing model managers: {str(e)}")
#         raise


# @app.post("/predict/{disease}")
# async def predict(disease: Literal["asthma", "autism", "stroke"], input_data: Union[AutismInput, AsthmaInput, StrokeInput]):
#     try:
#         if disease not in model_managers:
#             raise HTTPException(
#                 status_code=400, detail=f"Unsupported disease: {disease}")

#         # Validate input model matches the disease
#         if disease == "autism" and not isinstance(input_data, AutismInput):
#             raise HTTPException(
#                 status_code=422, detail="Input data must match AutismInput schema for autism")
#         if disease == "asthma" and not isinstance(input_data, AsthmaInput):
#             raise HTTPException(
#                 status_code=422, detail="Input data must match AsthmaInput schema for asthma")
#         if disease == "stroke" and not isinstance(input_data, StrokeInput):
#             raise HTTPException(
#                 status_code=422, detail="Input data must match StrokeInput schema for stroke")

#         model_manager = model_managers[disease]
#         prediction = model_manager.predict(input_data.dict())
#         return prediction
#     except Exception as e:
#         logger.error(f"Error during prediction for {disease}: {str(e)}")
#         raise HTTPException(status_code=500, detail=str(e))


from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
from src.services.model_manager import ModelManager
import logging

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

app = FastAPI(title="Disease Prediction API")

# Pydantic models for input validation


class AutismInput(BaseModel):
    A1: int
    A2: int
    A3: int
    A4: int
    A5: int
    A6: int
    A7: int
    A8: int
    A9: int
    A10: int
    Age_Mons: int
    Sex: str
    Ethnicity: str
    Jaundice: str
    Family_mem_with_ASD: str
    Who_completed_the_test: str


class AsthmaInput(BaseModel):
    Age: int
    Gender: int
    Ethnicity: int
    EducationLevel: int
    BMI: float
    Smoking: int
    PhysicalActivity: float  # Changed to float
    DietQuality: float      # Changed to float
    SleepQuality: float     # Changed to float
    PollutionExposure: float  # Changed to float
    PollenExposure: float   # Changed to float
    DustExposure: float     # Changed to float
    PetAllergy: int
    FamilyHistoryAsthma: int
    HistoryOfAllergies: int
    Eczema: int
    HayFever: int
    GastroesophagealReflux: int
    LungFunctionFEV1: float
    LungFunctionFVC: float
    Wheezing: int
    ShortnessOfBreath: int
    ChestTightness: int
    Coughing: int
    NighttimeSymptoms: int
    ExerciseInduced: int


class StrokeInput(BaseModel):
    gender: str
    age: float
    hypertension: int
    heart_disease: int
    ever_married: str
    work_type: str
    Residence_type: str
    avg_glucose_level: float
    bmi: float
    smoking_status: str


# Model managers
model_managers = {}


@app.on_event("startup")
async def startup_event():
    try:
        model_managers["asthma"] = ModelManager("asthma")
        model_managers["autism"] = ModelManager("autism")
        model_managers["stroke"] = ModelManager("stroke")
        logger.info("Model managers initialized successfully")
    except Exception as e:
        logger.error(f"Error initializing model managers: {str(e)}")
        raise

# Endpoint for asthma prediction


@app.post("/predict/asthma")
async def predict_asthma(input_data: AsthmaInput):
    try:
        model_manager = model_managers["asthma"]
        prediction = model_manager.predict(input_data.dict())
        return prediction
    except Exception as e:
        logger.error(f"Error during prediction for asthma: {str(e)}")
        raise HTTPException(status_code=500, detail=str(e))

# Endpoint for autism prediction


@app.post("/predict/autism")
async def predict_autism(input_data: AutismInput):
    try:
        model_manager = model_managers["autism"]
        prediction = model_manager.predict(input_data.dict())
        return prediction
    except Exception as e:
        logger.error(f"Error during prediction for autism: {str(e)}")
        raise HTTPException(status_code=500, detail=str(e))

# Endpoint for stroke prediction


@app.post("/predict/stroke")
async def predict_stroke(input_data: StrokeInput):
    try:
        model_manager = model_managers["stroke"]
        prediction = model_manager.predict(input_data.dict())
        return prediction
    except Exception as e:
        logger.error(f"Error during prediction for stroke: {str(e)}")
        raise HTTPException(status_code=500, detail=str(e))
