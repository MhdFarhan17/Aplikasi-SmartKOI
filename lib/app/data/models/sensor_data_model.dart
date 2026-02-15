// lib/app/data/models/sensor_data_model.dart

import 'package:firebase_database/firebase_database.dart';

class SensorData {
  final String kekeruhan; // "Jernih"
  final int lastUpdate; // 1762138800
  final String network; // "WiFi"
  final double ph; // 7
  final String statusCooler; // "ON"
  final String statusHeater; // "OFF"
  final double suhu; // 28
  final double tds; // "164"
  final double turbidity; // "-9"

  SensorData({
    required this.kekeruhan,
    required this.lastUpdate,
    required this.network,
    required this.ph,
    required this.statusCooler,
    required this.statusHeater,
    required this.suhu,
    required this.tds,
    required this.turbidity,
  });

  // Helper untuk parsing aman
  static double _parseDouble(dynamic value) {
    if (value is num) {
      return value.toDouble();
    } else if (value is String) {
      return double.tryParse(value) ?? 0.0;
    }
    return 0.0;
  }

  static int _parseInt(dynamic value) {
    if (value is int) {
      return value;
    } else if (value is String) {
      return int.tryParse(value) ?? 0;
    }
    return 0;
  }

  // Factory constructor untuk membuat instance SensorData dari Map (data JSON dari RTDB)
  factory SensorData.fromMap(Map<String, dynamic> map) {
    return SensorData(
      kekeruhan: map['kekeruhan'] ?? 'Unknown',
      lastUpdate: _parseInt(map['last_update']),
      network: map['network'] ?? 'Unknown',
      ph: _parseDouble(map['ph']),
      statusCooler: map['status_cooler'] ?? 'OFF',
      statusHeater: map['status_heater'] ?? 'OFF',
      suhu: _parseDouble(map['suhu']),
      tds: _parseDouble(map['tds']),
      turbidity: _parseDouble(map['turbidity']),
    );
  }

  // Tambahkan ini untuk memudahkan jika Anda mendapat snapshot langsung
  factory SensorData.fromSnapshot(DataSnapshot snapshot) {
    final map = snapshot.value as Map<String, dynamic>;
    return SensorData.fromMap(map);
  }
}