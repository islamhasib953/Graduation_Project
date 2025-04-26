from pydantic import BaseModel


class AsthmaPatientData(BaseModel):
    Age: int
    Gender: int
    Ethnicity: int
    EducationLevel: int
    BMI: float
    Smoking: int
    PhysicalActivity: int
    DietQuality: int
    SleepQuality: int
    PollutionExposure: int
    PollenExposure: int
    DustExposure: int
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
