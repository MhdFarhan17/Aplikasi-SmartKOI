// lib/app/data/models/battery_data_model.dart

// Helper untuk parsing aman
int _parseInt(dynamic value) {
  if (value is int) return value;
  if (value is double) return value.toInt();
  if (value is String) return int.tryParse(value) ?? 0;
  return 0;
}

String _parseString(dynamic value) {
  return value?.toString() ?? 'N/A';
}

class BatteryDataModel {
  // Field baru sesuai screenshot image_27591d.png
  final int power; // Power: 70
  final String status; // Status: "Idle"
  final int capacity; // capacity: 20
  final int current; // current: 3
  final int currentIn; // current_in: 3
  final int currentOut; // current_out: 2
  final String dischargingTime; // discharging_time: "00:30:15"
  final String timeUntilFull; // time_until_full: "01:22:00"

  BatteryDataModel({
    required this.power,
    required this.status,
    required this.capacity,
    required this.current,
    required this.currentIn,
    required this.currentOut,
    required this.dischargingTime,
    required this.timeUntilFull,
  });

  /// Factory constructor untuk membuat data dari Map (JSON dari RTDB)
  factory BatteryDataModel.fromMap(Map<String, dynamic> map) {
    return BatteryDataModel(
      // Gunakan helper untuk parsing yang aman
      power: _parseInt(map['Power']),
      status: _parseString(map['Status']),
      capacity: _parseInt(map['capacity']),
      current: _parseInt(map['current']),
      currentIn: _parseInt(map['current_in']),
      currentOut: _parseInt(map['current_out']),
      dischargingTime: _parseString(map['discharging_time']),
      timeUntilFull: _parseString(map['time_until_full']),
    );
  }
}