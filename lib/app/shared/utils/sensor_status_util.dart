import 'package:flutter/material.dart';
// Pastikan path import ini sesuai dengan struktur folder kamu
import 'package:smartkoi/app/data/models/control_settings_model.dart';

// Class sederhana untuk menampung Teks Status dan Warnanya
class SensorStatus {
  final String text;
  final Color color;

  SensorStatus({required this.text, required this.color});
}

class SensorStatusUtil {
  /// Mendapatkan status SUHU (Dingin, Ideal, Panas)
  static SensorStatus getStatusForSuhu(
      double suhu, ControlSettingsModel settings) {
    // Jika di bawah batas minimum -> Dingin (Biru)
    if (suhu < settings.suhuMin) {
      return SensorStatus(text: 'Dingin', color: Colors.lightBlue.shade600);
    }
    if (suhu < 14 ) {
      return SensorStatus(text: 'Terlalu Dingin', color: Colors.lightBlue.shade600);
    }
    // Jika di atas batas maksimum -> Panas (Merah)
    if (suhu > settings.suhuMax) {
      return SensorStatus(text: 'Panas', color: Colors.red.shade600);
    }
    if (suhu > 34 ) {
      return SensorStatus(text: 'Terlalu Panas', color: Colors.red.shade600);
    }
    // Di tengah-tengah -> Ideal (Hijau)
    return SensorStatus(text: 'Ideal', color: Colors.green.shade600);
  }

  /// Mendapatkan status pH (Asam, Netral, Basa)
  static SensorStatus getStatusForPh(double ph, ControlSettingsModel settings) {
    // Di bawah min -> Asam (Oranye/Kuning Gelap)
    if (ph < settings.phMin) {
      return SensorStatus(text: 'Asam', color: Colors.orange.shade700);
    }
    // Di atas max -> Basa (Ungu)
    if (ph > settings.phMax) {
      return SensorStatus(text: 'Basa', color: Colors.purple.shade400);
    }
    // Ideal -> Netral (Hijau)
    return SensorStatus(text: 'Netral', color: Colors.green.shade600);
  }

  /// Mendapatkan status TDS (Rendah, Ideal, Tinggi/Kotor)
  static SensorStatus getStatusForTds(double tds, ControlSettingsModel settings) {
    if (tds < settings.tdsMin) {
      return SensorStatus(text: 'Rendah', color: Colors.blue.shade400);
    }
    if (tds > settings.tdsMax) {
      return SensorStatus(text: 'Tinggi', color: Colors.red.shade600);
    }
    return SensorStatus(text: 'Ideal', color: Colors.green.shade600);
  }

  /// Mendapatkan status Turbidity/Kekeruhan Sensor (NTU)
  static SensorStatus getStatusForTurbidity(
      double turbidity, ControlSettingsModel settings) {
    if (turbidity < 1) {
      return SensorStatus(text: 'Error', color: Colors.grey.shade400);
    }
    // Semakin rendah NTU, semakin jernih.
    // Jika < min (misal min diset 5, dan nilai 2), itu sangat bagus.
    if (turbidity < settings.turbidityMin) {
      return SensorStatus(text: 'Sangat Jernih', color: Colors.blue.shade400);
    }
    // Jika > max, berarti keruh
    if (turbidity > settings.turbidityMax) {
      return SensorStatus(text: 'Keruh', color: Colors.brown.shade400);
    }
    if (turbidity > 500 ) {
      return SensorStatus(text: 'Kotor', color: Colors.brown.shade400);
    }
    // Di antara range
    return SensorStatus(text: 'Jernih', color: Colors.green.shade600);
  }

  /// Mendapatkan status Visual Kekeruhan (String dari alat)
  /// Biasanya alat mengirim: "Jernih", "Keruh", atau "Sangat Keruh"
  static SensorStatus getStatusForKekeruhan(String kekeruhan) {
    final status = kekeruhan.toLowerCase().trim();

    if (status.contains('keruh') || status.contains('kotor')) {
      return SensorStatus(text: 'Kotor', color: Colors.red.shade600);
    } else if (status.contains('cukup') || status.contains('sedang')) {
      return SensorStatus(text: 'Cukup', color: Colors.orange.shade600);
    } else {
      // Default (Jernih/Bagus)
      return SensorStatus(text: 'Jernih', color: Colors.green.shade600);
    }
  }
}