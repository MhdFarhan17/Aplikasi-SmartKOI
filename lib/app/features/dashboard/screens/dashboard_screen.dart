import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:smartkoi/app/data/models/sensor_data_model.dart';
import 'package:smartkoi/app/features/device/devices_screen.dart';
import 'package:smartkoi/app/features/dashboard/controllers/dashboard_controller.dart';
import 'package:smartkoi/app/features/settings/screens/settings_screen.dart';
import 'package:smartkoi/app/features/sensors/screens/sensors_screen.dart';
import 'package:smartkoi/app/shared/utils/sensor_status_util.dart';
import 'package:smartkoi/app/features/profile/screens/profile_screen.dart';
import 'package:smartkoi/app/features/authentication/screens/welcome_screen.dart';
import 'package:smartkoi/app/features/battery/screen/battery_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 2; // Default ke Home

  // Inisialisasi controller di sini agar bisa diakses oleh tab lain jika perlu
  final DashboardController dashboardController = Get.put(DashboardController());

  late final List<Widget> _widgetOptions;

  @override
  void initState() {
    super.initState();
    _widgetOptions = <Widget>[
      const DevicesScreen(), // Tab 0
      const SensorsScreen(), // Tab 1
      DashboardHomePage(
        onGoToDevices: () => _onItemTapped(0), // Callback untuk pindah tab
      ), // Tab 2
      const BatteryScreen(), // Tab 3
      const ProfileScreen(), // Tab 4
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // IndexedStack menjaga state halaman (tidak reload saat pindah tab)
      body: IndexedStack(
        index: _selectedIndex,
        children: _widgetOptions,
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Iconsax.cpu), label: 'Perangkat'),
          BottomNavigationBarItem(icon: Icon(Iconsax.ruler), label: 'Sensor'),
          BottomNavigationBarItem(icon: Icon(Iconsax.home), label: 'Beranda'),
          BottomNavigationBarItem(icon: Icon(Iconsax.battery_full), label: 'Baterai'),
          BottomNavigationBarItem(icon: Icon(Iconsax.user), label: 'Profil'),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Colors.blue[700],
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        elevation: 10,
      ),
    );
  }
}

class DashboardHomePage extends StatelessWidget {
  final VoidCallback onGoToDevices;

  const DashboardHomePage({
    super.key,
    required this.onGoToDevices,
  });

