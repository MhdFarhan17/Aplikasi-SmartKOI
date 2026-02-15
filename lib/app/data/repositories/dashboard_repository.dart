import 'package:firebase_database/firebase_database.dart';
import 'package:smartkoi/app/data/models/control_settings_model.dart';
import 'package:smartkoi/app/data/models/sensor_data_model.dart';
import 'package:smartkoi/app/data/models/battery_data_model.dart';
import 'dart:async';

class DashboardRepository {
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref();

  /// Validasi apakah Device ID ada di database
  Future<bool> validateDeviceId(String deviceId) async {
    final snapshot = await _dbRef.child('Devices/$deviceId').once();
    return snapshot.snapshot.exists;
  }

  /// Menyimpan nama kustom/panggilan untuk sebuah device.
  Future<void> saveDeviceName(String deviceId, String name) {
    final nameRef = _dbRef.child('Devices/$deviceId/deviceName');
    return nameRef.set(name);
  }

  /// Mengembalikan stream data sensor terbaru (`realtime`).
  Stream<SensorData> getSensorDataStream(String deviceId) {
    final realtimeRef = _dbRef.child('Devices/$deviceId/realtime');

    return realtimeRef.onValue.map((event) {
      if (event.snapshot.exists && event.snapshot.value != null) {
        final dataMap =
        Map<String, dynamic>.from(event.snapshot.value as Map);
        return SensorData.fromMap(dataMap);
      } else {
        throw Exception('Data sensor tidak ditemukan untuk device $deviceId!');
      }
    });
  }

  /// Mengembalikan stream data Baterai lengkap.
  Stream<BatteryDataModel> getBatteryDataStream(String deviceId) {
    final batteryRef = _dbRef.child('Devices/$deviceId/Battery');
    return batteryRef.onValue.map((event) {
      if (event.snapshot.exists && event.snapshot.value != null) {
        final dataMap =
        Map<String, dynamic>.from(event.snapshot.value as Map);
        return BatteryDataModel.fromMap(dataMap);
      } else {
        // Kembalikan default model jika data tidak ada
        return BatteryDataModel.fromMap({});
      }
    });
  }

  /// Mengembalikan stream pengaturan batas sensor (`parameters`).
  Stream<ControlSettingsModel> getControlSettingsStream(String deviceId) {
    // Path sudah benar menunjuk ke 'parameters'
    final settingsRef = _dbRef.child('Devices/$deviceId/parameters');
    return settingsRef.onValue.map((event) {
      if (event.snapshot.exists && event.snapshot.value != null) {
        final settingsMap =
        Map<String, dynamic>.from(event.snapshot.value as Map);
        return ControlSettingsModel.fromMap(settingsMap);
      } else {
        // Kembalikan nilai default jika map tidak ditemukan
        return ControlSettingsModel.fromMap({});
      }
    });
  }

  /// Memperbarui field di dalam map `parameters`.
  Future<void> updateControlSettings(
      String deviceId, Map<String, dynamic> newSettings) {
    final settingsRef = _dbRef.child('Devices/$deviceId/parameters');
    return settingsRef.update(newSettings);
  }

  /// Mengembalikan stream pengaturan notifikasi (`notification_settings`).
  Stream<Map<String, bool>> getNotificationSettingsStream(String deviceId) {
    final notifRef = _dbRef.child('Devices/$deviceId/notification_settings');
    return notifRef.onValue.map((event) {
      if (event.snapshot.exists && event.snapshot.value != null) {
        // Pastikan data yang datang adalah Map<String, dynamic>
        final data = event.snapshot.value;
        if (data is Map) {
          return Map<String, bool>.from(data.cast<String, bool>());
        }
      }
      // Kembalikan nilai default
      return {
        'critical_alerts_enabled': false,
        'offline_alerts_enabled': false,
      };
    });
  }

  Future<void> updateNotificationSetting({
    required String deviceId,
    required String settingKey,
    required bool newValue,
  }) {
    final settingKeyRef =
    _dbRef.child('Devices/$deviceId/notification_settings/$settingKey');
    return settingKeyRef.set(newValue);
  }
}

