const calculateAge = (birthDate) => {
  const today = new Date();
  const birth = new Date(birthDate);
  const ageInMilliseconds = today - birth;
  const ageInYears = ageInMilliseconds / (1000 * 60 * 60 * 24 * 365.25);
  return ageInYears;
};

const calculateActivity = (data, childAge) => {
  const bpm = data.bpm || 0;
  const avgGyro =
    ((data.gyroX || 0) + (data.gyroY || 0) + (data.gyroZ || 0)) / 3;
  const avgAcc = ((data.accX || 0) + (data.accY || 0) + (data.accZ || 0)) / 3;
  const spo2 = data.spo2 || 0;
  const temperature = data.temperature || 0;
  const ir = data.ir || 0;
  const red = data.red || 0;

  // تعديل النطاقات حسب العمر
  let bpmRanges = {
    Resting: [60, 90],
    "Light Activity": [90, 110],
    "Moderate Activity": [110, 130],
    "Intense Activity": [130, 160],
    "Distress/Stress": [140, 180],
  };
  let gyroRanges = {
    Resting: [0, 50],
    "Light Activity": [50, 150],
    "Moderate Activity": [150, 300],
    "Intense Activity": [300, 500],
    "Distress/Stress": [200, Infinity],
  };
  let spo2Ranges = {
    Resting: [96, 100],
    "Light Activity": [95, 99],
    "Moderate Activity": [94, 98],
    "Intense Activity": [92, 96],
    "Distress/Stress": [88, 94],
  };
  let tempRanges = {
    Resting: [36.0, 36.4],
    "Light Activity": [36.4, 36.7],
    "Moderate Activity": [36.7, 37.0],
    "Intense Activity": [37.0, 37.3],
    "Distress/Stress": [37.0, 37.5],
  };

  if (childAge <= 1) {
    bpmRanges.Resting = [90, 120];
    bpmRanges["Light Activity"] = [120, 140];
    bpmRanges["Moderate Activity"] = [140, 160];
    bpmRanges["Intense Activity"] = [160, 180];
    bpmRanges["Distress/Stress"] = [180, 200];
  } else if (childAge <= 3) {
    bpmRanges.Resting = [80, 110];
    bpmRanges["Light Activity"] = [110, 130];
    bpmRanges["Moderate Activity"] = [130, 150];
    bpmRanges["Intense Activity"] = [150, 170];
    bpmRanges["Distress/Stress"] = [170, 190];
  }

  const stages = [
    "Resting",
    "Light Activity",
    "Moderate Activity",
    "Intense Activity",
    "Distress/Stress",
  ];
  let bestMatch = "Resting";
  let maxScore = -Infinity;

  stages.forEach((stage) => {
    const bpmScore =
      bpm >= bpmRanges[stage][0] && bpm <= bpmRanges[stage][1] ? 1 : 0;
    const gyroScore =
      avgGyro >= gyroRanges[stage][0] && avgGyro <= gyroRanges[stage][1]
        ? 1
        : 0;
    const spo2Score =
      spo2 >= spo2Ranges[stage][0] && spo2 <= spo2Ranges[stage][1] ? 1 : 0;
    const tempScore =
      temperature >= tempRanges[stage][0] && temperature <= tempRanges[stage][1]
        ? 1
        : 0;
    const irScore = ir > 0 && ir < 30 ? 1 : 0;
    const score = bpmScore + gyroScore + spo2Score + tempScore + irScore * 0.5;

    if (score > maxScore) {
      maxScore = score;
      bestMatch = stage;
    }
  });

  if (
    data.validationStatus === "Invalid" ||
    bpm > 180 ||
    avgGyro > 500 ||
    spo2 < 88
  ) {
    bestMatch = "Distress/Stress";
  }

  return {
    activityStage: bestMatch,
    bpm,
    avgGyro,
    avgAcc,
    spo2,
    temperature,
    ir,
    red,
    status: data.status,
    timestamp: data.timestamp,
  };
};

