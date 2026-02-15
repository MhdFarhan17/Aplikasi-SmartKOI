import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smartkoi/app/features/dashboard/controllers/dashboard_controller.dart';
import 'package:smartkoi/app/data/models/control_settings_model.dart';
// Note: Kita tidak butuh AlertHelper di sini karena DashboardController yang akan memunculkan alertnya.

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

  // --- GETTERS ---
  // Menghubungkan data dari DashboardController ke UI Settings

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

    // 2. Setup Listener (Reactive)
    // "ever" akan memantau perubahan data di DashboardController.
    // Jika data dari server berubah (misal device lain mengupdate setting),
    // form di halaman ini akan otomatis terisi nilai baru.
    ever(_dashboardController.controlSettings, _populateFields);

    // 3. Isi form saat pertama kali dibuka
    _populateFields(_dashboardController.controlSettings.value);
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

  // --- FUNGSI UPDATE (DELEGASI) ---
  // Controller ini hanya perantara, logika simpan ada di DashboardController
  // DashboardController juga yang akan menampilkan CustomAlert Sukses/Gagal.

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