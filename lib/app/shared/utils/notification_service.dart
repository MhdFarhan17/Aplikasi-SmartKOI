// lib/app/utils/notification_service.dart

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_database/firebase_database.dart';

class NotificationService {
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref();

  /// Fungsi ini dipanggil saat user memilih device (Login ke alat)
  Future<void> syncFcmToken(String deviceId) async {
    try {
      // 1. Minta Izin Notifikasi (Wajib untuk Android 13+)
      NotificationSettings settings = await _fcm.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        print('✅ Izin notifikasi diberikan.');

        // 2. Ambil Token HP ini
        String? token = await _fcm.getToken();

        if (token != null) {
          print('✅ FCM Token didapat: $token');
          // 3. Simpan ke Database
          await _saveTokenToDatabase(token, deviceId);
        }

        // 4. Jaga-jaga kalau token berubah (Refresh)
        _fcm.onTokenRefresh.listen((newToken) {
          _saveTokenToDatabase(newToken, deviceId);
        });

      } else {
        print('❌ Izin notifikasi ditolak user.');
      }
    } catch (e) {
      print("❌ Error FCM: $e");
    }
  }

  /// Logika menyimpan ke Devices/ID/fcm_tokens/TOKEN_PANJANG
  Future<void> _saveTokenToDatabase(String token, String deviceId) async {
    try {
      // Path ini memungkinkan BANYAK HP menyimpan token di SATU Device ID
      // Kita pakai token sebagai 'Key' agar tidak saling menimpa
      final tokenRef = _dbRef.child('Devices/$deviceId/fcm_tokens/$token');

      // Isi datanya simpel saja, misalnya 'true' atau info device
      await tokenRef.set({
        'active': true,
        'platform': 'android', // opsional
        'timestamp': ServerValue.timestamp, // opsional, buat tau kapan login
      });

      print("✅ Token berhasil disimpan di: Devices/$deviceId/fcm_tokens/...");
    } catch (e) {
      print("❌ Gagal simpan token ke DB: $e");
    }
  }
}