  @override
  Widget build(BuildContext context) {
    // Kita gunakan Get.find karena sudah di-put di parent (DashboardScreen)
    final DashboardController controller = Get.find<DashboardController>();

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F8),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFFF4F7F8),
        title: const Text(
          'Status Akuarium',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Iconsax.setting_2, color: Colors.black87),
            onPressed: () => Get.to(() => const SettingsScreen()),
          ),
          IconButton(
            icon: const Icon(Iconsax.logout, color: Colors.red),
            onPressed: () => _showLogoutDialog(context),
          )
        ],
      ),
      body: Obx(() {
        // 1. Cek Loading State
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        // 2. Cek Apakah ada Device Aktif
        if (controller.activeDeviceId.isEmpty) {
          return _buildNotConnectedUI(context, onGoToDevices);
        }

        // 3. Cek Data Stream (Nested Obx untuk efisiensi render)
        // Kita cek apakah data sudah masuk atau masih null (proses koneksi awal)
        final settings = controller.controlSettings.value;
        final sensorData = controller.sensorData.value;
        final batteryData = controller.batteryData.value;

        if (settings == null || sensorData == null || batteryData == null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: 16),
                Text("Menghubungkan ke ${controller.activeDeviceId.value}...",
                    style: TextStyle(color: Colors.grey[600])),
              ],
            ),
          );
        }

        // Hitung Status Sensor
        final suhuStatus = SensorStatusUtil.getStatusForSuhu(sensorData.suhu, settings);
        final phStatus = SensorStatusUtil.getStatusForPh(sensorData.ph, settings);
        final tdsStatus = SensorStatusUtil.getStatusForTds(sensorData.tds, settings);
        final turbidityStatus = SensorStatusUtil.getStatusForTurbidity(sensorData.turbidity, settings);
        final kekeruhanStatus = SensorStatusUtil.getStatusForKekeruhan(sensorData.kekeruhan);

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- KARTU STATUS UTAMA ---
              _buildOverallStatusCard(
                context,
                sensorData,
                suhuStatus,
                phStatus,
                tdsStatus,
                turbidityStatus,
                kekeruhanStatus,
              ),

              const SizedBox(height: 24),

              // --- STATUS DAYA & JARINGAN ---
              const Text(
                'Status Baterai dan Jaringan',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  DeviceStatusTile(
                    icon: batteryData.status.toLowerCase() == 'discharging'
                        ? Iconsax.battery_disable
                        : Iconsax.battery_charging,
                    label: 'Baterai',
                    status: batteryData.status,
                    statusColor: batteryData.status.toLowerCase() == 'discharging'
                        ? Colors.orange.shade600
                        : Colors.green.shade700,
                    onTap: () => _showDetailDialog(
                      context,
                      title: "Power Status",
                      content: "Standby dan Charging: Listrik Utama (PLN) Aktif.\nDischarging: Menggunakan Baterai Sebagai Daya Cadangan (Listrik Mati).",
                      icon: Iconsax.battery_charging,
                      color: Colors.green,
                    ),
                  ),
                  const SizedBox(width: 16),
                  DeviceStatusTile(
                    icon: sensorData.network.toLowerCase() == 'wifi'
                        ? Iconsax.wifi
                        : Iconsax.mobile,
                    label: 'Jaringan',
                    status: sensorData.network,
                    statusColor: sensorData.network.toLowerCase() == 'wifi'
                        ? Colors.blue.shade700
                        : Colors.purple.shade600,
                    onTap: () => _showDetailDialog(
                      context,
                      title: "Koneksi Jaringan",
                      content: "WiFi: Koneksi internet utama.\nGSM/SIM: Koneksi cadangan saat WiFi terputus.",
                      icon: Iconsax.wifi,
                      color: Colors.blue,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // --- DATA SENSOR ---
              const Text(
                'Data Terbaru Sensor',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),

              _buildKekeruhanCard(
                context: context,
                kekeruhanStatus: kekeruhanStatus,
              ),

              const SizedBox(height: 16),

              // Grid Sensor
              GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  SensorCard(
                    icon: Iconsax.sun_1,
                    title: 'Suhu',
                    value: sensorData.suhu.toStringAsFixed(1),
                    unit: '°C',
                    status: suhuStatus.text,
                    statusColor: suhuStatus.color,
                    iconColor: Colors.orange.shade400,
                    onTap: () => _showDetailDialog(
                      context,
                      title: "Suhu Air",
                      content: "Suhu ideal Koi: 23°C - 30°C.\nPerubahan suhu drastis dapat menyebabkan stres.",
                      icon: Iconsax.sun_1,
                      color: Colors.orange,
                    ),
                  ),
                  SensorCard(
                    icon: Iconsax.colorfilter,
                    title: 'Level pH',
                    value: sensorData.ph.toStringAsFixed(1),
                    unit: '',
                    status: phStatus.text,
                    statusColor: phStatus.color,
                    iconColor: Colors.green.shade600,
                    onTap: () => _showDetailDialog(
                      context,
                      title: "Level pH",
                      content: "pH Netral adalah 7.0.\nIdeal Koi: 6.5 - 8.5.",
                      icon: Iconsax.colorfilter,
                      color: Colors.green,
                    ),
                  ),
                  SensorCard(
                    icon: Iconsax.blend_2,
                    title: 'TDS',
                    value: sensorData.tds.toStringAsFixed(0),
                    unit: 'ppm',
                    status: tdsStatus.text,
                    statusColor: tdsStatus.color,
                    iconColor: Colors.blue.shade400,
                    onTap: () => _showDetailDialog(
                      context,
                      title: "TDS (Zat Terlarut)",
                      content: "Mengukur kepekatan air.\nIdeal: < 300 ppm.",
                      icon: Iconsax.blend_2,
                      color: Colors.blue,
                    ),
                  ),
                  SensorCard(
                    icon: Iconsax.ruler,
                    title: 'Turbidity',
                    value: sensorData.turbidity.toStringAsFixed(1),
                    unit: 'NTU',
                    status: turbidityStatus.text,
                    statusColor: turbidityStatus.color,
                    iconColor: Colors.purple.shade300,
                    onTap: () => _showDetailDialog(
                      context,
                      title: "Kekeruhan (Turbidity)",
                      content: "Tingkat kekeruhan air.\nIdeal: < 400 NTU.",
                      icon: Iconsax.ruler,
                      color: Colors.purple,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // --- STATUS ALAT (AKTUATOR) ---
              const Text(
                'Status Aktuator',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  EquipmentStatusTile(
                    icon: Iconsax.airdrop,
                    label: 'Pendingin',
                    status: sensorData.statusCooler,
                    onTap: () => _showDetailDialog(
                      context,
                      title: "Pendingin (Cooler)",
                      content: "Aktif otomatis jika suhu melebihi batas maksimal.",
                      icon: Iconsax.airdrop,
                      color: Colors.cyan,
                    ),
                  ),
                  const SizedBox(width: 16),
                  EquipmentStatusTile(
                    icon: Iconsax.flash_1,
                    label: 'Penghangat',
                    status: sensorData.statusHeater,
                    onTap: () => _showDetailDialog(
                      context,
                      title: "Penghangat (Heater)",
                      content: "Aktif otomatis jika suhu kurang dari batas minimum.",
                      icon: Iconsax.flash_1,
                      color: Colors.orange,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
            ],
          ),
        );
      }),
    );
  }

  // --- HELPER METHODS ---

  void _showDetailDialog(BuildContext context,
      {required String title,
        required String content,
        required IconData icon,
        required MaterialColor color}) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                    color: color.shade50,
                    shape: BoxShape.circle
                ),
                child: Icon(icon, color: color.shade700, size: 32),
              ),
              const SizedBox(height: 16),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Text(
                content,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 14, color: Colors.black54, height: 1.5),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[700],
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () => Get.back(),
                  child: const Text("Mengerti", style: TextStyle(color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Dialog Logout yang lebih cantik dan konsisten
  void _showLogoutDialog(BuildContext context) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Iconsax.logout, color: Colors.red, size: 48),
              const SizedBox(height: 16),
              const Text(
                'Konfirmasi Keluar',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Apakah Anda yakin ingin keluar dari aplikasi?',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.back(),
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text('Batal', style: TextStyle(color: Colors.grey)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        Get.back(); // Tutup dialog dulu
                        // Proses Logout
                        final DashboardController controller = Get.find();
                        controller.clearActiveDevice(); // Bersihkan data di memori
                        await FirebaseAuth.instance.signOut();
                        Get.offAll(() => const WelcomeScreen());
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text('Keluar', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNotConnectedUI(BuildContext context, VoidCallback onGoToDevices) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(Iconsax.cpu, size: 60, color: Colors.blue[700]),
            ),
            const SizedBox(height: 24),
            const Text(
              'Belum Terhubung',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(
              'Anda belum menghubungkan Perangkat IoT SmartKoi. Tambahkan Perangkat untuk mulai Monitoring.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey[600], height: 1.5),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              icon: const Icon(Iconsax.add_square, color: Colors.white),
              label: const Text('Tambah Perangkat', style: TextStyle(color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[700],
                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: onGoToDevices,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOverallStatusCard(
      BuildContext context,
      SensorData data,
      SensorStatus suhuStatus,
      SensorStatus phStatus,
      SensorStatus tdsStatus,
      SensorStatus turbidityStatus,
      SensorStatus kekeruhanStatus,
      ) {

    // Logika Status Keseluruhan
    final bool isNormal = (suhuStatus.text == 'Ideal') &&
        (phStatus.text == 'Netral') &&
        (tdsStatus.text == 'Ideal') &&
        (turbidityStatus.text == 'Jernih') &&
        (kekeruhanStatus.text == 'Jernih');

    final statusText = isNormal ? 'Semua Sistem Normal' : 'Perlu Perhatian!';
    final bgColor = isNormal ? Colors.green.shade50 : Colors.orange.shade50;
    final borderColor = isNormal ? Colors.green.shade200 : Colors.orange.shade200;
    final icon = isNormal ? Iconsax.tick_circle : Iconsax.warning_2;
    final iconColor = isNormal ? Colors.green.shade700 : Colors.orange.shade700;

    // Format Waktu
    final dateTime = DateTime.fromMillisecondsSinceEpoch(data.lastUpdate * 1000);
    final formattedTime = DateFormat('d MMM, HH:mm').format(dateTime);

    return InkWell(
      onTap: () => _showDetailDialog(
        context,
        title: "Status Sistem Keseluruhan",
        content: isNormal
            ? "Bagus! Semua parameter air dalam kondisi ideal untuk Koi."
            : "Peringatan! Ada sensor yang mendeteksi nilai tidak ideal. Cek detail di bawah.",
        icon: icon,
        color: isNormal ? Colors.green : Colors.orange,
      ),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: const BoxDecoration(
                  color: Colors.white, shape: BoxShape.circle),
              child: Icon(icon, color: iconColor, size: 32),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    statusText,
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: iconColor),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Terakhir Update: $formattedTime',
                    style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 14, color: iconColor.withOpacity(0.5)),
          ],
        ),
      ),
    );
  }

  Widget _buildKekeruhanCard(
      {required BuildContext context, required SensorStatus kekeruhanStatus}) {
    return InkWell(
      onTap: () => _showDetailDialog(
        context,
        title: "Kualitas Visual Air",
        content: "Jernih: Bagus.\nKeruh: Cek filter air.\nKotor: Bahaya, segera bersihkan !",
        icon: Iconsax.eye,
        color: Colors.grey,
      ),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              )
            ]
        ),
        child: Row(
          children: [
            Icon(Iconsax.eye, color: kekeruhanStatus.color, size: 28),
            const SizedBox(width: 12),
            const Text(
              'Kualitas Visual Air',
              style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: kekeruhanStatus.color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                kekeruhanStatus.text,
                style: TextStyle(
                    color: kekeruhanStatus.color,
                    fontWeight: FontWeight.bold,
                    fontSize: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// === WIDGETS PENDUKUNG (Grid, Tiles) ===

class SensorCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final String unit;
  final String status;
  final Color statusColor;
  final Color iconColor;
  final VoidCallback? onTap;

  const SensorCard({
    super.key,
    required this.icon,
    required this.title,
    required this.value,
    required this.unit,
    required this.status,
    required this.statusColor,
    required this.iconColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.05),
              spreadRadius: 1,
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(icon, color: iconColor, size: 20),
                const SizedBox(width: 8),
                Expanded(
                    child: Text(title,
                        style: TextStyle(color: Colors.grey[600], fontSize: 13),
                        overflow: TextOverflow.ellipsis)),
              ],
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(value,
                    style: const TextStyle(
                        fontSize: 24, fontWeight: FontWeight.bold)),
                const SizedBox(width: 2),
                Text(unit,
                    style: TextStyle(
                        fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey[400])),
              ],
            ),
            Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                      color: statusColor, shape: BoxShape.circle),
                ),
                const SizedBox(width: 6),
                Expanded(child: Text(status, style: TextStyle(color: statusColor, fontWeight: FontWeight.w500, fontSize: 12), overflow: TextOverflow.ellipsis)),
              ],
            )
          ],
        ),
      ),
    );
  }
}

class DeviceStatusTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String status;
  final Color statusColor;
  final VoidCallback? onTap;

  const DeviceStatusTile({
    super.key,
    required this.icon,
    required this.label,
    required this.status,
    required this.statusColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(color: Colors.grey.withOpacity(0.05), blurRadius: 5)
              ]
          ),
          child: Row(
            children: [
              Icon(icon, color: statusColor, size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label,
                        style: const TextStyle(
                            color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 2),
                    Text(
                      status.toUpperCase(),
                      style: TextStyle(
                          color: statusColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 14),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class EquipmentStatusTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String status;
  final VoidCallback? onTap;

  const EquipmentStatusTile({
    super.key,
    required this.icon,
    required this.label,
    required this.status,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bool isActive = status.toUpperCase() == 'ON';
    final Color statusColor = isActive ? Colors.green.shade600 : Colors.grey.shade400;

    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(color: Colors.grey.withOpacity(0.05), blurRadius: 5)
              ]
          ),
          child: Row(
            children: [
              Icon(icon, color: statusColor, size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label,
                        style: const TextStyle(
                            color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 2),
                    Text(
                      status.toUpperCase(),
                      style: TextStyle(
                          color: statusColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 14),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}