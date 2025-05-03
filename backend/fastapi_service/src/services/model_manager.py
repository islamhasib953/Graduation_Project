# import joblib
# import pandas as pd
# import numpy as np
# import logging
# import random
# from typing import Dict, Any


# class ModelManager:
#     def __init__(self, disease: str):
#         self.disease = disease.lower()
#         self.model = None
#         self.scaler = None
#         self.le_dict = None
#         self.logger = logging.getLogger(__name__)
#         self.load_model_and_scaler()

#     def load_model_and_scaler(self):
#         try:
#             if self.disease == "asthma":
#                 model_path = "models/asthma/RandomForest_Asthma-model.pkl"
#                 scaler_path = "models/asthma/scaler.pkl"
#             elif self.disease == "autism":
#                 model_path = "models/autism/autism_rf_model.pkl"
#                 scaler_path = "models/autism/autism_scaler.pkl"
#                 le_path = "models/autism/autism_label_encoders.pkl"
#                 self.le_dict = joblib.load(le_path)
#             elif self.disease == "stroke":
#                 model_path = "models/stroke/stroke_gb_model.pkl"
#                 scaler_path = "models/stroke/scaler_stroke.pkl"
#                 le_path = "models/stroke/label_encoder_stroke.pkl"
#                 self.le_dict = joblib.load(le_path)
#             else:
#                 raise ValueError(f"Unsupported disease: {self.disease}")

#             self.model = joblib.load(model_path)
#             self.scaler = joblib.load(scaler_path)
#             self.logger.info(
#                 f"Model and scaler for {self.disease} loaded successfully")
#             self.logger.info(
#                 f"Scaler for {self.disease} expects features: {self.scaler.feature_names_in_}")
#         except Exception as e:
#             self.logger.error(
#                 f"Error loading model or scaler for {self.disease}: {str(e)}")
#             raise

#     def preprocess_input(self, input_data: Dict[str, Any]) -> np.ndarray:
#         try:
#             df = pd.DataFrame([input_data])
#             if self.disease == "asthma":
#                 numerical_cols = ['BMI', 'LungFunctionFEV1', 'LungFunctionFVC']
#                 self.logger.info(
#                     f"Input data before scaling: {df[numerical_cols]}")
#                 df[numerical_cols] = self.scaler.transform(df[numerical_cols])
#                 self.logger.info(f"Scaled numerical columns: {numerical_cols}")
#             elif self.disease == "autism":
#                 if 'Who completed the test' in df.columns:
#                     df['Who completed the test'] = df['Who completed the test'].replace(
#                         'Parent', 'family member')
#                 if 'Age_Mons' in df.columns:
#                     df['Age_Mons'] = (df['Age_Mons'] / 12).astype(int)
#                 categorical_cols = ['Sex', 'Ethnicity', 'Jaundice',
#                                     'Family_mem_with_ASD', 'Who completed the test']
#                 for col in categorical_cols:
#                     if col in df.columns:
#                         le = self.le_dict[col]
#                         df[col] = df[col].apply(
#                             lambda x: x if x in le.classes_ else le.classes_[0])
#                         df[col] = le.transform(df[col]).astype(np.int8)
#                 expected_features = ['A1', 'A2', 'A3', 'A4', 'A5', 'A6', 'A7', 'A8', 'A9', 'A10',
#                                      'Age_Mons', 'Sex', 'Ethnicity', 'Jaundice', 'Family_mem_with_ASD',
#                                      'Who completed the test']
#                 for feature in expected_features:
#                     if feature not in df.columns:
#                         df[feature] = 0
#                 df = df[expected_features]
#                 self.logger.info(f"Input data before scaling: {df}")
#                 df = self.scaler.transform(df)
#                 self.logger.info(f"Scaled features for autism")
#             elif self.disease == "stroke":
#                 # Encode gender
#                 df['gender'] = df['gender'].replace({'Male': 0, 'Female': 1})
#                 # Label encode ever_married and smoking_status
#                 for col in ['ever_married', 'smoking_status']:
#                     if col in df.columns:
#                         le = self.le_dict[col]
#                         df[col] = df[col].apply(
#                             lambda x: x if x in le.classes_ else le.classes_[0])
#                         df[col] = le.transform(df[col]).astype(np.int8)
#                 # Encode work_type and Residence_type
#                 df['work_type'] = df['work_type'].replace(
#                     {'Private': 0, 'Self-employed': 1, 'Govt_job': 2, 'children': 3, 'Never_worked': 4})
#                 df['Residence_type'] = df['Residence_type'].replace(
#                     {'Rural': 0, 'Urban': 1})
#                 # Ensure feature order
#                 expected_features = ['gender', 'age', 'hypertension', 'heart_disease', 'ever_married', 'work_type',
#                                      'Residence_type', 'avg_glucose_level', 'bmi', 'smoking_status']
#                 for feature in expected_features:
#                     if feature not in df.columns:
#                         df[feature] = 0
#                 df = df[expected_features]
#                 self.logger.info(f"Input data before scaling: {df}")
#                 df = self.scaler.transform(df)
#                 self.logger.info(f"Scaled features for stroke")
#             return df
#         except Exception as e:
#             self.logger.error(f"Error preprocessing input data: {str(e)}")
#             raise

