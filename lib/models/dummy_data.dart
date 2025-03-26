// lib/data/dummy_data.dart

import 'package:manlogen/models/sensor.dart';

List<Sensor> dummySensors = [
  Sensor(
    id: 1,
    sensorType: 'distance',
    brand: 'BrandA',
    serialNumber: '12345',
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  ),
  Sensor(
    id: 2,
    sensorType: 'led',
    brand: 'BrandB',
    serialNumber: '67890',
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  ),
  // Add more sensors here
];
