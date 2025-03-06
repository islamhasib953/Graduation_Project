import sys
import json
import numpy as np
from sklearn.ensemble import IsolationForest


def validate_data(new_data, last_readings):
    # Convert JSON data to NumPy arrays
    data_points = [list(d.values())[:-1]
                   for d in last_readings]  # Exclude timestamp
    new_point = list(new_data.values())[:-1]  # Exclude timestamp

    # Train an anomaly detection model (Isolation Forest)
    model = IsolationForest(contamination=0.1, random_state=42)
    model.fit(data_points)

    # Predict new data (1 = normal, -1 = anomaly)
    prediction = model.predict([new_point])

    if prediction[0] == 1:
        print("1")  # Valid data
    else:
        print("0")  # Abnormal data


if __name__ == "__main__":
    new_data = json.loads(sys.argv[1])
    last_readings = json.loads(sys.argv[2])

    if len(last_readings) < 5:
        print("1")  # Accept first readings without validation
    else:
        validate_data(new_data, last_readings)
