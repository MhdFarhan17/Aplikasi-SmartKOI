import 'package:flutter_test/flutter_test.dart';
// Sesuaikan path import ini
import 'package:smartkoi/app/data/models/battery_data_model.dart';

void main() {
  group('BatteryDataModel Test - Pengujian Fungsionalitas Parsing Data', () {

    // SKENARIO 1: Parsing data JSON yang valid dan lengkap
    test('Skenario 1 (BatteryData): Parsing JSON valid dan lengkap BERHASIL', () {
      // Arrange
      final Map<String, dynamic> jsonValid = {
        'Power': 95,
        'Status': 'Charging',
        'capacity': 25,
        'current': 3,
        'current_in': 4,
        'current_out': 1,
        'discharging_time': '00:00:00',
        'time_until_full': '01:15:00',
      };

      // Act
      final result = BatteryDataModel.fromMap(jsonValid);

      // Assert
      expect(result.power, 95);
      expect(result.status, 'Charging');
      expect(result.capacity, 25);
      expect(result.currentIn, 4);
      expect(result.timeUntilFull, '01:15:00');

      print('✅ Skenario 1 (BatteryData): Parsing JSON valid BERHASIL');
    });

    // SKENARIO 2: Menangani field JSON yang hilang
    test('Skenario 2 (BatteryData): Menangani field hilang BERHASIL', () {
      // Arrange (Data kosong/tidak lengkap)
      final Map<String, dynamic> jsonIncomplete = {
        'Power': 50,
        // Field lain hilang
      };

      // Act
      final result = BatteryDataModel.fromMap(jsonIncomplete);

      // Assert
      // Helper _parseString akan mengembalikan 'N/A' jika null
      expect(result.status, 'N/A');
      expect(result.dischargingTime, 'N/A');
      // Helper _parseInt akan mengembalikan 0 jika null
      expect(result.capacity, 0);
      expect(result.current, 0);

      print('✅ Skenario 2 (BatteryData): Menangani field hilang BERHASIL');
    });

    // SKENARIO 3: Pengujian Safe Parsing (String ke Integer)
    test('Skenario 3 (BatteryData): Menangani ketidaksesuaian tipe data BERHASIL', () {
      // Arrange (Firebase mengirim angka sebagai String)
      final Map<String, dynamic> jsonTypeMismatch = {
        'Power': '80',         // String
        'Status': 'Discharging',
        'capacity': '20',      // String
        'current': 3.5,        // Double (harusnya Int)
        'current_in': '0',
        'current_out': 2,
        'discharging_time': '02:30:00',
        'time_until_full': null
      };

      // Act
      final result = BatteryDataModel.fromMap(jsonTypeMismatch);

      // Assert
      expect(result.power, 80);    // '80' -> 80
      expect(result.capacity, 20); // '20' -> 20
      expect(result.current, 3);   // 3.5 -> 3 (pembulatan ke bawah via .toInt())

      print('✅ Skenario 3 (BatteryData): Menangani konversi tipe data BERHASIL');
    });

    // SKENARIO 4: Menangani nilai null eksplisit
    test('Skenario 4 (BatteryData): Menangani nilai null pada field JSON BERHASIL', () {
      // Arrange
      final Map<String, dynamic> jsonNulls = {
        'Power': null,
        'Status': null,
        'capacity': null,
      };

      // Act
      final result = BatteryDataModel.fromMap(jsonNulls);

      // Assert
      expect(result.power, 0);      // _parseInt mengembalikan 0
      expect(result.status, 'N/A'); // _parseString mengembalikan 'N/A'

      print('✅ Skenario 4 (BatteryData): Menangani nilai null BERHASIL');
    });
  });
}