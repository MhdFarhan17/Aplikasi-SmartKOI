import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smartkoi/app/features/dashboard/controllers/dashboard_controller.dart';
import 'package:smartkoi/app/data/models/control_settings_model.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:smartkoi/app/shared/widgets/alert_helper.dart';

class SettingsController extends GetxController {
  final DashboardController _dashboardController = Get.find<DashboardController>();

  // --- TEXT CONTROLLERS ---
  // Digunakan untuk menampung input user di form pengaturan
  late TextEditingController suhuMinC;
  late TextEditingController suhuMaxC;
  late TextEditingController phMinC;
  late TextEditingController phMaxC;
  late TextEditingController tdsMinC;
  late TextEditingController tdsMaxC;
  late TextEditingController turbidityMinC;
  late TextEditingController turbidityMaxC;

  // --- TEXT CONTROLLERS (Wi-Fi) ---
  late TextEditingController ssidC;
  late TextEditingController passwordC;

  // --- REACTIVE VARIABLES (Wi-Fi) ---
  // Untuk menampilkan data realtime di UI tanpa harus reload
  final RxString currentSsid = 'Memuat...'.obs;
  final RxString currentPassword = ''.obs;

  /// Mengambil nilai setting saat ini (Realtime)
  ControlSettingsModel? get controlSettings =>
      _dashboardController.controlSettings.value;

  /// Mengambil status notifikasi (Aktif/Tidak)
  Map<String, bool> get notificationSettings =>
      _dashboardController.notificationSettings.value ?? {};

  /// Cek apakah ada device yang sedang dipilih
  bool get isDeviceActive => _dashboardController.activeDeviceId.isNotEmpty;

  @override
  void onInit() {
    super.onInit();
    // 1. Inisialisasi Text Controllers
    suhuMinC = TextEditingController();
    suhuMaxC = TextEditingController();
    phMinC = TextEditingController();
    phMaxC = TextEditingController();
    tdsMinC = TextEditingController();
    tdsMaxC = TextEditingController();
    turbidityMinC = TextEditingController();
    turbidityMaxC = TextEditingController();
    ssidC = TextEditingController();
    passwordC = TextEditingController();

    // 2. Setup Listener (Reactive)
    ever(_dashboardController.controlSettings, _populateFields);

    // 3. Isi form saat pertama kali dibuka
    _populateFields(_dashboardController.controlSettings.value);

    // 4. Setup Listener Wi-Fi
    _listenToWifiSettings();
  }

  @override
  void onClose() {
    // Bersihkan memori saat halaman ditutup
    suhuMinC.dispose();
    suhuMaxC.dispose();
    phMinC.dispose();
    phMaxC.dispose();
    tdsMinC.dispose();
    tdsMaxC.dispose();
    turbidityMinC.dispose();
    turbidityMaxC.dispose();
    ssidC.dispose();
    passwordC.dispose();
    super.onClose();
  }

  /// Fungsi untuk mengisi Text Field dari data Model
  void _populateFields(ControlSettingsModel? settings) {
    if (settings != null) {
      // Helper kecil untuk menghilangkan ".0" jika angka bulat (25.0 -> 25)
      String format(double val) =>
          val.truncateToDouble() == val ? val.toInt().toString() : val.toString();

      suhuMinC.text = format(settings.suhuMin);
      suhuMaxC.text = format(settings.suhuMax);
      phMinC.text = format(settings.phMin);
      phMaxC.text = format(settings.phMax);
      tdsMinC.text = format(settings.tdsMin);
      tdsMaxC.text = format(settings.tdsMax);
      turbidityMinC.text = format(settings.turbidityMin);
      turbidityMaxC.text = format(settings.turbidityMax);
    }
  }

  /// Fungsi baru: Mendengarkan data Wi-Fi secara Realtime
  void _listenToWifiSettings() {
    if (!isDeviceActive) return;
    final deviceId = _dashboardController.activeDeviceId.value;
    final wifiRef = FirebaseDatabase.instance.ref('Devices/$deviceId/setting_wifi');

    wifiRef.onValue.listen((event) {
      if (event.snapshot.value != null) {
        final data = Map<String, dynamic>.from(event.snapshot.value as Map);
        currentSsid.value = data['ssid']?.toString() ?? 'Tidak ada SSID';
        currentPassword.value = data['password']?.toString() ?? '';

        // Isi text field agar saat dialog dibuka sudah ada teksnya
        ssidC.text = currentSsid.value;
        passwordC.text = currentPassword.value;
      } else {
        currentSsid.value = 'Belum Diatur';
      }
    });
  }

  // Update Wi-Fi Langsung ke Firebase
  Future<void> saveWifiSettings() async {
    if (!isDeviceActive) return;

    if (ssidC.text.trim().isEmpty) {
      CustomAlert.show(AlertType.warning, 'Peringatan', 'SSID tidak boleh kosong!');
      return;
    }

    final deviceId = _dashboardController.activeDeviceId.value;
    try {
      Get.back(); // Tutup dialog
      await FirebaseDatabase.instance.ref('Devices/$deviceId/setting_wifi').set({
        'ssid': ssidC.text.trim(),
        'password': passwordC.text, // Password bisa kosong jika open wifi
      });
      CustomAlert.show(AlertType.success, 'Berhasil', 'Pengaturan Wi-Fi berhasil diperbarui.');
    } catch (e) {
      CustomAlert.show(AlertType.error, 'Gagal', 'Terjadi kesalahan: $e');
    }
  }


  void updateNotificationSetting(String key, bool value) {
    if (!isDeviceActive) return;
    _dashboardController.updateNotificationSetting(key, value);
  }

  void saveTemperatureSettings() {
    if (!isDeviceActive) return;
    _dashboardController.updateTemperatureSettings(
        suhuMinC.text, suhuMaxC.text);
  }

  void savePhSettings() {
    if (!isDeviceActive) return;
    _dashboardController.updatePhSettings(phMinC.text, phMaxC.text);
  }

  void saveTdsSettings() {
    if (!isDeviceActive) return;
    _dashboardController.updateTdsSettings(tdsMinC.text, tdsMaxC.text);
  }

  void saveTurbiditySettings() {
    if (!isDeviceActive) return;
    _dashboardController.updateTurbiditySettings(
        turbidityMinC.text, turbidityMaxC.text);
  }
}