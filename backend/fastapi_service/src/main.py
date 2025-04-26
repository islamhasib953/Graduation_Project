# from fastapi import FastAPI, HTTPException
# from pydantic import BaseModel
# from src.services.model_manager import ModelManager
# from src.models.asthma import AsthmaPatientData
# from typing import Union

# app = FastAPI(title="ML Prediction API")

# # Initialize model manager
# model_manager = ModelManager()


# @app.post("/predict/{model_name}")
# async def predict(model_name: str, data: Union[AsthmaPatientData]):
#     try:
#         # Get prediction
#         result = model_manager.predict(model_name, data.dict())
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
from src.services.model_manager import ModelManager
from src.models.asthma import AsthmaPatientData
from typing import Union

app = FastAPI(title="ML Prediction API")

# Initialize model manager with disease="asthma"
model_manager = ModelManager(disease="asthma")


@app.post("/predict/{model_name}")
async def predict(model_name: str, data: Union[AsthmaPatientData]):
    try:
        # Get prediction
        result = model_manager.predict(data.dict())
        return result
    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e))
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Server error: {str(e)}")


@app.get("/")
async def root():
    return {"message": "ML Prediction API is running"}
