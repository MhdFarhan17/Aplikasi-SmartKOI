import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:smartkoi/app/features/dashboard/controllers/dashboard_controller.dart';
import 'package:smartkoi/app/data/models/battery_data_model.dart';

class BatteryScreen extends StatelessWidget {
  const BatteryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Menggunakan DashboardController yang sudah ada
    final DashboardController controller = Get.find<DashboardController>();

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F8),
      appBar: AppBar(
        title: const Text(
          'Monitor Baterai',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFFF4F7F8),
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false, // Hilangkan back button karena ini Tab
      ),
      body: Obx(() {
        // 1. Loading State
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        // 2. Belum ada device
        if (controller.activeDeviceId.isEmpty) {
          return _buildNotConnectedUI();
        }

        final batteryData = controller.batteryData.value;

        // 3. Menunggu data stream
        if (batteryData == null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: 16),
                Text('Menunggu data baterai...', style: TextStyle(color: Colors.grey[600])),
              ],
            ),
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Kartu Status Utama (Besar)
              _buildMainStatusCard(context, batteryData),

              const SizedBox(height: 24),

              // Kartu Instruksi
              _buildInstructionCard(),

              const SizedBox(height: 24),

              const Text(
                  'Info Detail Baterai',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)
              ),
              const SizedBox(height: 12),

              // List Detail Dinamis
              Container(
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)
                    ]
                ),
                child: _buildConditionalDetails(context, batteryData),
              ),

              const SizedBox(height: 24),

              // Kartu Rekomendasi
              _buildBatteryRecommendationCard(context),

              const SizedBox(height: 30),
            ],
          ),
        );
      }),
    );
  }

  /// WIDGET: Kartu Status Utama
  Widget _buildMainStatusCard(BuildContext context, BatteryDataModel data) {
    final int powerValue = data.power;
    final String status = data.status;
    Color statusColor;
    Color bgColor;
    IconData statusIcon;

    // Logika Warna & Ikon
    switch (status.toLowerCase()) {
      case 'charging':
        statusColor = Colors.green.shade600;
        bgColor = Colors.green.shade50;
        statusIcon = Iconsax.battery_charging;
        break;
      case 'discharging':
        statusColor = Colors.orange.shade700;
        bgColor = Colors.orange.shade50;
        statusIcon = Iconsax.battery_disable; // Ikon petir silang/baterai turun
        break;
      default: // Standby / Full
        statusColor = Colors.blue.shade600;
        bgColor = Colors.blue.shade50;
        statusIcon = Iconsax.battery_full;
    }

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: statusColor.withOpacity(0.2), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: statusColor.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header Kartu
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Daya Baterai',
                  style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                      fontWeight: FontWeight.bold)),
              InkWell(
                onTap: () => _showMainStatusDialog(context),
                borderRadius: BorderRadius.circular(20),
                child: Icon(Iconsax.info_circle, size: 22, color: Colors.grey[400]),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Indikator Utama
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Ikon dalam lingkaran
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: bgColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  statusIcon,
                  color: statusColor,
                  size: 40,
                ),
              ),
              const SizedBox(width: 20),

              // Angka Persentase
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    powerValue.toString(),
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 60,
                      fontWeight: FontWeight.bold,
                      height: 1,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0, left: 4.0),
                    child: Text(
                      "%",
                      style: TextStyle(
                        color: statusColor,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Label Status (Capsule)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(30),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(width: 8, height: 8, decoration: BoxDecoration(color: statusColor, shape: BoxShape.circle)),
                const SizedBox(width: 8),
                Text(
                  'Status: ${status.toUpperCase()}',
                  style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 14),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// WIDGET: Kartu Instruksi
  Widget _buildInstructionCard() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.blue.shade100),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Iconsax.lamp_on, color: Colors.blue[700], size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Tips: Klik pada salah satu detail di bawah untuk memahami cara kerja sistem backup daya.',
              style: TextStyle(color: Colors.blue[800], fontSize: 13, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }

  /// WIDGET: Kartu Rekomendasi
  Widget _buildBatteryRecommendationCard(BuildContext context) {
    return InkWell(
      onTap: () => _showDetailDialog(
        context: context,
        title: 'Spesifikasi Baterai',
        description:
        'Sistem ini dirancang untuk bekerja optimal dengan baterai spesifikasi khusus. Penggantian yang tidak sesuai dapat merusak kontroler.',
        detailInfo:
        '• Tipe: SLA (Sealed Lead Acid) 12V\n• Kapasitas: 25 Ah (C/10) atau 20 Ah (C/2)\n• Kapasitas Efektif pada beban penuh: ~11.7 Ah.\n\nMenggunakan baterai di bawah 20Ah akan membuat waktu backup sangat singkat.',
        icon: Iconsax.shield_tick,
        color: Colors.purple,
        showWarning: true,
        warningText: 'PERINGATAN: Jangan gunakan baterai mobil (Starter Battery) karena tidak didesain untuk Deep Cycle (pengurasan daya terus menerus).',
      ),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.purple.shade50, Colors.white],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.purple.shade100),
            boxShadow: [
              BoxShadow(color: Colors.purple.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5))
            ]
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.purple.shade100,
                shape: BoxShape.circle,
              ),
              child: Icon(Iconsax.battery_3full, color: Colors.purple.shade700, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Rekomendasi Baterai',
                      style: TextStyle(
                          color: Colors.purple.shade900,
                          fontWeight: FontWeight.bold,
                          fontSize: 15)),
                  const SizedBox(height: 4),
                  Text('Cek spesifikasi pengganti.',
                      style: TextStyle(
                          color: Colors.purple.shade700, fontSize: 12)),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: Colors.purple.shade300, size: 14),
          ],
        ),
      ),
    );
  }

  /// WIDGET: Logic List Detail
  Widget _buildConditionalDetails(BuildContext context, BatteryDataModel data) {
    // Item 1: Kapasitas (Selalu Muncul)
    final capacityItem = BatteryDetailListItem(
      icon: Iconsax.battery_3full,
      iconColor: Colors.grey.shade700,
      title: 'Kapasitas Total',
      value: '${data.capacity} Ah',
      onTap: () => _showDetailDialog(
        context: context,
        title: 'Kapasitas Baterai',
        description: 'Total energi yang dapat disimpan baterai dalam satuan Ampere-hour.',
        detailInfo: 'Rating: ${data.capacity} Ah\n\nSemakin besar angka ini, semakin lama alat bisa menyala saat mati lampu.',
        icon: Iconsax.battery_3full,
        color: Colors.grey,
      ),
    );

    List<Widget> items = [capacityItem];

    // Logika Tampilan Berdasarkan Status
    if (data.status.toLowerCase() == 'charging') {
      items.add(const Divider(height: 1, indent: 64, endIndent: 20));
      items.add(BatteryDetailListItem(
        icon: Iconsax.flash_1,
        iconColor: Colors.green.shade600,
        title: 'Arus Masuk (Charging)',
        value: '${data.currentIn} A',
        onTap: () => _showDetailDialog(
          context: context,
          title: 'Arus Pengisian',
          description: 'Kecepatan listrik masuk ke baterai.',
          detailInfo: 'Laju: ${data.currentIn} Ampere\n\nSistem mengatur arus ini secara otomatis agar baterai tidak panas.',
          icon: Iconsax.flash_1,
          color: Colors.green,
        ),
      ));

      items.add(const Divider(height: 1, indent: 64, endIndent: 20));
      items.add(BatteryDetailListItem(
        icon: Iconsax.timer_1,
        iconColor: Colors.blue.shade600,
        title: 'Estimasi Penuh',
        value: data.timeUntilFull,
        onTap: () => _showDetailDialog(
          context: context,
          title: 'Waktu Penuh',
          description: 'Perkiraan waktu hingga baterai mencapai 100%.',
          detailInfo: 'Sisa Waktu: ${data.timeUntilFull}\n\nSemakin mendekati 100%, pengisian akan melambat (fase absorption).',
          icon: Iconsax.timer_1,
          color: Colors.blue,
        ),
      ));

    } else if (data.status.toLowerCase() == 'discharging') {
      items.add(const Divider(height: 1, indent: 64, endIndent: 20));
      items.add(BatteryDetailListItem(
        icon: Iconsax.flash_1,
        iconColor: Colors.red.shade600,
        title: 'Beban Arus (Keluar)',
        value: '${data.currentOut} A',
        onTap: () => _showDetailDialog(
          context: context,
          title: 'Beban Sistem',
          description: 'Listrik yang dipakai alat saat ini (dari baterai).',
          detailInfo: 'Beban: ${data.currentOut} Ampere\n\nKarena listrik utama mati, semua komponen IoT mengambil daya dari baterai ini.',
          icon: Iconsax.flash_1,
          color: Colors.red,
        ),
      ));

      items.add(const Divider(height: 1, indent: 64, endIndent: 20));
      items.add(BatteryDetailListItem(
        icon: Iconsax.timer_start,
        iconColor: Colors.orange.shade600,
        title: 'Durasi Backup',
        value: data.dischargingTime,
        onTap: () => _showDetailDialog(
          context: context,
          title: 'Waktu Berjalan',
          description: 'Lama waktu alat bertahan sejak listrik mati.',
          detailInfo: 'Durasi: ${data.dischargingTime}\n\nJika baterai mencapai batas kritis, alat akan mati total untuk melindungi baterai.',
          icon: Iconsax.timer_start,
          color: Colors.orange,
        ),
      ));

    } else {
      // Standby / Full
      items.add(const Divider(height: 1, indent: 64, endIndent: 20));
      items.add(BatteryDetailListItem(
        icon: Iconsax.flash_circle,
        iconColor: Colors.blue.shade600,
        title: 'Arus Standby',
        value: '${data.current} A',
        onTap: () => _showDetailDialog(
          context: context,
          title: 'Mode Siaga',
          description: 'Arus kecil untuk menjaga baterai tetap di 100%.',
          detailInfo: 'Arus: ${data.current} A\n\nListrik utama (PLN) aktif. Baterai aman dan siap digunakan kapan saja.',
          icon: Iconsax.flash_circle,
          color: Colors.blue,
        ),
      ));
    }

    return Column(children: items);
  }

  // --- DIALOGS ---

  void _showMainStatusDialog(BuildContext context) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Iconsax.info_circle, color: Colors.blue.shade700),
                  const SizedBox(width: 12),
                  const Text('Status Daya',
                      style:
                      TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ],
              ),
              const Divider(height: 24),
              _buildStatusExplanation('Charging', Colors.green,
                  'Listrik PLN hidup. Baterai sedang diisi ulang.'),
              const SizedBox(height: 12),
              _buildStatusExplanation('Discharging', Colors.red,
                  'Listrik PLN MATI. Alat menggunakan daya cadangan baterai.'),
              const SizedBox(height: 12),
              _buildStatusExplanation('Standby', Colors.blue,
                  'Baterai Penuh (100%). Alat menggunakan listrik PLN.'),

              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12)
                ),
                child: const Text(
                    'Sistem akan otomatis mati jika baterai < 50% untuk mencegah kerusakan permanen pada sel baterai (Deep Discharge Protection).',
                    style: TextStyle(color: Colors.black87, fontSize: 12, height: 1.4)),
              ),

              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Get.back(),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[700],
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))
                  ),
                  child: const Text("Tutup", style: TextStyle(color: Colors.white)),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusExplanation(String label, Color color, String desc) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(top: 4),
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: const TextStyle(color: Colors.black87, fontSize: 13, height: 1.3),
              children: [
                TextSpan(
                    text: '$label: ',
                    style: TextStyle(fontWeight: FontWeight.bold, color: color)),
                TextSpan(text: desc),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _showDetailDialog({
    required BuildContext context,
    required String title,
    required String description,
    required String detailInfo,
    required IconData icon,
    required MaterialColor? color,
    bool showWarning = false,
    String? warningText,
  }) {
    MaterialColor themeColor = color ?? Colors.blue;

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                        color: themeColor.shade50, shape: BoxShape.circle),
                    child: Icon(icon, color: themeColor.shade700, size: 24),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                      child: Text(title,
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold))),
                ],
              ),
              const SizedBox(height: 20),

              Text("Definisi:", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey[600])),
              const SizedBox(height: 4),
              Text(description,
                  style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black87, height: 1.4)),

              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Info Teknis:", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey[600])),
                    const SizedBox(height: 4),
                    Text(detailInfo,
                        style: const TextStyle(
                            fontSize: 13, color: Colors.black87, height: 1.4)),
                  ],
                ),
              ),

              if (showWarning && warningText != null) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Iconsax.danger, color: Colors.red.shade700, size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(warningText,
                            style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: Colors.red.shade800,
                                height: 1.3)),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Get.back(),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: themeColor.shade700,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))
                  ),
                  child: const Text("Mengerti", style: TextStyle(color: Colors.white)),
                ),
              )
            ],
          ),
        ),
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
              child: Icon(Iconsax.battery_empty, size: 50, color: Colors.grey[500]),
            ),
            const SizedBox(height: 24),
            const Text('Perangkat Belum Terhubung',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(
                'Hubungkan perangkat di menu utama untuk melihat status baterai.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey[600])),
          ],
        ),
      ),
    );
  }
}

// --- LIST ITEM WIDGET ---
class BatteryDetailListItem extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String value;
  final VoidCallback onTap;

  const BatteryDetailListItem({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor, size: 22),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          color: Colors.black87, // Lebih gelap agar terbaca
                          fontSize: 15,
                          fontWeight: FontWeight.w600)),
                  const SizedBox(height: 2),
                  Text('Ketuk untuk detail',
                      style: TextStyle(color: Colors.grey[400], fontSize: 11)),
                ],
              ),
            ),
            Text(value,
                style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87)),
            const SizedBox(width: 8),
            Icon(Icons.arrow_forward_ios, color: Colors.grey[300], size: 14),
          ],
        ),
      ),
    );
  }
}