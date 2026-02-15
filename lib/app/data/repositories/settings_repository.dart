// lib/app/data/repositories/settings_repository.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class SettingsRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Fungsi untuk mendapatkan stream data pengaturan notifikasi
  Stream<Map<String, bool>> getNotificationSettingsStream(String deviceId) {
    return _firestore.collection('devices').doc(deviceId).snapshots().map((snapshot) {
      if (snapshot.exists && snapshot.data()!.containsKey('notification_settings')) {
        // Jika field ada, konversi ke Map<String, bool>
        return Map<String, bool>.from(snapshot.data()!['notification_settings']);
      } else {
        // Jika tidak ada, kembalikan nilai default
        return {
          'critical_alerts_enabled': false,
          'offline_alerts_enabled': false,
        };
      }
    });
  }

  // Fungsi untuk memperbarui satu pengaturan spesifik
  Future<void> updateNotificationSetting({
    required String deviceId,
    required String settingKey,
    required bool newValue,
  }) {
    return _firestore.collection('devices').doc(deviceId).set({
      'notification_settings': {
        settingKey: newValue,
      }
    }, SetOptions(merge: true)); // SetOptions(merge: true) PENTING!
  }
}