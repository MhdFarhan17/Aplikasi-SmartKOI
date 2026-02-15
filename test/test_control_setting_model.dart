import 'package:flutter_test/flutter_test.dart';
// Sesuaikan path import ini
import 'package:smartkoi/app/data/models/control_settings_model.dart';

void main() {
  group('ControlSettingsModel Test - Pengujian Fungsionalitas Parsing Data', () {

    // SKENARIO 1: Parsing data JSON yang valid dengan nilai kustom
    test('Skenario 1 (ControlSettings): Parsing JSON valid dengan nilai kustom BERHASIL', () {
      // Arrange (Data settingan user yang custom)
      final Map<String, dynamic> jsonCustom = {
        'ph_max': 9.0,
        'ph_min': 6.0,
        'suhu_max': 30.0,
        'suhu_min': 20.0,
        'tds_max': 600.0,
        'tds_min': 5.0,
        'turbidity_max': 100.0,
        'turbidity_min': 5.0,
      };

      // Act
      final result = ControlSettingsModel.fromMap(jsonCustom);

      // Assert
      expect(result.phMax, 9.0);
      expect(result.suhuMin, 20.0);
      expect(result.tdsMax, 600.0);
      expect(result.turbidityMin, 5.0);

      print('✅ Skenario 1 (ControlSettings): Parsing nilai kustom BERHASIL');
    });

    // SKENARIO 2: Menangani field JSON yang hilang (Menggunakan Default Value)
    test('Skenario 2 (ControlSettings): Menangani field hilang BERHASIL', () {
      // Arrange (Data kosong sama sekali)
      final Map<String, dynamic> jsonEmpty = {};

      // Act
      final result = ControlSettingsModel.fromMap(jsonEmpty);

      // Assert
      // Harus kembali ke nilai default yang kamu set di Class Model
      expect(result.phMax, 8.5);    // Default
      expect(result.phMin, 6.5);    // Default
      expect(result.suhuMax, 29.0); // Default
      expect(result.tdsMax, 300.0); // Default

      print('✅ Skenario 2 (ControlSettings): Fallback ke Default BERHASIL');
    });

    // SKENARIO 3: Pengujian Safe Parsing (String/Int ke Double)
    test('Skenario 3 (ControlSettings): Menangani ketidaksesuaian tipe data BERHASIL', () {
      // Arrange (Firebase kadang kirim angka desimal sebagai String)
      final Map<String, dynamic> jsonTypeMismatch = {
        'ph_max': '8.8',      // String
        'suhu_max': 29,       // Int (bukan Double)
        'tds_max': '450.5',   // String
        'turbidity_max': 50   // Int
      };

      // Act
      final result = ControlSettingsModel.fromMap(jsonTypeMismatch);

      // Assert
      expect(result.phMax, 8.8);      // '8.8' -> 8.8
      expect(result.suhuMax, 29.0);   // 29 -> 29.0
      expect(result.tdsMax, 450.5);   // '450.5' -> 450.5

      print('✅ Skenario 3 (ControlSettings): Menangani konversi tipe data BERHASIL');
    });

    // SKENARIO 4: Menangani nilai null eksplisit
    test('Skenario 4 (ControlSettings): Menangani nilai null pada field JSON BERHASIL', () {
      // Arrange
      final Map<String, dynamic> jsonNulls = {
        'ph_max': null,
        'suhu_min': null,
      };

      // Act
      final result = ControlSettingsModel.fromMap(jsonNulls);

      // Assert
      // Helper _parseDouble harus mengembalikan defaultValue jika null
      expect(result.phMax, 8.5);    // Default
      expect(result.suhuMin, 23.0); // Default

      print('✅ Skenario 4 (ControlSettings): Menangani nilai null BERHASIL');
    });
  });
}