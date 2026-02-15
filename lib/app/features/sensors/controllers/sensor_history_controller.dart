import 'dart:async';
import 'package:firebase_database/firebase_database.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

// --- MODEL ---
class HistoryEntry {
  final String status;
  final double value;
  final DateTime timestamp;

  HistoryEntry({
    required this.status,
    required this.value,
    required this.timestamp,
  });

  // Getter untuk format tanggal & waktu (untuk UI)
  String get formattedTime => DateFormat('HH:mm').format(timestamp);
  String get formattedDate => DateFormat('d MMM yyyy').format(timestamp);

  factory HistoryEntry.fromMap(Map<dynamic, dynamic> data) {
    // Parsing Timestamp: Mencegah error jika data kosong atau bukan angka
    final rawTimestamp = data['timestamp'];
    int timestampInt = 0;

    if (rawTimestamp is int) {
      timestampInt = rawTimestamp;
    } else if (rawTimestamp is String) {
      timestampInt = int.tryParse(rawTimestamp) ?? 0;
    }

    // Parsing Value: Menangani int dan double
    final rawValue = data['value'];
    double parsedValue = 0.0;

    if (rawValue is num) {
      parsedValue = rawValue.toDouble();
    } else if (rawValue is String) {
      parsedValue = double.tryParse(rawValue) ?? 0.0;
    }

    return HistoryEntry(
      status: data['status'] as String? ?? 'Normal',
      value: parsedValue,
      // Dikali 1000 karena DateTime.fromMillisecondsSinceEpoch butuh milidetik
      // (Asumsi data dari IoT dalam satuan detik/Unix Epoch)
      timestamp: DateTime.fromMillisecondsSinceEpoch(timestampInt * 1000),
    );
  }
}

// --- CONTROLLER ---
class SensorHistoryController extends GetxController {
  final String deviceId;

  SensorHistoryController({required this.deviceId});

  final _dbRef = FirebaseDatabase.instance.ref();

  // Observable Lists
  var suhuHistory = <HistoryEntry>[].obs;
  var phHistory = <HistoryEntry>[].obs;
  var tdsHistory = <HistoryEntry>[].obs;
  var turbidityHistory = <HistoryEntry>[].obs;

  var isLoading = true.obs;
  var selectedSensor = 'Suhu'.obs; // Default tab terpilih

  final List<String> sensorList = ['Suhu', 'pH', 'TDS', 'Turbidity'];
  final List<StreamSubscription> _subscriptions = [];

  @override
  void onInit() {
    super.onInit();
    setupRealtimeListeners();
  }

  @override
  void onClose() {
    // Membatalkan semua stream agar tidak memakan memori saat keluar halaman
    for (var sub in _subscriptions) {
      sub.cancel();
    }
    super.onClose();
  }

  void setupRealtimeListeners() {
    isLoading.value = true;

    // Mulai mendengarkan data dari 4 node history
    _listenToSensor('History_Suhu', suhuHistory);
    _listenToSensor('History_pH', phHistory);
    _listenToSensor('History_TDS', tdsHistory);
    _listenToSensor('History_Turbidity', turbidityHistory);

    // Fallback: Jika dalam 2 detik tidak ada data masuk, matikan loading
    // (Jaga-jaga jika internet lambat atau data kosong)
    Future.delayed(const Duration(seconds: 2), () {
      if (isLoading.value) isLoading.value = false;
    });
  }

  void _listenToSensor(String historyPath, RxList<HistoryEntry> targetList) {
    // Path ke node history di Firebase
    final path = 'Devices/$deviceId/History_Sensors/$historyPath';

    // Ambil 50 data terakhir saja agar ringan
    final stream = _dbRef.child(path).orderByKey().limitToLast(50).onValue;

    final subscription = stream.listen((event) {
      final snapshot = event.snapshot;

      if (snapshot.exists && snapshot.value != null) {
        try {
          // Konversi Map<dynamic, dynamic> dari Firebase
          final dataMap = snapshot.value as Map<dynamic, dynamic>;

          final entries = dataMap.entries.map((entry) {
            final val = entry.value as Map<dynamic, dynamic>;
            return HistoryEntry.fromMap(val);
          }).toList();

          // SORTING:
          // Untuk List View: Urutkan dari yang TERBARU ke TERLAMA (Descending)
          entries.sort((a, b) => b.timestamp.compareTo(a.timestamp));

          targetList.value = entries;
        } catch (e) {
          print("Error parsing data for $historyPath: $e");
        }
      } else {
        targetList.clear();
      }

      // Matikan loading saat data pertama berhasil diterima
      if (isLoading.value) isLoading.value = false;

    }, onError: (error) {
      print("Stream Error $historyPath: $error");
      if (isLoading.value) isLoading.value = false;
    });

    _subscriptions.add(subscription);
  }

  // --- GETTERS UNTUK UI ---

  /// Mengambil list history berdasarkan tab yang dipilih
  List<HistoryEntry> get activeHistoryList {
    switch (selectedSensor.value) {
      case 'pH': return phHistory;
      case 'TDS': return tdsHistory;
      case 'Turbidity': return turbidityHistory;
      case 'Suhu': default: return suhuHistory;
    }
  }

  /// Mengambil satuan unit berdasarkan tab yang dipilih
  String get activeSensorUnit {
    switch (selectedSensor.value) {
      case 'pH': return '';
      case 'TDS': return 'ppm';
      case 'Turbidity': return 'NTU';
      case 'Suhu': default: return '°C';
    }
  }

  /// Data untuk Grafik (Chart)
  /// Grafik biasanya butuh urutan dari KIRI (Lama) ke KANAN (Baru).
  /// Karena `activeHistoryList` sudah di-sort Descending (Baru -> Lama),
  /// kita perlu me-reverse-nya.
  List<HistoryEntry> get activeChartData => activeHistoryList.reversed.toList();
}