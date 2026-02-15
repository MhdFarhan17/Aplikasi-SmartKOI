import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:smartkoi/app/features/device/devices_controller.dart';
import 'package:smartkoi/app/features/dashboard/controllers/dashboard_controller.dart';

class DevicesScreen extends StatelessWidget {
  const DevicesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Inisialisasi controller
    final DevicesController controller = Get.put(DevicesController());
    final DashboardController dashboardController = Get.find<DashboardController>();

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          'Manajemen Perangkat',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.grey[100],
        elevation: 0,
        centerTitle: true,
      ),
      body: Obx(() {
        final String activeId = dashboardController.activeDeviceId.value;

        // Tampilan jika belum ada perangkat sama sekali
        if (controller.savedDevices.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 10)
                        ]
                    ),
                    child: Icon(Iconsax.cpu, size: 60, color: Colors.grey[400]),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Belum Ada Perangkat',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tambahkan ID perangkat pertama Anda untuk mulai memantau kolam Koi.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey[600], height: 1.5),
                  ),
                ],
              ),
            ),
          );
        }

        // Tampilan List Perangkat
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          // +1 untuk widget Info di bagian paling bawah
          itemCount: controller.savedDevices.length + 1,
          itemBuilder: (context, index) {
            // Widget Info di bagian bawah list
            if (index == controller.savedDevices.length) {
              return Padding(
                padding: const EdgeInsets.only(top: 24.0, bottom: 80.0),
                child: Column(
                  children: [
                    Icon(Iconsax.info_circle, size: 20, color: Colors.grey[400]),
                    const SizedBox(height: 8),
                    Text(
                      "Anda dapat menambahkan beberapa ID Perangkat.\nData di Dashboard akan berubah sesuai perangkat yang DIPILIH.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.grey[500],
                        fontSize: 12,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              );
            }

            final device = controller.savedDevices[index];
            final deviceId = device['id']!;
            final deviceName = device['nama']!;
            final bool isActive = activeId == deviceId;

            return Card(
              elevation: isActive ? 4.0 : 0.5,
              margin: const EdgeInsets.only(bottom: 12),
              shadowColor: isActive ? Colors.blue.withOpacity(0.3) : Colors.black12,
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(
                  color: isActive ? Colors.blue[700]! : Colors.transparent,
                  width: isActive ? 2 : 1,
                ),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                leading: CircleAvatar(
                  backgroundColor: isActive ? Colors.blue[50] : Colors.grey[100],
                  child: Icon(
                    Iconsax.cpu,
                    color: isActive ? Colors.blue[700] : Colors.grey[600],
                  ),
                ),
                title: Text(
                  deviceName,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isActive ? Colors.blue[900] : Colors.black87,
                    fontSize: 16,
                  ),
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 4.0),
                  child: Text(
                    isActive ? 'Sedang Aktif' : 'ID: $deviceId',
                    style: TextStyle(
                      color: isActive ? Colors.blue[700] : Colors.grey[500],
                      fontSize: 12,
                      fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Iconsax.edit, size: 20),
                      color: Colors.blue[700],
                      tooltip: "Ubah Nama",
                      onPressed: () =>
                          _showEditDeviceDialog(context, controller, device),
                    ),
                    IconButton(
                      icon: const Icon(Iconsax.trash, size: 20),
                      color: Colors.red[400],
                      tooltip: "Hapus Perangkat",
                      onPressed: () =>
                          _showRemoveDeviceDialog(context, controller, device),
                    ),
                  ],
                ),
                onTap: () => controller.selectDevice(device),
              ),
            );
          },
        );
      }),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Iconsax.add),
        label: const Text('Tambah Perangkat'),
        backgroundColor: Colors.blue[800],
        foregroundColor: Colors.white,
        onPressed: () {
          _showAddDeviceDialog(context, controller);
        },
      ),
    );
  }

  // --- DIALOG: TAMBAH DEVICE ---
  void _showAddDeviceDialog(BuildContext context, DevicesController controller) {
    final TextEditingController idController = TextEditingController();
    final TextEditingController namaController = TextEditingController();

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Tambah Perangkat Baru',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                const Text(
                  'Masukkan Nama (misal: "Akuarium Teras") dan ID Perangkat yang ada di kotak IoT.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 13, color: Colors.grey),
                ),
                const SizedBox(height: 24),

                // Input Nama
                TextField(
                  controller: namaController,
                  textInputAction: TextInputAction.next, // Lanjut ke kolom berikutnya
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(
                    labelText: 'Nama Perangkat',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Iconsax.tag),
                  ),
                ),
                const SizedBox(height: 16),

                // Input ID
                TextField(
                  controller: idController,
                  inputFormatters: [UpperCaseTextFormatter()],
                  textInputAction: TextInputAction.done, // Selesai input
                  onSubmitted: (_) { // Langsung submit saat tekan Enter
                    FocusScope.of(context).unfocus();
                    controller.addDevice(
                      idController.text.trim(),
                      namaController.text.trim(),
                    );
                  },
                  decoration: const InputDecoration(
                    labelText: 'ID Perangkat',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Iconsax.cpu),
                  ),
                ),
                const SizedBox(height: 24),

                Obx(() => Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: Colors.grey[300]!),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: controller.isLoading.value ? null : () => Get.back(),
                        child: const Text('Batal'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue[800],
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: 0,
                        ),
                        onPressed: controller.isLoading.value
                            ? null
                            : () {
                          FocusScope.of(context).unfocus();
                          controller.addDevice(
                            idController.text.trim(),
                            namaController.text.trim(),
                          );
                        },
                        child: controller.isLoading.value
                            ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                            : const Text('Tambah'),
                      ),
                    ),
                  ],
                )),
              ],
            ),
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

  // --- DIALOG: EDIT NAMA ---
  void _showEditDeviceDialog(BuildContext context, DevicesController controller,
      Map<String, String> device) {
    final TextEditingController namaController =
    TextEditingController(text: device['nama']);

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Ubah Nama',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text(
                  'Ubah nama panggilan untuk ID: ${device['id']}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 13, color: Colors.grey),
                ),
                const SizedBox(height: 24),
                TextField(
                  controller: namaController,
                  textCapitalization: TextCapitalization.words,
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) {
                    FocusScope.of(context).unfocus();
                    controller.updateDeviceName(device, namaController.text.trim());
                  },
                  decoration: const InputDecoration(
                    labelText: 'Nama Perangkat Baru',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Iconsax.edit),
                  ),
                ),
                const SizedBox(height: 24),

                Obx(() => Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: Colors.grey[300]!),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: controller.isLoading.value ? null : () => Get.back(),
                        child: const Text('Batal'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue[800],
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: 0,
                        ),
                        onPressed: controller.isLoading.value
                            ? null
                            : () {
                          FocusScope.of(context).unfocus();
                          controller.updateDeviceName(
                              device, namaController.text.trim());
                        },
                        child: controller.isLoading.value
                            ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                            : const Text('Simpan'),
                      ),
                    ),
                  ],
                )),
              ],
            ),
          ),
        ),
      ),
      barrierDismissible: true,
    );
  }

  // --- DIALOG: HAPUS DEVICE ---
  void _showRemoveDeviceDialog(BuildContext context, DevicesController controller,
      Map<String, String> device) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Iconsax.warning_2, color: Colors.red, size: 48),
              const SizedBox(height: 16),
              Text('Hapus ${device['nama']}?',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Text(
                'Anda yakin ingin menghapus ID "${device['id']}"?\nTindakan ini tidak dapat dibatalkan.',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 24),

              Obx(() => Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Colors.grey[300]!),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: controller.isLoading.value ? null : () => Get.back(),
                      child: const Text('Batal'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                      ),
                      onPressed: controller.isLoading.value
                          ? null
                          : () {
                        controller.removeDevice(device);
                      },
                      child: controller.isLoading.value
                          ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                          : const Text('Ya, Hapus'),
                    ),
                  ),
                ],
              )),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }
}

// Utility: Agar ID Perangkat selalu Kapital saat diketik
class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    return TextEditingValue(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
}