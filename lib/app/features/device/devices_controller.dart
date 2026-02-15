import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:smartkoi/app/shared/widgets/alert_helper.dart';
import 'package:smartkoi/app/data/repositories/dashboard_repository.dart';
import 'package:smartkoi/app/features/dashboard/controllers/dashboard_controller.dart';

class DevicesController extends GetxController {
  final _storage = GetStorage();
  final _repository = DashboardRepository();

  // Mengambil DashboardController agar bisa mengubah device aktif
  final DashboardController _dashboardController = Get.find<DashboardController>();

  final isLoading = false.obs;

  // List device disimpan dalam format Map: {'id': '...', 'nama': '...'}
  var savedDevices = <Map<String, String>>[].obs;

  @override
  void onInit() {
    super.onInit();
    _loadDevices();
  }

  /// Memuat daftar device dari penyimpanan lokal (GetStorage)
  void _loadDevices() {
    final dynamic data = _storage.read('savedDevices');

    if (data is List) {
      // LOGIKA MIGRASI: Jika data lama tersimpan hanya sebagai String (ID saja)
      if (data.isNotEmpty && data.first is String) {
        final List<Map<String, String>> migratedList = data
            .map((dynamic deviceId) =>
        {'id': deviceId.toString(), 'nama': deviceId.toString()})
            .toList();
        savedDevices.assignAll(migratedList);
        _saveDevices(); // Simpan ulang dengan format baru
      }
      // Jika data sudah format baru (Map)
      else if (data.isNotEmpty && data.first is Map) {
        final List<Map<String, String>> loadedList = data
            .map((dynamic item) => Map<String, String>.from(item as Map))
            .toList();
        savedDevices.assignAll(loadedList);
      }
    }
  }

  /// Menyimpan list device ke penyimpanan lokal
  Future<void> _saveDevices() async {
    await _storage.write('savedDevices', savedDevices.toList());
  }

  // --- FUNGSI TAMBAH DEVICE ---
  Future<void> addDevice(String deviceId, String deviceName) async {
    if (isLoading.value) return;

    // Bersihkan spasi berlebih
    final cleanId = deviceId.trim();
    final cleanName = deviceName.trim();

    if (cleanId.isEmpty || cleanName.isEmpty) {
      CustomAlert.show(
          AlertType.warning,
          'Input Kosong',
          'Nama Perangkat dan Device ID harus diisi.'
      );
      return;
    }

    // Cek apakah ID sudah ada di list lokal
    if (savedDevices.any((device) => device['id'] == cleanId)) {
      CustomAlert.show(
          AlertType.warning,
          'Duplikat',
          'Device ID "$cleanId" sudah ada di daftar Anda.'
      );
      return;
    }

    isLoading.value = true;
    try {
      // Validasi ke Server/Firebase apakah ID benar-benar ada
      final bool isValid = await _repository.validateDeviceId(cleanId);

      if (isValid) {
        // Simpan nama alias ke database (opsional, tergantung struktur DB kamu)
        await _repository.saveDeviceName(cleanId, cleanName);

        final newDevice = {'id': cleanId, 'nama': cleanName};
        savedDevices.add(newDevice);
        await _saveDevices();

        // Jika ini device pertama yang ditambahkan, langsung jadikan aktif
        if (savedDevices.length == 1) {
          selectDevice(newDevice);
        }

        Get.back(); // Tutup dialog
        CustomAlert.show(
            AlertType.success,
            'Berhasil',
            'Perangkat berhasil ditambahkan.'
        );
      } else {
        CustomAlert.show(
            AlertType.error,
            'Tidak Ditemukan',
            'Device ID "$cleanId" tidak terdaftar di sistem server.'
        );
      }
    } catch (e) {
      CustomAlert.show(AlertType.error, 'Error', 'Gagal menambahkan perangkat: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // --- FUNGSI UPDATE NAMA DEVICE ---
  Future<void> updateDeviceName(Map<String, String> device, String newName) async {
    if (isLoading.value) return;

    final cleanName = newName.trim();

    if (cleanName.isEmpty) {
      CustomAlert.show(AlertType.warning, 'Input Kosong', 'Nama Perangkat tidak boleh kosong.');
      return;
    }

    if (device['nama'] == cleanName) {
      Get.back(); // Tidak ada perubahan
      return;
    }

    isLoading.value = true;
    try {
      final deviceId = device['id']!;

      // Update di server
      await _repository.saveDeviceName(deviceId, cleanName);

      // Update di list lokal
      int index = savedDevices.indexWhere((d) => d['id'] == deviceId);
      if (index != -1) {
        savedDevices[index] = {'id': deviceId, 'nama': cleanName};
        savedDevices.refresh(); // Trigger update UI
      }

      await _saveDevices();

      Get.back(); // Tutup dialog
      CustomAlert.show(AlertType.success, 'Berhasil', 'Nama perangkat diperbarui.');
    } catch (e) {
      CustomAlert.show(AlertType.error, 'Error', 'Gagal update nama: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // --- FUNGSI HAPUS DEVICE ---
  Future<void> removeDevice(Map<String, String> device) async {
    if (isLoading.value) return;

    isLoading.value = true;
    try {
      final deviceId = device['id'];

      // Hapus dari list lokal
      savedDevices.remove(device);
      await _saveDevices();

      // LOGIKA DASHBOARD:
      // Jika device yang dihapus sedang aktif dimonitoring, bersihkan dashboard
      if (_dashboardController.activeDeviceId.value == deviceId) {
        _dashboardController.clearActiveDevice();

        // Opsional: Langsung pilih device lain jika masih ada sisa device
        if (savedDevices.isNotEmpty) {
          selectDevice(savedDevices.first);
        }
      }

      Get.back(); // Tutup dialog konfirmasi
      CustomAlert.show(AlertType.success, 'Terhapus', 'Perangkat berhasil dihapus.');
    } catch (e) {
      CustomAlert.show(AlertType.error, 'Error', 'Gagal menghapus perangkat.');
    } finally {
      isLoading.value = false;
    }
  }

  // --- FUNGSI PILIH DEVICE ---
  void selectDevice(Map<String, String> device) {
    if (isLoading.value) return;

    if (device['id'] == null) return;

    // Jangan reload jika memilih device yang sedang aktif
    if (_dashboardController.activeDeviceId.value == device['id']) return;

    // Panggil fungsi di DashboardController
    _dashboardController.setActiveDevice(device['id']!);
  }
}