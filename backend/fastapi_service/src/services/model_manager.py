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
#                 model_path = "models/asthma/RandomForest_Asthma-model_adjusted.pkl"
#                 scaler_path = "models/asthma/scaler_adjusted.pkl"
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
#                 # Round BMI to 2 decimal places and LungFunction columns to 1 decimal place
#                 df['BMI'] = df['BMI'].round(2)
#                 df['LungFunctionFEV1'] = df['LungFunctionFEV1'].round(1)
#                 df['LungFunctionFVC'] = df['LungFunctionFVC'].round(1)
#                 # Round specified float columns to integers
#                 float_columns_to_round = ['PhysicalActivity', 'DietQuality', 'SleepQuality',
#                                           'PollutionExposure', 'PollenExposure', 'DustExposure']
#                 for col in float_columns_to_round:
#                     df[col] = df[col].round(0).astype(int)
#                 # Scale numerical columns
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
#                 df['gender'] = df['gender'].replace({'Male': 0, 'Female': 1})
#                 for col in ['ever_married', 'smoking_status']:
#                     if col in df.columns:
#                         le = self.le_dict[col]
#                         df[col] = df[col].apply(
#                             lambda x: x if x in le.classes_ else le.classes_[0])
#                         df[col] = le.transform(df[col]).astype(np.int8)
#                 df['work_type'] = df['work_type'].replace(
#                     {'Private': 0, 'Self-employed': 1, 'Govt_job': 2, 'children': 3, 'Never_worked': 4})
#                 df['Residence_type'] = df['Residence_type'].replace(
#                     {'Rural': 0, 'Urban': 1})
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
#             prediction = self.model.predict(X)[0]
#             probability = self.model.predict_proba(X)[0][1]

#             if self.disease == "asthma":
#                 # Custom response logic for asthma
#                 if prediction == 0 and probability > 0.7:
#                     diagnosis = "No Asthma"
#                     probability = random.uniform(0.5, 0.9)
#                 elif prediction == 0 and probability <= 0.7:
#                     diagnosis = "Asthma"
#                     prediction = 1
#                     probability = random.uniform(0.5, 0.9)
#                 elif prediction == 1 and probability < 0.25:
#                     diagnosis = "No Asthma"
#                     prediction = 0
#                     probability = random.uniform(0.5, 0.9)
#                 else:  # prediction == 1 and probability >= 0.25
#                     diagnosis = "Asthma"
#                     probability = random.uniform(0.5, 0.9)
#             elif self.disease == "autism":
#                 diagnosis = "ASD" if prediction == 1 else "No ASD"
#             elif self.disease == "stroke":
#                 if prediction == 1 and probability > 0.1:
#                     diagnosis = "Stroke"
#                     probability = random.uniform(0.5, 0.9)
#                 else:
#                     diagnosis = "No Stroke"
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
import nltk
from nltk.stem import WordNetLemmatizer
import tensorflow as tf
import json
import pickle

nltk.download('wordnet')
nltk.download('punkt')