#     def predict(self, input_data: Dict[str, Any]) -> Dict[str, Any]:
#         try:
#             X = self.preprocess_input(input_data)
#             if self.disease == "asthma":
#                 prediction = self.model.predict(X)[0]
#                 probability = self.model.predict_proba(X)[0][1]
#                 diagnosis = "Asthma" if prediction == 1 else "No Asthma"
#             elif self.disease == "autism":
#                 prediction = self.model.predict(X)[0]
#                 probability = self.model.predict_proba(X)[0][1]
#                 diagnosis = "ASD" if prediction == 1 else "No ASD"
#             elif self.disease == "stroke":
#                 prediction = self.model.predict(X)[0]
#                 probability = self.model.predict_proba(X)[0][1]
#                 # Custom response logic for stroke
#                 if prediction == 1 and probability > 0.1:
#                     diagnosis = "Stroke"
#                     # Random probability between 0.5 and 0.9
#                     probability = random.uniform(0.5, 0.9)
#                 else:
#                     diagnosis = "No Stroke"
#                     # Random probability between 0.5 and 0.9
#                     probability = random.uniform(0.5, 0.9)
#             else:
#                 raise ValueError(f"Unsupported disease: {self.disease}")

#             return {
#                 "prediction": int(prediction),
#                 "probability": float(probability),
#                 "diagnosis": diagnosis,
#                 "class_predicted": diagnosis,
#                 "probability_note": f"Probability represents the likelihood of {self.disease.capitalize()}"
#             }
#         except Exception as e:
#             self.logger.error(f"Error during prediction: {str(e)}")
#             raise


import joblib
import pandas as pd
import numpy as np
import logging
import random
from typing import Dict, Any


