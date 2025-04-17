import pandas as pd
import numpy as np
from datetime import datetime, timedelta

# Define sleep stage characteristics based on provided ranges
sleep_stages = {
    "Deep Sleep": {
        "heart_rate": (60, 80),
        "acceleration": (0, 0.05),
        "spo2": (96, 100),
        "temperature": (35.8, 36.2)
    },
    "Light Sleep": {
        "heart_rate": (70, 90),
        "acceleration": (0.05, 0.2),
        "spo2": (95, 99),
        "temperature": (36.0, 36.4)
    },
    "REM": {
        "heart_rate": (75, 95),
        "acceleration": (0.1, 0.3),
        "spo2": (95, 99),
        "temperature": (36.1, 36.5)
    },
    "Awake": {
        "heart_rate": (85, 110),
        "acceleration": (0.3, 1.0),
        "spo2": (94, 98),
        "temperature": (36.4, 36.8)
    },
    "Sleep Disturbance": {
        "heart_rate": (90, 120),
        "acceleration": (0.5, 1.5),
        "spo2": (90, 95),
        "temperature": (36.5, 37.0)
    }
}

# Function to generate random sensor data for a given sleep stage
def generate_sensor_data(sleep_stage):
    stage_data = sleep_stages[sleep_stage]
    heart_rate = np.random.randint(stage_data["heart_rate"][0], stage_data["heart_rate"][1] + 1)
    acceleration = np.round(np.random.uniform(stage_data["acceleration"][0], stage_data["acceleration"][1]), 2)
    spo2 = np.random.randint(stage_data["spo2"][0], stage_data["spo2"][1] + 1)
    temperature = np.round(np.random.uniform(stage_data["temperature"][0], stage_data["temperature"][1]), 1)
    return heart_rate, acceleration, spo2, temperature

# Generate balanced dataset
np.random.seed(42)  # For reproducibility
total_rows = 10000
rows_per_stage = total_rows // len(sleep_stages)  # 1000 rows per sleep stage
data = []

for stage in sleep_stages.keys():
    for i in range(rows_per_stage):
        heart_rate, acceleration, spo2, temperature = generate_sensor_data(stage)
        data.append({
            "Heart_Rate": heart_rate,
            "Acceleration": acceleration,
            "SpO2": spo2,
            "Temperature": temperature,
            "Predicted_Sleep_Stage": stage
        })

# Shuffle the dataset to avoid ordered sleep stages
df = pd.DataFrame(data)
df = df.sample(frac=1, random_state=42).reset_index(drop=True)

# Save to CSV
df.to_csv("balanced_sleep_quality_dataset_no_timestamp_10t.csv", index=False)

# Display the first few rows and class distribution
print("First 5 rows of the dataset:")
print(df.head())
print("\nClass distribution:")
print(df["Predicted_Sleep_Stage"].value_counts())