import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:smartkoi/app/features/sensors/controllers/sensor_history_controller.dart';

class SensorHistoryScreen extends StatelessWidget {
  const SensorHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final String deviceId = Get.arguments['deviceId'] as String? ?? '';

    // PENTING: Gunakan 'tag' agar controller unik per device ID
    // Jika user buka history Device A lalu Device B, datanya tidak tertukar
    final SensorHistoryController controller = Get.put(
      SensorHistoryController(deviceId: deviceId),
      tag: deviceId,
    );

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F8),
      appBar: AppBar(
        title: const Text(
          'History Sensor',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFFF4F7F8),
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            // Hapus controller dari memori saat kembali agar hemat RAM
            Get.delete<SensorHistoryController>(tag: deviceId);
            Get.back();
          },
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        // Cek jika semua history kosong (Data baru)
        if (controller.activeHistoryList.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.1),
                      shape: BoxShape.circle
                  ),
                  child: Icon(Iconsax.chart_fail, size: 50, color: Colors.grey[400]),
                ),
                const SizedBox(height: 16),
                Text(
                  'Belum ada data history.',
                  style: TextStyle(fontSize: 16, color: Colors.grey[500]),
                ),
              ],
            ),
          );
        }

        // --- Persiapan Data Grafik ---
        final chartDataList = controller.activeChartData;
        final spots = <FlSpot>[];

        double minY = double.maxFinite;
        double maxY = double.negativeInfinity;

        for (var i = 0; i < chartDataList.length; i++) {
          final value = chartDataList[i].value;
          spots.add(FlSpot(i.toDouble(), value));
          if (value < minY) minY = value;
          if (value > maxY) maxY = value;
        }

        // Handling jika grafik datar (Nilai konstan)
        if (minY == maxY) {
          minY -= 1.0; // Beri ruang bawah
          maxY += 1.0; // Beri ruang atas
        }

        // Margin agar grafik tidak mentok atas/bawah
        double yMargin = (maxY - minY) * 0.1;
        if (yMargin == 0) yMargin = 1.0;

        minY = (minY - yMargin);
        maxY = (maxY + yMargin);

        // Interval Grid Y
        final double yInterval = (maxY - minY) / 4;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. DROPDOWN SELECTOR
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Iconsax.info_circle, size: 14, color: Colors.blue[700]),
                      const SizedBox(width: 6),
                      Text(
                        'Pilih parameter sensor:',
                        style: TextStyle(
                          color: Colors.blue[700],
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.blue.shade100),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.blue.withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 4))
                        ]),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: controller.selectedSensor.value,
                        isExpanded: true,
                        icon: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                              color: Colors.blue[50], shape: BoxShape.circle),
                          child: Icon(Iconsax.arrow_down_1,
                              size: 18, color: Colors.blue[700]),
                        ),
                        items: controller.sensorList.map((String sensor) {
                          return DropdownMenuItem<String>(
                            value: sensor,
                            child: Row(
                              children: [
                                Icon(_getSensorIcon(sensor),
                                    color: Colors.blue[700], size: 20),
                                const SizedBox(width: 12),
                                Text(
                                  sensor,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold, fontSize: 15),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          if (newValue != null) {
                            controller.selectedSensor.value = newValue;
                          }
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // 2. GRAFIK (LINE CHART)
            SizedBox(
              height: 280,
              child: Padding(
                padding: const EdgeInsets.only(right: 24.0, left: 12.0),
                child: LineChart(
                  LineChartData(
                    // Interaksi Sentuh & Tooltip
                    lineTouchData: LineTouchData(
                      handleBuiltInTouches: true,
                      touchTooltipData: LineTouchTooltipData(
                        getTooltipColor: (touchedSpot) => Colors.blueGrey.shade900,
                        tooltipRoundedRadius: 8,
                        tooltipPadding: const EdgeInsets.all(12),
                        getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
                          return touchedBarSpots.map((barSpot) {
                            final index = barSpot.x.toInt();
                            if (index >= 0 && index < chartDataList.length) {
                              final entry = chartDataList[index];
                              return LineTooltipItem(
                                '${entry.value} ${controller.activeSensorUnit}\n',
                                const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                                children: [
                                  TextSpan(
                                    text: '${entry.formattedDate}\n${entry.formattedTime}',
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.8),
                                      fontSize: 10,
                                      fontWeight: FontWeight.normal,
                                    ),
                                  ),
                                ],
                              );
                            }
                            return null;
                          }).toList();
                        },
                      ),
                    ),

                    // Grid Latar Belakang
                    gridData: FlGridData(
                      show: true,
                      drawVerticalLine: true,
                      drawHorizontalLine: true,
                      getDrawingHorizontalLine: (value) => FlLine(
                        color: Colors.grey.shade300,
                        strokeWidth: 1,
                        dashArray: [5, 5],
                      ),
                      getDrawingVerticalLine: (value) => FlLine(
                        color: Colors.grey.shade200,
                        strokeWidth: 1,
                      ),
                    ),

                    // Label Sumbu (Axis)
                    titlesData: FlTitlesData(
                      // KIRI (Y-Axis)
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 40,
                          interval: yInterval > 0 ? yInterval : 1,
                          getTitlesWidget: (value, meta) {
                            return Text(
                              value.toStringAsFixed(1),
                              style: TextStyle(color: Colors.grey[600], fontSize: 10),
                            );
                          },
                        ),
                      ),
                      // BAWAH (X-Axis / Waktu)
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 30,
                          interval: 1, // Cek setiap titik
                          getTitlesWidget: (value, meta) {
                            final index = value.toInt();
                            // Tampilkan label hanya di Awal, Tengah, dan Akhir agar tidak tumpang tindih
                            if (index == 0 ||
                                index == chartDataList.length - 1 ||
                                index == (chartDataList.length / 2).round()) {
                              if (index < chartDataList.length) {
                                return Padding(
                                  padding: const EdgeInsets.only(top: 8.0),
                                  child: Text(
                                    chartDataList[index].formattedTime,
                                    style: TextStyle(color: Colors.grey[600], fontSize: 10),
                                  ),
                                );
                              }
                            }
                            return const SizedBox.shrink();
                          },
                        ),
                      ),
                      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    ),

                    borderData: FlBorderData(show: false),
                    minY: minY,
                    maxY: maxY,
                    minX: 0,
                    maxX: (chartDataList.length - 1).toDouble(),

                    // Data Garis
                    lineBarsData: [
                      LineChartBarData(
                        spots: spots,
                        isCurved: true,
                        curveSmoothness: 0.2, // Sedikit lengkung
                        color: Colors.blue[700],
                        barWidth: 3,
                        isStrokeCapRound: true,
                        dotData: FlDotData(show: false), // Sembunyikan dot agar bersih
                        belowBarData: BarAreaData(
                          show: true,
                          gradient: LinearGradient(
                            colors: [
                              Colors.blue[700]!.withOpacity(0.2),
                              Colors.blue[700]!.withOpacity(0.0),
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // 3. HEADER LIST
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Riwayat Data (${controller.activeHistoryList.length})',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Text('Terbaru di atas',
                            style: TextStyle(fontSize: 10, color: Colors.grey[600])),
                        const SizedBox(width: 4),
                        Icon(Icons.arrow_upward, size: 10, color: Colors.grey[600]),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // 4. LIST DATA
            Expanded(
              child: Container(
                color: Colors.white,
                child: ListView.separated(
                  padding: const EdgeInsets.only(bottom: 20, top: 0),
                  itemCount: controller.activeHistoryList.length,
                  separatorBuilder: (context, index) =>
                      Divider(height: 1, indent: 56, endIndent: 16, color: Colors.grey[100]),
                  itemBuilder: (context, index) {
                    final entry = controller.activeHistoryList[index];

                    // Tentukan warna status
                    Color statusColor = Colors.grey;
                    final statusText = entry.status.toLowerCase();
                    if (statusText.contains('ideal') ||
                        statusText.contains('normal') ||
                        statusText.contains('jernih') ||
                        statusText.contains('netral')) {
                      statusColor = Colors.green;
                    } else if (statusText.contains('bahaya') || statusText.contains('kotor')) {
                      statusColor = Colors.red;
                    } else {
                      statusColor = Colors.orange;
                    }

                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                      leading: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.blue[50],
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                            _getSensorIcon(controller.selectedSensor.value),
                            color: Colors.blue[700],
                            size: 22),
                      ),
                      title: Text(
                        '${entry.value} ${controller.activeSensorUnit}',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      subtitle: Row(
                        children: [
                          Icon(Icons.access_time, size: 12, color: Colors.grey[500]),
                          const SizedBox(width: 4),
                          Text(
                            "${entry.formattedDate}, ${entry.formattedTime}",
                            style: TextStyle(color: Colors.grey[600], fontSize: 12),
                          ),
                        ],
                      ),
                      trailing: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                            color: statusColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: statusColor.withOpacity(0.2))
                        ),
                        child: Text(
                          entry.status,
                          style: TextStyle(
                              fontSize: 12,
                              color: statusColor,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  IconData _getSensorIcon(String sensorType) {
    switch (sensorType) {
      case 'Suhu': return Iconsax.sun_1;
      case 'pH': return Iconsax.colorfilter;
      case 'TDS': return Iconsax.blend_2;
      case 'Turbidity': return Iconsax.ruler;
      default: return Iconsax.chart;
    }
  }
}