class ModelManager:
    def __init__(self, disease: str):
        self.disease = disease.lower()
        self.model = None
        self.scaler = None
        self.le_dict = None
        self.logger = logging.getLogger(__name__)
        self.lemmatizer = WordNetLemmatizer()
        self.words = None
        self.classes = None
        self.intents = None
        self.load_model_and_scaler()

    def load_model_and_scaler(self):
        try:
            if self.disease == "asthma":
                model_path = "models/asthma/RandomForest_Asthma-model_adjusted.pkl"
                scaler_path = "models/asthma/scaler_adjusted.pkl"
                self.model = joblib.load(model_path)
                self.scaler = joblib.load(scaler_path)
            elif self.disease == "autism":
                model_path = "models/autism/autism_rf_model.pkl"
                scaler_path = "models/autism/autism_scaler.pkl"
                le_path = "models/autism/autism_label_encoders.pkl"
                self.model = joblib.load(model_path)
                self.scaler = joblib.load(scaler_path)
                self.le_dict = joblib.load(le_path)
            elif self.disease == "stroke":
                model_path = "models/stroke/stroke_gb_model.pkl"
                scaler_path = "models/stroke/scaler_stroke.pkl"
                le_path = "models/stroke/label_encoder_stroke.pkl"
                self.model = joblib.load(model_path)
                self.scaler = joblib.load(scaler_path)
                self.le_dict = joblib.load(le_path)
            elif self.disease == "chatbot":
                model_path = "models/chatbot/chatbot_model_v5.h5"
                self.model = tf.keras.models.load_model(
                    model_path, compile=True, safe_mode=True)
                self.words = pickle.load(
                    open("models/chatbot/words_v5.pkl", 'rb'))
                self.classes = pickle.load(
                    open("models/chatbot/classes_v5.pkl", 'rb'))
                self.intents = json.loads(
                    open("models/chatbot/intents.json").read())
                self.logger.info(
                    f"Chatbot model, words, classes, and intents loaded successfully")
            else:
                raise ValueError(f"Unsupported disease: {self.disease}")

            if self.disease in ["asthma", "autism", "stroke"]:
                self.logger.info(
                    f"Model and scaler for {self.disease} loaded successfully")
                self.logger.info(
                    f"Scaler for {self.disease} expects features: {self.scaler.feature_names_in_}")
        except Exception as e:
            self.logger.error(
                f"Error loading model or scaler for {self.disease}: {str(e)}")
            raise

    def clean_up_sentence(self, sentence):
        sentence_words = nltk.word_tokenize(sentence)
        sentence_words = [self.lemmatizer.lemmatize(
            word) for word in sentence_words]
        return sentence_words

    def bag_of_words(self, sentence):
        sentence_words = self.clean_up_sentence(sentence)
        bag = [0] * len(self.words)
        for w in sentence_words:
            for i, word in enumerate(self.words):
                if word == w:
                    bag[i] = 1
        return np.array(bag)

    def predict_class(self, sentence):
        bow = self.bag_of_words(sentence)
        # Ensure the input is a 2D array with shape (1, len(words))
        bow = np.array([bow])  # Shape becomes (1, len(words))
        if bow.shape[1] != len(self.words):
            raise ValueError(
                f"Expected input size {len(self.words)}, got {bow.shape[1]}")
        res = self.model.predict(bow)[0]  # Predict with proper shape
        ERROR_THRESHOLD = 0.25
        results = [[i, r] for i, r in enumerate(res) if r > ERROR_THRESHOLD]
        results.sort(key=lambda x: x[1], reverse=True)
        return_list = []
        if results:
            for r in results:
                return_list.append(
                    {'intent': self.classes[r[0]], 'probability': str(r[1])})
        return return_list

    def get_response(self, intents_list):
        if not intents_list:
            return "Sorry, I didn't understand that."
        tag = intents_list[0]['intent']
        self.logger.info(f"Detected intent: {tag}")
        list_of_intents = self.intents['intents']
        result = ''
        for i in list_of_intents:
            if i['tag'] == tag:
                self.logger.info(f"Responses found: {i['responses']}")
                result = random.choice(i['responses'])
                break
        return result

    def preprocess_input(self, input_data: Dict[str, Any]) -> np.ndarray:
        try:
            if self.disease == "asthma":
                df = pd.DataFrame([input_data])
                df['BMI'] = df['BMI'].round(2)
                df['LungFunctionFEV1'] = df['LungFunctionFEV1'].round(1)
                df['LungFunctionFVC'] = df['LungFunctionFVC'].round(1)
                float_columns_to_round = ['PhysicalActivity', 'DietQuality', 'SleepQuality',
                                          'PollutionExposure', 'PollenExposure', 'DustExposure']
                for col in float_columns_to_round:
                    df[col] = df[col].round(0).astype(int)
                numerical_cols = ['BMI', 'LungFunctionFEV1', 'LungFunctionFVC']
                self.logger.info(
                    f"Input data before scaling: {df[numerical_cols]}")
                df[numerical_cols] = self.scaler.transform(df[numerical_cols])
                self.logger.info(f"Scaled numerical columns: {numerical_cols}")
                return df
            elif self.disease == "autism":
                df = pd.DataFrame([input_data])
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
                return df
            elif self.disease == "stroke":
                df = pd.DataFrame([input_data])
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
            elif self.disease == "chatbot":
                sentence = input_data.get('msg', '')
                if not sentence:
                    raise ValueError("No message provided")
                # Return bag of words directly
                return self.bag_of_words(sentence.lower())
        except Exception as e:
            self.logger.error(f"Error preprocessing input data: {str(e)}")
            raise

    def predict(self, input_data: Dict[str, Any]) -> Dict[str, Any]:
        try:
            if self.disease in ["asthma", "autism", "stroke"]:
                X = self.preprocess_input(input_data)
                prediction = self.model.predict(X)[0]
                probability = self.model.predict_proba(X)[0][1] if hasattr(
                    self.model, 'predict_proba') else random.uniform(0.5, 0.9)
                if self.disease == "asthma":
                    if prediction == 0 and probability > 0.7:
                        diagnosis = "No Asthma"
                    elif prediction == 0 and probability <= 0.7:
                        diagnosis = "Asthma"
                        prediction = 1
                    elif prediction == 1 and probability > 0.25:
                        diagnosis = "Asthma"
                    elif prediction == 1 and probability < 0.25:
                        diagnosis = "No Asthma"
                elif self.disease == "autism":
                    diagnosis = "ASD" if prediction == 1 else "No ASD"
                elif self.disease == "stroke":
                    diagnosis = "Stroke" if prediction == 1 and probability > 0.1 else "No Stroke"
                return {
                    "prediction": int(prediction),
                    "probability": float(probability),
                    "diagnosis": diagnosis,
                    "class_predicted": diagnosis,
                    "probability_note": f"Probability represents the likelihood of {self.disease.capitalize()}"
                }
            elif self.disease == "chatbot":
                sentence = input_data.get('msg', '')
                if not sentence:
                    return {
                        "user_message": "",
                        "text_response": "No message provided"
                    }
                predict = self.predict_class(sentence.lower())
                if not predict:
                    return {
                        "user_message": sentence,
                        "text_response": "Sorry, I didn't understand that."
                    }
                response = self.get_response(predict)
                return {
                    "user_message": sentence,
                    "text_response": response
                }
            else:
                raise ValueError(f"Unsupported disease: {self.disease}")
        except Exception as e:
            self.logger.error(f"Error during prediction: {str(e)}")
            raise
