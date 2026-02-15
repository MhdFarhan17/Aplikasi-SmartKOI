import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';

// Imports
import 'package:smartkoi/app/data/models/sensor_data_model.dart';
import 'package:smartkoi/app/features/dashboard/controllers/dashboard_controller.dart';
import 'package:smartkoi/app/shared/utils/sensor_status_util.dart';
import 'package:smartkoi/app/features/sensors/screens/sensor_history_screen.dart';

class SensorsScreen extends StatelessWidget {
  const SensorsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Kita gunakan Get.find karena controller ini sudah hidup di DashboardScreen
    final DashboardController controller = Get.find<DashboardController>();

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F8),
      appBar: AppBar(
        title: const Text(
          'Detail Sensor',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFFF4F7F8),
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false, // Hilangkan tombol back jika ini adalah tab
      ),
      body: Obx(() {
        // 1. Loading State
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        // 2. Empty State (Belum connect)
        if (controller.activeDeviceId.isEmpty) {
          return _buildNotConnectedUI();
        }

        final settings = controller.controlSettings.value;
        final sensorData = controller.sensorData.value;

        // 3. Null Data Check
        if (settings == null || sensorData == null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: 16),
                Text('Menunggu data sensor...', style: TextStyle(color: Colors.grey[600])),
              ],
            ),
          );
        }

        // 4. Hitung Status
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
              // Ringkasan Atas
              _buildSummaryCard(sensorData, suhuStatus, phStatus, tdsStatus,
                  turbidityStatus, kekeruhanStatus),

              const SizedBox(height: 20),

              // Kartu Instruksi
              _buildInstructionCard(),

              const SizedBox(height: 24),

              // Judul Section & Tombol History
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Data Terbaru Sensor',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  _buildHistoryButton(context, controller.activeDeviceId.value),
                ],
              ),
              const SizedBox(height: 16),

              // --- LIST KARTU SENSOR ---

              // 1. SUHU
              SensorDetailListItem(
                icon: Iconsax.sun_1,
                iconBgColor: Colors.orange.shade100,
                iconColor: Colors.orange.shade800,
                title: 'Suhu Air',
                statusText: suhuStatus.text,
                statusColor: suhuStatus.color,
                value: '${sensorData.suhu.toStringAsFixed(1)}°C',
                subValue: 'Limit: ${settings.suhuMin}° - ${settings.suhuMax}°',
                onTap: () => _showSensorInfoDialog(
                  context: context,
                  title: 'Tentang Suhu',
                  icon: Iconsax.sun_1,
                  color: Colors.orange,
                  currentValue: '${sensorData.suhu.toStringAsFixed(1)}°C (${suhuStatus.text})',
                  description: 'Suhu air mempengaruhi metabolisme Koi. Perubahan drastis dapat menyebabkan stres atau penyakit.',
                  recommendation: 'Jaga suhu stabil antara 23°C - 30°C. Gunakan heater/cooler jika suhu sering keluar batas.',
                ),
              ),
              const SizedBox(height: 12),

              // 2. pH
              SensorDetailListItem(
                icon: Iconsax.colorfilter,
                iconBgColor: Colors.green.shade100,
                iconColor: Colors.green.shade800,
                title: 'Derajat Keasaman (pH)',
                statusText: phStatus.text,
                statusColor: phStatus.color,
                value: sensorData.ph.toStringAsFixed(1),
                subValue: 'Limit: ${settings.phMin} - ${settings.phMax}',
                onTap: () => _showSensorInfoDialog(
                  context: context,
                  title: 'Tentang pH',
                  icon: Iconsax.colorfilter,
                  color: Colors.green,
                  currentValue: '${sensorData.ph.toStringAsFixed(1)} (${phStatus.text})',
                  description: 'Menunjukkan seberapa asam atau basa air kolam. Skala 7.0 adalah Netral.',
                  recommendation: 'Koi menyukai pH 6.5 - 8.5. Jika pH rendah (asam), tambahkan buffer kapur/karang jahe. Jika tinggi, lakukan pergantian air.',
                ),
              ),
              const SizedBox(height: 12),

              // 3. TDS
              SensorDetailListItem(
                icon: Iconsax.blend_2,
                iconBgColor: Colors.blue.shade100,
                iconColor: Colors.blue.shade800,
                title: 'Zat Terlarut (TDS)',
                statusText: tdsStatus.text,
                statusColor: tdsStatus.color,
                value: '${sensorData.tds.toStringAsFixed(0)} ppm',
                subValue: 'Maksimal: ${settings.tdsMax} ppm',
                onTap: () => _showSensorInfoDialog(
                  context: context,
                  title: 'Tentang TDS',
                  icon: Iconsax.blend_2,
                  color: Colors.blue,
                  currentValue: '${sensorData.tds.toStringAsFixed(0)} ppm (${tdsStatus.text})',
                  description: 'Total Dissolved Solids. Mengukur jumlah mineral, garam, atau logam terlarut dalam air.',
                  recommendation: 'TDS rendah (< 300 ppm) lebih baik untuk pertumbuhan Koi. TDS tinggi bisa berarti air sudah "tua" dan perlu dikuras sebagian.',
                ),
              ),
              const SizedBox(height: 12),

              // 4. TURBIDITY
              SensorDetailListItem(
                icon: Iconsax.ruler,
                iconBgColor: Colors.purple.shade100,
                iconColor: Colors.purple.shade800,
                title: 'Kekeruhan (Turbidity)',
                statusText: turbidityStatus.text,
                statusColor: turbidityStatus.color,
                value: '${sensorData.turbidity.toStringAsFixed(1)} NTU',
                subValue: 'Maksimal: ${settings.turbidityMax} NTU',
                onTap: () => _showSensorInfoDialog(
                  context: context,
                  title: 'Tentang Kekeruhan',
                  icon: Iconsax.ruler,
                  color: Colors.purple,
                  currentValue: '${sensorData.turbidity.toStringAsFixed(1)} NTU (${turbidityStatus.text})',
                  description: 'Mengukur kejernihan air berdasarkan partikel yang melayang. Semakin rendah NTU, semakin bening.',
                  recommendation: 'Idealnya < 400 NTU. Jika tinggi, periksa sistem filter mekanis Anda atau kurangi pakan berlebih.',
                ),
              ),

              const SizedBox(height: 30),
            ],
          ),
        );
      }),
    );
  }

  // --- WIDGETS ---

  Widget _buildSummaryCard(
      SensorData data,
      SensorStatus suhuStatus,
      SensorStatus phStatus,
      SensorStatus tdsStatus,
      SensorStatus turbidityStatus,
      SensorStatus kekeruhanStatus,
      ) {

    // Logika Keseluruhan
    final bool isNormal = (suhuStatus.text == 'Ideal') &&
        (phStatus.text == 'Netral') &&
        (tdsStatus.text == 'Ideal') &&
        (turbidityStatus.text == 'Jernih') &&
        (kekeruhanStatus.text == 'Jernih');

    final dateTime = DateTime.fromMillisecondsSinceEpoch(data.lastUpdate * 1000);
    final formattedTime = DateFormat('d MMM yyyy, HH:mm').format(dateTime);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 16.0),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: isNormal ? Colors.green.withOpacity(0.1) : Colors.orange.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            )
          ]
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isNormal ? Colors.green.shade50 : Colors.orange.shade50,
              shape: BoxShape.circle,
            ),
            child: Icon(
                isNormal ? Iconsax.shield_tick : Iconsax.warning_2,
                color: isNormal ? Colors.green.shade700 : Colors.orange.shade700,
                size: 40
            ),
          ),
          const SizedBox(height: 16),
          Text(
            isNormal ? 'Kondisi Kolam Optimal' : 'Perlu Perhatian',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Terakhir diperbarui: $formattedTime',
            style: TextStyle(color: Colors.grey[600], fontSize: 13),
          ),
        ],
      ),
    );
  }

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
          Icon(Iconsax.info_circle, color: Colors.blue[700], size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Ketuk pada salah satu kartu sensor di bawah untuk melihat penjelasan detail dan rekomendasi perawatan.',
              style: TextStyle(color: Colors.blue[800], fontSize: 13, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryButton(BuildContext context, String deviceId) {
    return InkWell(
      onTap: () {
        // Navigasi ke History Screen dengan argument deviceId
        Get.to(
              () => const SensorHistoryScreen(),
          arguments: {'deviceId': deviceId},
          transition: Transition.rightToLeft,
        );
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.blue.shade100),
        ),
        child: Row(
          children: [
            Icon(Iconsax.chart_2, size: 16, color: Colors.blue[700]),
            const SizedBox(width: 8),
            Text(
                'Lihat Riwayat',
                style: TextStyle(
                    color: Colors.blue[700],
                    fontWeight: FontWeight.bold,
                    fontSize: 12
                )
            ),
          ],
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
            Icon(Iconsax.link_2, size: 60, color: Colors.grey[400]),
            const SizedBox(height: 16),
            const Text(
              'Tidak Ada Perangkat',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Hubungkan perangkat di menu Beranda untuk melihat data sensor.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  // --- DIALOG INFO ---
  void _showSensorInfoDialog({
    required BuildContext context,
    required String title,
    required IconData icon,
    required MaterialColor color,
    required String currentValue,
    required String description,
    required String recommendation,
  }) {
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
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                        color: color.shade50, shape: BoxShape.circle),
                    child: Icon(icon, color: color.shade700, size: 24),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Nilai Saat Ini
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[200]!)
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Status Saat Ini', style: TextStyle(fontSize: 11, color: Colors.grey[600], fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(currentValue, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
                  ],
                ),
              ),

              const SizedBox(height: 16),
              const Text('Penjelasan', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              const SizedBox(height: 4),
              Text(description, style: TextStyle(color: Colors.grey[700], height: 1.5, fontSize: 13)),

              const SizedBox(height: 16),
              const Text('Rekomendasi', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              const SizedBox(height: 4),
              Text(recommendation, style: TextStyle(color: Colors.grey[700], height: 1.5, fontSize: 13)),

              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Get.back(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: color.shade700,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text("Mengerti"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// --- WIDGET LIST ITEM ---
class SensorDetailListItem extends StatelessWidget {
  final IconData icon;
  final Color iconBgColor;
  final Color iconColor;
  final String title;
  final String? statusText;
  final Color? statusColor;
  final String value;
  final String subValue; // Info tambahan (misal: range limit)
  final VoidCallback onTap;

  const SensorDetailListItem({
    super.key,
    required this.icon,
    required this.iconBgColor,
    required this.iconColor,
    required this.title,
    this.statusText,
    this.statusColor,
    required this.value,
    required this.subValue,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Ikon Kiri
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: iconBgColor,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor, size: 24),
            ),
            const SizedBox(width: 16),

            // Text Tengah
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 15)),
                  const SizedBox(height: 4),
                  if (statusText != null && statusColor != null)
                    Text(
                      statusText!,
                      style: TextStyle(
                          color: statusColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 12),
                    ),
                ],
              ),
            ),

            // Nilai Kanan
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(value,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 18)),
                const SizedBox(height: 4),
                Text(subValue,
                    style: TextStyle(color: Colors.grey[500], fontSize: 11)),
              ],
            ),

            const SizedBox(width: 8),
            Icon(Icons.arrow_forward_ios, size: 12, color: Colors.grey[300]),
          ],
        ),
      ),
    );
  }
}