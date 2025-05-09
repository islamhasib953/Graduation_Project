# Baby Monitoring System - Vital Signs Ranges

This document outlines the vital signs ranges used in the baby monitoring system for validating sensor data (`ValidatedSensorData`), calculating baby activity (`BabyActivity`), and assessing sleep quality (`SleepQuality`). The ranges are defined based on the child's age and are derived from medical standards.

## Vital Signs Ranges by Age

### 1. Heart Rate (bpm)
Used in:
- `sensorData.controller.js` (`validateReading` for `ValidatedSensorData`)
- `activityLogic.js` (`calculateActivity` and `calculateSleepQuality`)

| Age Group         | Validation Range (bpm) | Activity Ranges (bpm) | Sleep Ranges (bpm) |
|-------------------|-----------------------|----------------------|-------------------|
| 0.5 to <1 year    | 80-170                | Resting: 80-120<br>Light: 120-140<br>Moderate: 140-160<br>Intense: 160-170<br>Distress: 170-200 | Deep: 80-110<br>Light: 110-130<br>REM: 120-140<br>Awake: 130-160<br>Disturbance: 160-170 |
| 1 to <3 years     | 80-150                | Resting: 80-110<br>Light: 110-130<br>Moderate: 130-150<br>Intense: 150-160<br>Distress: 160-190 | Deep: 80-100<br>Light: 100-120<br>REM: 110-130<br>Awake: 120-140<br>Disturbance: 140-150 |
| 3 to <5 years     | 70-130                | Resting: 70-100<br>Light: 100-120<br>Moderate: 120-130<br>Intense: 130-140<br>Distress: 140-180 | Deep: 70-90<br>Light: 90-110<br>REM: 100-120<br>Awake: 110-130<br>Disturbance: 130-140 |
| 5 to 7 years      | 65-120                | Resting: 65-100<br>Light: 100-120<br>Moderate: 120-140<br>Intense: 140-160<br>Distress: 160-200 | Deep: 65-80<br>Light: 80-100<br>REM: 85-110<br>Awake: 100-120<br>Disturbance: 120-140 |

### 2. Respiratory Rate (ir)
Used in:
- `sensorData.controller.js` (`validateReading` for `ValidatedSensorData`)
- `activityLogic.js` (scoring in `calculateActivity` and `calculateSleepQuality`)

| Age Group         | Validation Range (breaths/min) |
|-------------------|-------------------------------|
| 0.5 to <1 year    | 30-55                         |
| 1 to <3 years     | 20-30                         |
| 3 to <5 years     | 20-25                         |
| 5 to 7 years      | 14-22                         |

**Note**: In `calculateActivity` and `calculateSleepQuality`, `ir` is used for scoring (0.5 if `0 < ir < 55`).

### 3. Oxygen Saturation (spo2)
Used in:
- `sensorData.controller.js` (`validateReading` for `ValidatedSensorData`)
- `activityLogic.js` (`calculateActivity` and `calculateSleepQuality`)

| Age Group         | Validation Range (%) | Activity Ranges (%) | Sleep Ranges (%) |
|-------------------|---------------------|--------------------|-----------------|
| All Ages          | 90-100              | Resting: 95-100<br>Light: 94-99<br>Moderate: 93-98<br>Intense: 92-97<br>Distress: 90-95 | Deep: 95-100<br>Light: 94-99<br>REM: 94-99<br>Awake: 93-98<br>Disturbance: 90-95 |

### 4. Temperature
Used in:
- `sensorData.controller.js` (`validateReading` for `ValidatedSensorData`)
- `activityLogic.js` (`calculateActivity` and `calculateSleepQuality`)

| Age Group         | Validation Range (°C) | Activity Ranges (°C) | Sleep Ranges (°C) |
|-------------------|----------------------|--------------------|------------------|
| All Ages          | 36.1-37.9            | Resting: 36.1-36.5<br>Light: 36.5-36.9<br>Moderate: 36.9-37.3<br>Intense: 37.3-37.7<br>Distress: 37.7-37.9 | Deep: 36.1-36.3<br>Light: 36.3-36.5<br>REM: 36.5-36.7<br>Awake: 36.7-37.5<br>Disturbance: 37.5-37.9 |

### 5. Sensor Reading (red)
Used in:
- `sensorData.controller.js` (`validateReading` for `ValidatedSensorData`)

| Age Group         | Validation Range |
|-------------------|------------------|
| All Ages          | 1000-20000       |

**Note**: This range is device-specific and not based on medical standards.

### 6. Gyroscope (gyro) and Accelerometer (acc)
Used in:
- `activityLogic.js` (`calculateActivity` and `calculateSleepQuality`)

| Measurement       | Activity Ranges | Sleep Ranges |
|-------------------|----------------|-------------|
| Gyroscope (avgGyro) | Resting: 0-0.2<br>Light: 0.2-0.4<br>Moderate: 0.4-0.6<br>Intense: 0.6-0.8<br>Distress: 0.8-Infinity | Scoring: 1 if avgGyro < 0.2 |
| Accelerometer (avgAcc) | Not used in scoring | Deep: 0-0.1<br>Light: 0.1-0.3<br>REM: 0.2-0.4<br>Awake: 0.3-0.6<br>Disturbance: 0.5-Infinity |

**Note**: These ranges are device-specific and not based on medical standards.

## Sources
The ranges are based on the following medical references:
1. [eMedicineHealth - Pediatric Vital Signs](https://www.emedicinehealth.com/pediatric_vital_signs/article_em.htm)
2. [Verywell Health - Pediatric Vital Signs](https://www.verywellhealth.com/pediatric_vital_signs/article_em.htm)
3. [PMC - Vital Signs in Children](https://pmc.ncbi.nlm.nih.gov/articles/PMC3789232/)
4. [WebMD - Children's Vital Signs](https://www.webmd.com/children/children-vital-signs)

## Notes
- The `bpm` ranges for validation are broader to cover both resting and active states, while `activityLogic.js` uses narrower ranges to differentiate activity/sleep stages.
- The `ir` ranges are used primarily for validation and contribute to scoring in activity/sleep calculations.
- The `spo2` and `temperature` ranges are unified across ages for simplicity, as medical standards show minimal variation.
- The `red` range is adjusted to match realistic device outputs based on `mqtt.service.js` data.
- Gyroscope and accelerometer ranges are unchanged as they are device-specific.

For any issues or further refinements, please contact the development team.