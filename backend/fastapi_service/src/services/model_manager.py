import joblib
import pandas as pd
import logging
from typing import Dict, Any


class ModelManager:
    def __init__(self, disease: str):
        self.disease = disease.lower()
        self.model = None
        self.scaler = None
        self.logger = logging.getLogger(__name__)
        self.load_model_and_scaler()

    def load_model_and_scaler(self):
        try:
            model_path = f"models/{self.disease}/RandomForest_Asthma-model.pkl"
            scaler_path = f"models/{self.disease}/scaler.pkl"
            self.model = joblib.load(model_path)
            self.scaler = joblib.load(scaler_path)
            self.logger.info(
                f"Model and scaler for {self.disease} loaded successfully")
            self.logger.info(
                f"Scaler for {self.disease} expects features: {self.scaler.feature_names_in_}")
        except Exception as e:
            self.logger.error(
                f"Error loading model or scaler for {self.disease}: {str(e)}")
            raise

    def preprocess_input(self, input_data: Dict[str, Any]) -> pd.DataFrame:
        try:
            df = pd.DataFrame([input_data])
            numerical_cols = ['BMI', 'LungFunctionFEV1', 'LungFunctionFVC']
            self.logger.info(
                f"Input data before scaling: {df[numerical_cols]}")
            df[numerical_cols] = self.scaler.transform(df[numerical_cols])
            self.logger.info(f"Scaled numerical columns: {numerical_cols}")
            return df
        except Exception as e:
            self.logger.error(f"Error preprocessing input data: {str(e)}")
            raise

    def predict(self, input_data: Dict[str, Any]) -> Dict[str, Any]:
        try:
            df = self.preprocess_input(input_data)
            features = [
                'Age', 'Gender', 'Ethnicity', 'EducationLevel', 'BMI', 'Smoking',
                'PhysicalActivity', 'DietQuality', 'SleepQuality', 'PollutionExposure',
                'PollenExposure', 'DustExposure', 'PetAllergy', 'FamilyHistoryAsthma',
                'HistoryOfAllergies', 'Eczema', 'HayFever', 'GastroesophagealReflux',
                'LungFunctionFEV1', 'LungFunctionFVC', 'Wheezing', 'ShortnessOfBreath',
                'ChestTightness', 'Coughing', 'NighttimeSymptoms', 'ExerciseInduced'
            ]
            X = df[features]
            prediction = self.model.predict(X)[0]
            # دايمًا رجّع احتمالية الكلاس الإيجابي (Asthma)
            probability = self.model.predict_proba(X)[0][1]
            diagnosis = "Asthma" if prediction == 1 else "No Asthma"
            return {
                "prediction": int(prediction),
                "probability": float(probability),
                "diagnosis": diagnosis,
                "class_predicted": "Asthma" if prediction == 1 else "No Asthma",
                "probability_note": "Probability represents the likelihood of Asthma"
            }
        except Exception as e:
            self.logger.error(f"Error during prediction: {str(e)}")
            raise
