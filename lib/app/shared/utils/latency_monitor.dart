import 'dart:async';
import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';

class LatencyMonitor {
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref();

  // Kita butuh 2 subscription karena memantau 2 folder berbeda
  StreamSubscription? _realtimeSub;
  StreamSubscription? _batterySub;

  // Menyimpan nilai sebelumnya untuk mendeteksi perubahan (Change Detection)
  Map<String, dynamic> _prevValues = {};

  void startMonitoring(String deviceId) {
    stopMonitoring(); // Reset dulu biar bersih

    print("\n========================================================");
    print("🚀 ADVANCED MONITORING STARTED (DEVICE: $deviceId)");
    print("   Tracking: Realtime Sensors & Battery Status");
    print("========================================================\n");

    // ---------------------------------------------------------
    // 1. MONITORING SENSOR REALTIME (Suhu, pH, TDS, dll)
    // ---------------------------------------------------------
    final sensorPath = 'Devices/$deviceId/realtime';

    _realtimeSub = _dbRef.child(sensorPath).onValue.listen((event) {
      if (event.snapshot.value == null) return;

      try {
        final data = Map<String, dynamic>.from(event.snapshot.value as Map);
        final now = DateTime.now();

        // --- A. Hitung Latency (Wajib ada last_update) ---
        int latencyMs = 0;
        DateTime? serverTime;

        if (data['last_update'] != null) {
          num rawTime = data['last_update'];
          int serverTimestamp = (rawTime.toString().length <= 10)
              ? (rawTime * 1000).toInt() // Convert detik ke ms
              : rawTime.toInt();

          serverTime = DateTime.fromMillisecondsSinceEpoch(serverTimestamp);
          latencyMs = now.difference(serverTime).inMilliseconds.abs(); // Pakai ABS biar positif
        }

        // --- B. Deteksi Perubahan Data (Complex Logic) ---
        // Kita bandingkan data baru dengan data lama (_prevValues)
        List<String> changes = [];

        _checkChange(changes, 'Suhu', data['suhu'], '°C');
        _checkChange(changes, 'pH', data['ph'], '');
        _checkChange(changes, 'TDS', data['tds'], 'ppm');
        _checkChange(changes, 'Turbidity', data['turbidity'], 'NTU');
        _checkChange(changes, 'Heater', data['status_heater'], '');
        _checkChange(changes, 'Cooler', data['status_cooler'], '');

        // --- C. Format Output ---
        final fmt = DateFormat('HH:mm:ss.SSS');
        String statusLatency = latencyMs > 2000 ? "[SLOW ⚠️]" : "[FAST ⚡]";

        // Hanya print jika ada perubahan data ATAU ini data pertama kali
        if (changes.isNotEmpty || _prevValues.isEmpty) {
          print(
              "📡 SENSOR STREAM ➔ RX: ${fmt.format(now)} | "
                  "LATENCY: ${latencyMs}ms $statusLatency"
          );

          if (changes.isNotEmpty) {
            for (var change in changes) {
              print("   └─ 🔔 CHANGE: $change");
            }
          } else {
            print("   └─ (Inisialisasi Data Awal..)");
          }
          print("--------------------------------------------------------");
        }

        // Simpan data sekarang sebagai data lama untuk loop berikutnya
        _updatePrevValues(data);

      } catch (e) {
        print("❌ Error Sensor Monitor: $e");
      }
    });

    // ---------------------------------------------------------
    // 2. MONITORING BATTERY (Status Only)
    // ---------------------------------------------------------
    final batteryPath = 'Devices/$deviceId/Battery';

    _batterySub = _dbRef.child(batteryPath).onValue.listen((event) {
      if (event.snapshot.value == null) return;

      try {
        final data = Map<String, dynamic>.from(event.snapshot.value as Map);
        final newStatus = data['Status'] ?? 'Unknown';
        final oldStatus = _prevValues['battery_status'] ?? 'Init';

        // Khusus baterai, kita print kalau statusnya berubah aja
        if (newStatus != oldStatus) {
          print("🔋 BATTERY EVENT ➔ Status Berubah: '$oldStatus' ➔ '$newStatus'");
          _prevValues['battery_status'] = newStatus;
        }
      } catch (e) {
        // Silent error handling for battery structure differences
      }
    });
  }

  // Helper untuk membandingkan nilai lama vs baru
  void _checkChange(List<String> logs, String key, dynamic newValue, String unit) {
    // Kunci unik untuk map prevValues (misal: 'prev_Suhu')
    final storageKey = 'prev_$key';
    final oldValue = _prevValues[storageKey];

    // Jika nilai berubah dan bukan null
    if (oldValue != null && oldValue != newValue) {
      logs.add("$key: $oldValue ➔ $newValue $unit");
    }

    // Update nilai disimpan nanti di _updatePrevValues
  }

  void _updatePrevValues(Map<String, dynamic> data) {
    _prevValues['prev_Suhu'] = data['suhu'];
    _prevValues['prev_pH'] = data['ph'];
    _prevValues['prev_TDS'] = data['tds'];
    _prevValues['prev_Turbidity'] = data['turbidity'];
    _prevValues['prev_Heater'] = data['status_heater'];
    _prevValues['prev_Cooler'] = data['status_cooler'];
  }

  void stopMonitoring() {
    _realtimeSub?.cancel();
    _batterySub?.cancel();
    _prevValues.clear();
    print("\n🛑 MONITORING BERHENTI\n");
  }
}