const calculateSleepQuality = (data, childAge) => {
  const bpm = data.bpm || 0;
  const avgAcc = ((data.accX || 0) + (data.accY || 0) + (data.accZ || 0)) / 3;
  const avgGyro =
    ((data.gyroX || 0) + (data.gyroY || 0) + (data.gyroZ || 0)) / 3;
  const spo2 = data.spo2 || 0;
  const temperature = data.temperature || 0;
  const ir = data.ir || 0;
  const red = data.red || 0;

  let bpmRanges = {
    "Deep Sleep": [60, 80],
    "Light Sleep": [70, 90],
    REM: [75, 95],
    Awake: [85, 110],
    "Sleep Disturbance": [90, 120],
  };
  let accRanges = {
    "Deep Sleep": [0, 0.05],
    "Light Sleep": [0.05, 0.2],
    REM: [0.1, 0.3],
    Awake: [0.3, 1.0],
    "Sleep Disturbance": [0.5, Infinity],
  };
  let spo2Ranges = {
    "Deep Sleep": [96, 100],
    "Light Sleep": [95, 99],
    REM: [95, 99],
    Awake: [94, 98],
    "Sleep Disturbance": [90, 95],
  };
  let tempRanges = {
    "Deep Sleep": [35.8, 36.2],
    "Light Sleep": [36.0, 36.4],
    REM: [36.1, 36.5],
    Awake: [36.4, 36.8],
    "Sleep Disturbance": [36.5, 37.0],
  };

  if (childAge <= 1) {
    bpmRanges["Deep Sleep"] = [90, 110];
    bpmRanges["Light Sleep"] = [100, 120];
    bpmRanges.REM = [105, 125];
    bpmRanges.Awake = [115, 140];
    bpmRanges["Sleep Disturbance"] = [130, 150];
  } else if (childAge <= 3) {
    bpmRanges["Deep Sleep"] = [80, 100];
    bpmRanges["Light Sleep"] = [90, 110];
    bpmRanges.REM = [95, 115];
    bpmRanges.Awake = [105, 130];
    bpmRanges["Sleep Disturbance"] = [120, 140];
  }

  const stages = [
    "Deep Sleep",
    "Light Sleep",
    "REM",
    "Awake",
    "Sleep Disturbance",
  ];
  let bestMatch = "Deep Sleep";
  let maxScore = -Infinity;

  stages.forEach((stage) => {
    const bpmScore =
      bpm >= bpmRanges[stage][0] && bpm <= bpmRanges[stage][1] ? 1 : 0;
    const accScore =
      avgAcc >= accRanges[stage][0] && avgAcc <= accRanges[stage][1] ? 1 : 0;
    const spo2Score =
      spo2 >= spo2Ranges[stage][0] && spo2 <= spo2Ranges[stage][1] ? 1 : 0;
    const tempScore =
      temperature >= tempRanges[stage][0] && temperature <= tempRanges[stage][1]
        ? 1
        : 0;
    const irScore = ir > 0 && ir < 30 ? 1 : 0;
    const gyroScore = avgGyro < 50 ? 1 : 0;
    const score =
      bpmScore +
      accScore +
      spo2Score +
      tempScore +
      irScore * 0.5 +
      gyroScore * 0.5;

    if (score > maxScore) {
      maxScore = score;
      bestMatch = stage;
    }
  });

  if (
    data.validationStatus === "Invalid" ||
    bpm > 120 ||
    avgAcc > 1.0 ||
    spo2 < 90
  ) {
    bestMatch = "Sleep Disturbance";
  }

  return {
    sleepStage: bestMatch,
    bpm,
    avgAcc,
    avgGyro,
    spo2,
    temperature,
    ir,
    red,
    status: data.status,
    timestamp: data.timestamp,
  };
};

module.exports = { calculateActivity, calculateSleepQuality };
