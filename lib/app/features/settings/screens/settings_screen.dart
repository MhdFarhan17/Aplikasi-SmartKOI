import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

// Imports
import 'package:smartkoi/app/features/settings/controllers/settings_controller.dart';
import 'package:smartkoi/app/shared/widgets/custom_dialog.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Inject Controller
    final SettingsController controller = Get.put(SettingsController());

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F8),
      appBar: AppBar(
        title: const Text(
          'Pengaturan Parameter',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFFF4F7F8),
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      // Obx mendengarkan perubahan data di Controller
      body: Obx(() {
        // 1. Cek Koneksi Device
        if (!controller.isDeviceActive) {
          return _buildNotConnectedUI();
        }

        // 2. Ambil Data Settings
        final settings = controller.controlSettings;
        final notifSettings = controller.notificationSettings;

        if (settings == null) {
          return const Center(child: CircularProgressIndicator());
        }

        return ListView(
          padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 20.0),
          children: [
            // --- BAGIAN 1: BATAS PARAMETER ---
            _buildSectionTitle('Nilai Parameter Sensor'),
            const SizedBox(height: 12),

            Container(
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)
                  ]
              ),
              child: Column(
                children: [
                  // SUHU
                  SettingsTile(
                    icon: Iconsax.sun_1,
                    iconColor: Colors.orange,
                    title: 'Suhu Air',
                    subtitle: 'Batas suhu ideal (°C)',
                    value: '${settings.suhuMin} - ${settings.suhuMax}',
                    onTap: () => _showUpdateSuhuDialog(context, controller),
                  ),
                  const Divider(height: 1, indent: 60, endIndent: 20),

                  // pH
                  SettingsTile(
                    icon: Iconsax.colorfilter,
                    iconColor: Colors.green,
                    title: 'Derajat Keasaman (pH)',
                    subtitle: 'Rentang pH aman',
                    value: '${settings.phMin} - ${settings.phMax}',
                    onTap: () => _showUpdatePhDialog(context, controller),
                  ),
                  const Divider(height: 1, indent: 60, endIndent: 20),

                  // TDS
                  SettingsTile(
                    icon: Iconsax.blend_2,
                    iconColor: Colors.blue,
                    title: 'Zat Terlarut (TDS)',
                    subtitle: 'Batas mineral (ppm)',
                    value: '${settings.tdsMin} - ${settings.tdsMax}',
                    onTap: () => _showUpdateTdsDialog(context, controller),
                  ),
                  const Divider(height: 1, indent: 60, endIndent: 20),

                  // TURBIDITY
                  SettingsTile(
                    icon: Iconsax.ruler,
                    iconColor: Colors.purple,
                    title: 'Kekeruhan',
                    subtitle: 'Kejernihan air (NTU)',
                    value: '${settings.turbidityMin} - ${settings.turbidityMax}',
                    onTap: () => _showUpdateTurbidityDialog(context, controller),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // --- BAGIAN 2: PENGATURAN WI-FI ALAT ---
            _buildSectionTitle('Wi-Fi Perangkat'),
            const SizedBox(height: 12),

            Container(
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)
                  ]
              ),
              child: SettingsTile(
                icon: Iconsax.wifi,
                iconColor: Colors.cyan,
                title: 'Wi-Fi Perangkat',
                subtitle: 'Ubah SSID dan Password Perangkat',
                // Value diambil dari RxString secara realtime
                value: controller.currentSsid.value,
                onTap: () => _showUpdateWifiDialog(context, controller),
              ),
            ),

            const SizedBox(height: 30),

            // --- BAGIAN 3: NOTIFIKASI ---
            _buildSectionTitle('Notifikasi'),
            const SizedBox(height: 12),

            Container(
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)
                  ]
              ),
              child: Column(
                children: [
                  NotificationSwitchTile(
                    icon: Iconsax.danger,
                    title: 'Peringatan Bahaya',
                    subtitle: 'Notifikasi jika sensor melewati batas',
                    value: notifSettings['critical_alerts_enabled'] ?? false,
                    onChanged: (newValue) => controller
                        .updateNotificationSetting('critical_alerts_enabled', newValue),
                  ),
                  const Divider(height: 1, indent: 60, endIndent: 20),
                  NotificationSwitchTile(
                    icon: Iconsax.wifi_square,
                    title: 'Status Perangkat',
                    subtitle: 'Notifikasi jika alat Offline/Mati Lampu',
                    value: notifSettings['offline_alerts_enabled'] ?? false,
                    onChanged: (newValue) => controller
                        .updateNotificationSetting('offline_alerts_enabled', newValue),
                  ),
                ],
              ),
            ),
          ],
        );
      }),
    );
  }

  // --- DIALOG UPDATE ---

  // Dialog Baru: Wi-Fi
  void _showUpdateWifiDialog(BuildContext context, SettingsController controller) {
    Get.dialog(
      CustomActionDialog(
        title: 'Pengaturan Wi-Fi Alat',
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange.shade200)
              ),
              child: Row(
                children: [
                  Icon(Iconsax.info_circle, color: Colors.orange.shade700, size: 20),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Pastikan nama Wi-Fi (SSID) dan Password diketik dengan benar (huruf besar/kecil berpengaruh).',
                      style: TextStyle(fontSize: 12, color: Colors.black87),
                    ),
                  ),
                ],
              ),
            ),
            _buildTextField(
              controller: controller.ssidC,
              label: 'Nama Wi-Fi (SSID)',
              action: TextInputAction.next,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: controller.passwordC,
              label: 'Password Wi-Fi',
              action: TextInputAction.done,
              isPassword: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('Batal', style: TextStyle(color: Colors.grey[600])),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: () => controller.saveWifiSettings(),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue[700],
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }


  // 1. Dialog Suhu
  void _showUpdateSuhuDialog(
      BuildContext context, SettingsController controller) {
    Get.dialog(
      CustomActionDialog(
        title: 'Batas Suhu (°C)',
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildNumberField(
                controller: controller.suhuMinC,
                label: 'Minimum',
                action: TextInputAction.next
            ),
            const SizedBox(height: 16),
            _buildNumberField(
                controller: controller.suhuMaxC,
                label: 'Maksimum',
                action: TextInputAction.done
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('Batal', style: TextStyle(color: Colors.grey[600])),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: () => controller.saveTemperatureSettings(),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue[700],
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  // 2. Dialog pH
  void _showUpdatePhDialog(
      BuildContext context, SettingsController controller) {
    Get.dialog(
      CustomActionDialog(
        title: 'Batas pH',
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildNumberField(
                controller: controller.phMinC,
                label: 'Minimum (Asam)',
                action: TextInputAction.next
            ),
            const SizedBox(height: 16),
            _buildNumberField(
                controller: controller.phMaxC,
                label: 'Maksimum (Basa)',
                action: TextInputAction.done
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('Batal', style: TextStyle(color: Colors.grey[600])),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: () => controller.savePhSettings(),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue[700],
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  // 3. Dialog TDS
  void _showUpdateTdsDialog(
      BuildContext context, SettingsController controller) {
    Get.dialog(
      CustomActionDialog(
        title: 'Batas TDS (ppm)',
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildNumberField(
                controller: controller.tdsMinC,
                label: 'Minimum',
                action: TextInputAction.next
            ),
            const SizedBox(height: 16),
            _buildNumberField(
                controller: controller.tdsMaxC,
                label: 'Maksimum',
                action: TextInputAction.done
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('Batal', style: TextStyle(color: Colors.grey[600])),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: () => controller.saveTdsSettings(),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue[700],
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  // 4. Dialog Turbidity
  void _showUpdateTurbidityDialog(
      BuildContext context, SettingsController controller) {
    Get.dialog(
      CustomActionDialog(
        title: 'Batas Kekeruhan (NTU)',
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildNumberField(
                controller: controller.turbidityMinC,
                label: 'Minimum',
                action: TextInputAction.next
            ),
            const SizedBox(height: 16),
            _buildNumberField(
                controller: controller.turbidityMaxC,
                label: 'Maksimum',
                action: TextInputAction.done
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('Batal', style: TextStyle(color: Colors.grey[600])),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: () => controller.saveTurbiditySettings(),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue[700],
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  // --- WIDGET HELPERS ---

  // Helper untuk tombol Save/Cancel berulang
  List<Widget> _buildDialogActions(VoidCallback onSave) {
    return [
      TextButton(
        onPressed: () => Get.back(),
        child: Text('Batal', style: TextStyle(color: Colors.grey[600])),
      ),
      const SizedBox(width: 8),
      ElevatedButton(
        onPressed: onSave,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue[700],
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: const Text('Simpan'),
      ),
    ];
  }

  /// Helper untuk Text Field Angka (Decimal)
  Widget _buildNumberField({
    required TextEditingController controller,
    required String label,
    required TextInputAction action
  }) {
    return TextField(
      controller: controller,
      // Penting: decimal: true agar bisa input koma untuk pH/Suhu
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      textInputAction: action,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }

  /// Helper untuk Input Teks Biasa (Untuk Wi-Fi)
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required TextInputAction action,
    bool isPassword = false,
  }) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.text, // Keyboard huruf biasa
      textInputAction: action,
      obscureText: false, // Set true jika ingin password disembunyikan (***)
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }

  Widget _buildNotConnectedUI() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                shape: BoxShape.circle,
              ),
              child: Icon(Iconsax.setting_2, size: 40, color: Colors.grey[500]),
            ),
            const SizedBox(height: 24),
            const Text(
              'Tidak Ada Perangkat',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Hubungkan perangkat terlebih dahulu untuk mengubah parameter.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, left: 4.0),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
            color: Colors.grey[600], fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 0.5),
      ),
    );
  }
}

// --- WIDGET TILES ---

class SettingsTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final String value;
  final VoidCallback onTap;

  const SettingsTile({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onTap
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: iconColor.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: iconColor, size: 22),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
      subtitle: Text(subtitle, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(6)
            ),
            // Agar kalau SSID panjang tidak overflow
            constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.35),
            child: Text(value, style: TextStyle(color: Colors.grey[800], fontSize: 13, fontWeight: FontWeight.w600), overflow: TextOverflow.ellipsis,),
          ),
          const SizedBox(width: 8),
          Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey[400]),
        ],
      ),
      onTap: onTap,
    );
  }
}

class NotificationSwitchTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const NotificationSwitchTile({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: value ? Colors.blue.withOpacity(0.1) : Colors.grey.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: value ? Colors.blue[700] : Colors.grey, size: 22),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
      subtitle: Text(subtitle, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: Colors.blue[700],
        inactiveThumbColor: Colors.white,
        inactiveTrackColor: Colors.grey[300],
      ),
    );
  }
}