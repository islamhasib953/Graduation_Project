# from fastapi import FastAPI, HTTPException
# from pydantic import BaseModel
# from src.services.model_manager import ModelManager
# from src.models.asthma import AsthmaPatientData
# from typing import Union

# app = FastAPI(title="ML Prediction API")

# # Initialize model manager with disease="asthma"
# model_manager = ModelManager(disease="asthma")


# @app.post("/predict/{model_name}")
# async def predict(model_name: str, data: Union[AsthmaPatientData]):
#     try:
#         # Get prediction
#         result = model_manager.predict(data.dict())
#         return result
#     except ValueError as e:
#         raise HTTPException(status_code=400, detail=str(e))
#     except Exception as e:
#         raise HTTPException(status_code=500, detail=f"Server error: {str(e)}")


# @app.get("/")
# async def root():
#     return {"message": "ML Prediction API is running"}


from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
from typing import Literal, Union
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
    PhysicalActivity: float
    DietQuality: float
    SleepQuality: float
    PollutionExposure: float
    PollenExposure: float
    DustExposure: float
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


# Model managers
model_managers = {}


@app.on_event("startup")
async def startup_event():
    try:
        model_managers["asthma"] = ModelManager("asthma")
        model_managers["autism"] = ModelManager("autism")
        logger.info("Model managers initialized successfully")
    except Exception as e:
        logger.error(f"Error initializing model managers: {str(e)}")
        raise


@app.post("/predict/{disease}")
async def predict(disease: Literal["asthma", "autism"], input_data: Union[AutismInput, AsthmaInput]):
    try:
        if disease not in model_managers:
            raise HTTPException(
                status_code=400, detail=f"Unsupported disease: {disease}")

        # Validate input model matches the disease
        if disease == "autism" and not isinstance(input_data, AutismInput):
            raise HTTPException(
                status_code=422, detail="Input data must match AutismInput schema for autism")
        if disease == "asthma" and not isinstance(input_data, AsthmaInput):
            raise HTTPException(
                status_code=422, detail="Input data must match AsthmaInput schema for asthma")

        model_manager = model_managers[disease]
        prediction = model_manager.predict(input_data.dict())
        return prediction
    except Exception as e:
        logger.error(f"Error during prediction for {disease}: {str(e)}")
        raise HTTPException(status_code=500, detail=str(e))
