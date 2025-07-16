class SensorDataModel {
  final String? childId;
  final double? temperature;
  final double? spo2;
  final double? latitude;
  final double? longitude;
  final double? gyroX;
  final double? gyroY;
  final double? gyroZ;
  final double? bpm;
  final double? ir;
  final double? red;
  final double? accX;
  final double? accY;
  final double? accZ;
  final String? status;
  final String? validationStatus;
  final int? timestamp;
  final DateTime? createdAt;

  SensorDataModel({
    this.childId,
    this.temperature,
    this.spo2,
    this.latitude,
    this.longitude,
    this.gyroX,
    this.gyroY,
    this.gyroZ,
    this.bpm,
    this.ir,
    this.red,
    this.accX,
    this.accY,
    this.accZ,
    this.status,
    this.validationStatus,
    this.timestamp,
    this.createdAt,
  });

  factory SensorDataModel.fromJson(Map<String, dynamic> json) {
    return SensorDataModel(
      childId: json['childId']?.toString(),
      temperature: json['temperature'] != null ? double.tryParse(json['temperature'].toString()) : null,
      spo2: json['spo2'] != null ? double.tryParse(json['spo2'].toString()) : null,
      latitude: json['latitude'] != null ? double.tryParse(json['latitude'].toString()) : null,
      longitude: json['longitude'] != null ? double.tryParse(json['longitude'].toString()) : null,
      gyroX: json['gyroX'] != null ? double.tryParse(json['gyroX'].toString()) : null,
      gyroY: json['gyroY'] != null ? double.tryParse(json['gyroY'].toString()) : null,
      gyroZ: json['gyroZ'] != null ? double.tryParse(json['gyroZ'].toString()) : null,
      bpm: json['bpm'] != null ? double.tryParse(json['bpm'].toString()) : null,
      ir: json['ir'] != null ? double.tryParse(json['ir'].toString()) : null,
      red: json['red'] != null ? double.tryParse(json['red'].toString()) : null,
      accX: json['accX'] != null ? double.tryParse(json['accX'].toString()) : null,
      accY: json['accY'] != null ? double.tryParse(json['accY'].toString()) : null,
      accZ: json['accZ'] != null ? double.tryParse(json['accZ'].toString()) : null,
      status: json['status']?.toString(),
      validationStatus: json['validationStatus']?.toString(),
      timestamp: json['timestamp'] as int?,
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt'].toString()) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'childId': childId,
      'temperature': temperature,
      'spo2': spo2,
      'latitude': latitude,
      'longitude': longitude,
      'gyroX': gyroX,
      'gyroY': gyroY,
      'gyroZ': gyroZ,
      'bpm': bpm,
      'ir': ir,
      'red': red,
      'accX': accX,
      'accY': accY,
      'accZ': accZ,
      'status': status,
      'validationStatus': validationStatus,
      'timestamp': timestamp,
      'createdAt': createdAt?.toIso8601String(),
    };
  }
}