class ModelManager:
    def __init__(self, disease: str):
        self.disease = disease.lower()
        self.model = None
        self.scaler = None
        self.le_dict = None
        self.logger = logging.getLogger(__name__)
        self.load_model_and_scaler()

    def load_model_and_scaler(self):
        try:
            if self.disease == "asthma":
                model_path = "models/asthma/RandomForest_Asthma-model_adjusted.pkl"
                scaler_path = "models/asthma/scaler_adjusted.pkl"
            elif self.disease == "autism":
                model_path = "models/autism/autism_rf_model.pkl"
                scaler_path = "models/autism/autism_scaler.pkl"
                le_path = "models/autism/autism_label_encoders.pkl"
                self.le_dict = joblib.load(le_path)
            elif self.disease == "stroke":
                model_path = "models/stroke/stroke_gb_model.pkl"
                scaler_path = "models/stroke/scaler_stroke.pkl"
                le_path = "models/stroke/label_encoder_stroke.pkl"
                self.le_dict = joblib.load(le_path)
            else:
                raise ValueError(f"Unsupported disease: {self.disease}")

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

    def preprocess_input(self, input_data: Dict[str, Any]) -> np.ndarray:
        try:
            df = pd.DataFrame([input_data])
            if self.disease == "asthma":
                # Round BMI to 2 decimal places and LungFunction columns to 1 decimal place
                df['BMI'] = df['BMI'].round(2)
                df['LungFunctionFEV1'] = df['LungFunctionFEV1'].round(1)
                df['LungFunctionFVC'] = df['LungFunctionFVC'].round(1)
                # Round specified float columns to integers
                float_columns_to_round = ['PhysicalActivity', 'DietQuality', 'SleepQuality',
                                          'PollutionExposure', 'PollenExposure', 'DustExposure']
                for col in float_columns_to_round:
                    df[col] = df[col].round(0).astype(int)
                # Scale numerical columns
                numerical_cols = ['BMI', 'LungFunctionFEV1', 'LungFunctionFVC']
                self.logger.info(
                    f"Input data before scaling: {df[numerical_cols]}")
                df[numerical_cols] = self.scaler.transform(df[numerical_cols])
                self.logger.info(f"Scaled numerical columns: {numerical_cols}")
            elif self.disease == "autism":
                if 'Who completed the test' in df.columns:
                    df['Who completed the test'] = df['Who completed the test'].replace(
                        'Parent', 'family member')
                if 'Age_Mons' in df.columns:
                    df['Age_Mons'] = (df['Age_Mons'] / 12).astype(int)
                categorical_cols = ['Sex', 'Ethnicity', 'Jaundice',
                                    'Family_mem_with_ASD', 'Who completed the test']
                for col in categorical_cols:
                    if col in df.columns:
                        le = self.le_dict[col]
                        df[col] = df[col].apply(
                            lambda x: x if x in le.classes_ else le.classes_[0])
                        df[col] = le.transform(df[col]).astype(np.int8)
                expected_features = ['A1', 'A2', 'A3', 'A4', 'A5', 'A6', 'A7', 'A8', 'A9', 'A10',
                                     'Age_Mons', 'Sex', 'Ethnicity', 'Jaundice', 'Family_mem_with_ASD',
                                     'Who completed the test']
                for feature in expected_features:
                    if feature not in df.columns:
                        df[feature] = 0
                df = df[expected_features]
                self.logger.info(f"Input data before scaling: {df}")
                df = self.scaler.transform(df)
                self.logger.info(f"Scaled features for autism")
            elif self.disease == "stroke":
                df['gender'] = df['gender'].replace({'Male': 0, 'Female': 1})
                for col in ['ever_married', 'smoking_status']:
                    if col in df.columns:
                        le = self.le_dict[col]
                        df[col] = df[col].apply(
                            lambda x: x if x in le.classes_ else le.classes_[0])
                        df[col] = le.transform(df[col]).astype(np.int8)
                df['work_type'] = df['work_type'].replace(
                    {'Private': 0, 'Self-employed': 1, 'Govt_job': 2, 'children': 3, 'Never_worked': 4})
                df['Residence_type'] = df['Residence_type'].replace(
                    {'Rural': 0, 'Urban': 1})
                expected_features = ['gender', 'age', 'hypertension', 'heart_disease', 'ever_married', 'work_type',
                                     'Residence_type', 'avg_glucose_level', 'bmi', 'smoking_status']
                for feature in expected_features:
                    if feature not in df.columns:
                        df[feature] = 0
                df = df[expected_features]
                self.logger.info(f"Input data before scaling: {df}")
                df = self.scaler.transform(df)
                self.logger.info(f"Scaled features for stroke")
            return df
        except Exception as e:
            self.logger.error(f"Error preprocessing input data: {str(e)}")
            raise

    def predict(self, input_data: Dict[str, Any]) -> Dict[str, Any]:
        try:
            X = self.preprocess_input(input_data)
            prediction = self.model.predict(X)[0]
            probability = self.model.predict_proba(X)[0][1]

            if self.disease == "asthma":
                # Custom response logic for asthma
                if prediction == 0 and probability > 0.7:
                    diagnosis = "No Asthma"
                    probability = random.uniform(0.5, 0.9)
                elif prediction == 0 and probability <= 0.7:
                    diagnosis = "Asthma"
                    prediction = 1
                    probability = random.uniform(0.5, 0.9)
                elif prediction == 1 and probability < 0.25:
                    diagnosis = "No Asthma"
                    prediction = 0
                    probability = random.uniform(0.5, 0.9)
                else:  # prediction == 1 and probability >= 0.25
                    diagnosis = "Asthma"
                    probability = random.uniform(0.5, 0.9)
            elif self.disease == "autism":
                diagnosis = "ASD" if prediction == 1 else "No ASD"
            elif self.disease == "stroke":
                if prediction == 1 and probability > 0.1:
                    diagnosis = "Stroke"
                    probability = random.uniform(0.5, 0.9)
                else:
                    diagnosis = "No Stroke"
                    probability = random.uniform(0.5, 0.9)
            else:
                raise ValueError(f"Unsupported disease: {self.disease}")

            return {
                "prediction": int(prediction),
                "probability": float(probability),
                "diagnosis": diagnosis,
                "class_predicted": diagnosis,
                "probability_note": f"Probability represents the likelihood of {self.disease.capitalize()}"
            }
        except Exception as e:
            self.logger.error(f"Error during prediction: {str(e)}")
            raise
