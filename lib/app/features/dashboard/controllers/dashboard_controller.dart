import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:smartkoi/app/shared/widgets/alert_helper.dart';
import 'package:smartkoi/app/data/models/battery_data_model.dart';
import 'package:smartkoi/app/data/models/control_settings_model.dart';
import 'package:smartkoi/app/data/models/sensor_data_model.dart';
import 'package:smartkoi/app/shared/utils/notification_service.dart';
import 'package:smartkoi/app/shared/utils/latency_monitor.dart';
import 'package:smartkoi/app/data/repositories/dashboard_repository.dart';

class DashboardController extends GetxController {
  final DashboardRepository _repository = DashboardRepository();
  final _storage = GetStorage();
  final LatencyMonitor _latencyMonitor = LatencyMonitor();

  final RxString activeDeviceId = ''.obs;
  final RxBool isLoading = false.obs;

  // Reactive Variables (Bisa null di awal)
  final Rxn<SensorData> sensorData = Rxn<SensorData>();
  final Rxn<BatteryDataModel> batteryData = Rxn<BatteryDataModel>();
  final Rxn<ControlSettingsModel> controlSettings = Rxn<ControlSettingsModel>();
  final Rxn<Map<String, bool>> notificationSettings = Rxn<Map<String, bool>>();

  @override
  void onInit() {
    super.onInit();
    // Coba load deviceId terakhir yang disimpan di memori HP
    String? lastDeviceId = _storage.read('last_device_id');
    if (lastDeviceId != null && lastDeviceId.isNotEmpty) {
      setActiveDevice(lastDeviceId, isAutoLoad: true);
    }
  }

  void onClose() {
    // 2. Matikan monitor saat controller hancur (opsional, tapi bagus)
    _latencyMonitor.stopMonitoring();
    super.onClose();
  }

  /// Membersihkan data saat Log Out atau ganti device
  void clearActiveDevice() {
    activeDeviceId.value = '';
    sensorData.value = null;
    batteryData.value = null;
    controlSettings.value = null;
    notificationSettings.value = null;
    _storage.remove('last_device_id');
    _latencyMonitor.stopMonitoring();
  }

  /// Fungsi utama untuk menghubungkan aplikasi ke alat (IoT)
  Future<void> setActiveDevice(String deviceId, {bool isAutoLoad = false}) async {
    if (deviceId.trim().isEmpty) {
      CustomAlert.show(AlertType.warning, 'Input Kosong', 'Device ID tidak boleh kosong.');
      return;
    }

    isLoading.value = true;

    try {
      final bool isValid = await _repository.validateDeviceId(deviceId);

      if (!isValid) {
        isLoading.value = false;
        CustomAlert.show(AlertType.error, 'Device Tidak Ditemukan', 'ID "$deviceId" tidak terdaftar atau salah.');
        return;
      }

      // Jika valid, simpan dan bind data
      activeDeviceId.value = deviceId;
      _storage.write('last_device_id', deviceId);

      print("🔄 Mencoba menyimpan token untuk device: $deviceId");
      await NotificationService().syncFcmToken(deviceId);

      // BIND STREAM:
      // GetX .bindStream otomatis mengelola subscription (buka/tutup stream)
      sensorData.bindStream(_repository.getSensorDataStream(deviceId));
      batteryData.bindStream(_repository.getBatteryDataStream(deviceId));
      controlSettings.bindStream(_repository.getControlSettingsStream(deviceId));
      notificationSettings.bindStream(_repository.getNotificationSettingsStream(deviceId));

      _latencyMonitor.startMonitoring(deviceId);

      // Tampilkan notifikasi hanya jika bukan auto-load (saat user input manual)
      if (!isAutoLoad) {
        CustomAlert.show(AlertType.success, 'Terhubung', 'Berhasil terhubung ke perangkat "$deviceId"');
      }

    } catch (e) {
      CustomAlert.show(AlertType.error, 'Koneksi Gagal', 'Gagal memvalidasi perangkat: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Helper internal untuk update setting ke server
  Future<void> _updateSettings(Map<String, dynamic> settings) async {
    if (activeDeviceId.isEmpty) {
      CustomAlert.show(AlertType.warning, 'Error', 'Tidak ada perangkat yang aktif.');
      return;
    }

    try {
      // Menutup dialog input sebelum proses (agar UX lebih smooth)
      Get.back();

      await _repository.updateControlSettings(activeDeviceId.value, settings);

      CustomAlert.show(AlertType.success, 'Berhasil', 'Pengaturan berhasil diperbarui.');
    } catch (e) {
      CustomAlert.show(AlertType.error, 'Gagal Update', 'Terjadi kesalahan: $e');
    }
  }

  // --- FUNGSI UPDATE PARAMETER KHUSUS ---

  Future<void> updateTemperatureSettings(String min, String maks) async {
    final minVal = double.tryParse(min);
    final maxVal = double.tryParse(maks);

    if (minVal == null || maxVal == null) {
      CustomAlert.show(AlertType.warning, 'Input Salah', 'Masukkan angka yang valid.');
      return;
    }

    if (minVal >= maxVal) {
      CustomAlert.show(AlertType.warning, 'Logika Salah', 'Nilai Minimum harus lebih kecil dari Maksimum.');
      return;
    }

    await _updateSettings({'suhu_min': minVal, 'suhu_max': maxVal});
  }

  Future<void> updatePhSettings(String min, String maks) async {
    final minVal = double.tryParse(min);
    final maxVal = double.tryParse(maks);

    if (minVal == null || maxVal == null || minVal >= maxVal) {
      CustomAlert.show(AlertType.warning, 'Input Tidak Valid', 'Pastikan angka benar dan Min < Max.');
      return;
    }
    await _updateSettings({'ph_min': minVal, 'ph_max': maxVal});
  }

  Future<void> updateTdsSettings(String min, String maks) async {
    final minVal = double.tryParse(min);
    final maxVal = double.tryParse(maks);

    if (minVal == null || maxVal == null || minVal >= maxVal) {
      CustomAlert.show(AlertType.warning, 'Input Tidak Valid', 'Pastikan angka benar dan Min < Max.');
      return;
    }
    await _updateSettings({'tds_min': minVal, 'tds_max': maxVal});
  }

  Future<void> updateTurbiditySettings(String min, String maks) async {
    final minVal = double.tryParse(min);
    final maxVal = double.tryParse(maks);

    if (minVal == null || maxVal == null || minVal >= maxVal) {
      CustomAlert.show(AlertType.warning, 'Input Tidak Valid', 'Pastikan angka benar dan Min < Max.');
      return;
    }
    await _updateSettings({'turbidity_min': minVal, 'turbidity_max': maxVal});
  }

  Future<void> updateNotificationSetting(String key, bool value) async {
    if (activeDeviceId.isEmpty) return;

    try {
      await _repository.updateNotificationSetting(
          deviceId: activeDeviceId.value, settingKey: key, newValue: value);
      // Tidak perlu alert sukses di sini karena biasanya pakai Switch UI yang cepat
    } catch (e) {
      // Kembalikan nilai switch di UI jika gagal (opsional, tapi alert cukup)
      CustomAlert.show(AlertType.error, 'Gagal', 'Tidak dapat mengubah pengaturan notifikasi.');
    }
  }


}