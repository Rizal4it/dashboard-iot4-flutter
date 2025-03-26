// lib/models/sensor.dart

class Sensor {
  final int id;
  final String sensorType;
  final String brand;
  final String? serialNumber;
  final DateTime createdAt;
  final DateTime updatedAt;

  Sensor({
    required this.id,
    required this.sensorType,
    required this.brand,
    this.serialNumber,
    required this.createdAt,
    required this.updatedAt,
  });
}
