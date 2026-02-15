import 'package:flutter_test/flutter_test.dart';
// Pastikan path import ini sesuai dengan nama project kamu
import 'package:smartkoi/app/data/models/sensor_data_model.dart';

void main() {
  group('SensorData Model Test - Pengujian Fungsionalitas Parsing Data', () {

    // SKENARIO 1: Memastikan data JSON yang valid dan lengkap berhasil diparsing
    test('Skenario 1 (SensorData): Parsing JSON valid dan lengkap BERHASIL', () {
      // Arrange (Siapkan Data Dummy yang Sempurna)
      final Map<String, dynamic> jsonValid = {
        'kekeruhan': 'Jernih',
        'last_update': 1762138800,
        'network': 'WiFi',
        'ph': 7.5,
        'status_cooler': 'ON',
        'status_heater': 'OFF',
        'suhu': 28.5,
        'tds': 150.0,
        'turbidity': 5.2,
      };

      // Act (Lakukan Parsing)
      final result = SensorData.fromMap(jsonValid);

      // Assert (Verifikasi Hasil)
      expect(result.kekeruhan, 'Jernih');
      expect(result.suhu, 28.5);
      expect(result.lastUpdate, 1762138800);
      expect(result.statusCooler, 'ON');

      // Print untuk log di console agar mirip referensi laporan
      print('✅ Skenario 1 (SensorData): Parsing JSON valid BERHASIL');
    });

    // SKENARIO 2: Memastikan field yang hilang diganti dengan nilai default
    test('Skenario 2 (SensorData): Menangani field hilang BERHASIL', () {
      // Arrange (Data tidak lengkap, misal network dan status hilang)
      final Map<String, dynamic> jsonIncomplete = {
        'kekeruhan': 'Keruh',
        'ph': 6.0,
        // 'network' hilang
        // 'status_cooler' hilang
      };

      // Act
      final result = SensorData.fromMap(jsonIncomplete);

      // Assert
      // Harus kembali ke default value sesuai kode model kamu (?? 'Unknown' / ?? 'OFF')
      expect(result.network, 'Unknown');
      expect(result.statusCooler, 'OFF');
      expect(result.suhu, 0.0); // Default dari helper _parseDouble

      print('✅ Skenario 2 (SensorData): Menangani field hilang BERHASIL');
    });

    // SKENARIO 3: Menguji "Safe Parsing" (Pengganti Nested Object pada kasus ini)
    // Ini menguji logika _parseInt dan _parseDouble yang kamu buat
    test('Skenario 3 (SensorData): Menangani ketidaksesuaian tipe data BERHASIL', () {
      // Arrange (Firebase sering mengirim angka sebagai String "28.5" alih-alih 28.5)
      final Map<String, dynamic> jsonTypeMismatch = {
        'suhu': '28.5',        // String, harusnya Double
        'last_update': '12345',// String, harusnya Int
        'tds': 150,            // Int, harusnya Double
        'kekeruhan': 'Jernih'
      };

      // Act
      final result = SensorData.fromMap(jsonTypeMismatch);

      // Assert
      // Memastikan helper _parseDouble dan _parseInt bekerja
      expect(result.suhu, 28.5);
      expect(result.lastUpdate, 12345);
      expect(result.tds, 150.0);

      print('✅ Skenario 3 (SensorData): Menangani konversi tipe data BERHASIL');
    });

    // SKENARIO 4: Memastikan nilai null ditangani dengan aman
    test('Skenario 4 (SensorData): Menangani nilai null pada field JSON BERHASIL', () {
      // Arrange (Semua value null)
      final Map<String, dynamic> jsonNulls = {
        'kekeruhan': null,
        'last_update': null,
        'network': null,
        'ph': null,
        'suhu': null,
      };

      // Act
      final result = SensorData.fromMap(jsonNulls);

      // Assert
      expect(result.kekeruhan, 'Unknown'); // Default value
      expect(result.suhu, 0.0);            // Default value
      expect(result.lastUpdate, 0);        // Default value

      print('✅ Skenario 4 (SensorData): Menangani nilai null BERHASIL');
    });
  });
}