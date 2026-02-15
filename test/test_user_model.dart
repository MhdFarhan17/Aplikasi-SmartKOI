import 'package:flutter_test/flutter_test.dart';
// Sesuaikan path import ini
import 'package:smartkoi/app/data/models/user_model.dart';

void main() {
  group('UserModel Test - Pengujian Fungsionalitas Parsing Data', () {

    // SKENARIO 1: Parsing data JSON yang valid dan lengkap
    test('Skenario 1 (UserModel): Parsing JSON valid dan lengkap BERHASIL', () {
      // Arrange
      final String uid = 'user_12345';
      final Map<String, dynamic> jsonValid = {
        'firstName': 'Budi',
        'lastName': 'Santoso',
        'email': 'budi@example.com',
      };

      // Act
      final result = UserModel.fromMap(uid, jsonValid);

      // Assert
      expect(result.uid, 'user_12345');
      expect(result.firstName, 'Budi');
      expect(result.lastName, 'Santoso');
      expect(result.email, 'budi@example.com');

      print('✅ Skenario 1 (UserModel): Parsing JSON valid BERHASIL');
    });

    // SKENARIO 2: Menangani field JSON yang hilang (Empty Map)
    test('Skenario 2 (UserModel): Menangani field hilang BERHASIL', () {
      // Arrange (Data kosong)
      final String uid = 'user_999';
      final Map<String, dynamic> jsonEmpty = {};

      // Act
      final result = UserModel.fromMap(uid, jsonEmpty);

      // Assert
      // Harus default ke string kosong '' sesuai logika ?? ''
      expect(result.firstName, '');
      expect(result.lastName, '');
      expect(result.email, '');
      expect(result.uid, 'user_999'); // UID tetap harus ada

      print('✅ Skenario 2 (UserModel): Menangani field hilang BERHASIL');
    });

    // SKENARIO 3: Menangani nilai null eksplisit
    test('Skenario 3 (UserModel): Menangani nilai null pada field JSON BERHASIL', () {
      // Arrange
      final String uid = 'user_null';
      final Map<String, dynamic> jsonNulls = {
        'firstName': null,
        'lastName': null,
        'email': null,
      };

      // Act
      final result = UserModel.fromMap(uid, jsonNulls);

      // Assert
      expect(result.firstName, '');
      expect(result.lastName, '');
      expect(result.email, '');

      print('✅ Skenario 3 (UserModel): Menangani nilai null BERHASIL');
    });

    // SKENARIO 4: Integrasi UID eksternal
    // Karena UID tidak diambil dari dalam JSON, tapi di-pass sebagai argumen
    test('Skenario 4 (UserModel): Integrasi UID dari parameter eksternal BERHASIL', () {
      // Arrange
      final String uidExternal = 'firebase_uid_abc';
      final Map<String, dynamic> jsonUserData = {
        'firstName': 'Siti',
      };

      // Act
      final result = UserModel.fromMap(uidExternal, jsonUserData);

      // Assert
      expect(result.uid, 'firebase_uid_abc');
      expect(result.firstName, 'Siti');

      print('✅ Skenario 4 (UserModel): Integrasi UID BERHASIL');
    });
  });
}