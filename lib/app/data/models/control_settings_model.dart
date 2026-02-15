// lib/app/data/models/control_settings_model.dart

class ControlSettingsModel {
  final double phMax;
  final double phMin;
  final double suhuMax;
  final double suhuMin;
  final double tdsMax;
  final double tdsMin;
  final double turbidityMax;
  final double turbidityMin;

  ControlSettingsModel({
    this.phMax = 8.5, // Nilai default jika data tidak ada
    this.phMin = 6.5,
    this.suhuMax = 29.0,
    this.suhuMin = 23.0,
    this.tdsMax = 300.0,
    this.tdsMin = 1.0,
    this.turbidityMax = 400.0,
    this.turbidityMin = 1.0,
  });

  // Helper untuk parsing aman
  static double _parseDouble(dynamic value, double defaultValue) {
    if (value is num) {
      return value.toDouble();
    } else if (value is String) {
      return double.tryParse(value) ?? defaultValue;
    }
    return defaultValue;
  }

  // Factory constructor untuk membuat instance dari Map (data JSON dari RTDB)
  factory ControlSettingsModel.fromMap(Map<String, dynamic> map) {
    return ControlSettingsModel(
      phMax: _parseDouble(map['ph_max'], 8.5),
      phMin: _parseDouble(map['ph_min'], 6.5),
      suhuMax: _parseDouble(map['suhu_max'], 29.0),
      suhuMin: _parseDouble(map['suhu_min'], 23.0),
      tdsMax: _parseDouble(map['tds_max'], 300.0),
      tdsMin: _parseDouble(map['tds_min'], 1.0),
      turbidityMax: _parseDouble(map['turbidity_max'], 400.0),
      turbidityMin: _parseDouble(map['turbidity_min'], 1.0),
    );
  }
}
