import 'dart:async';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// Model data untuk log
class LogItem {
  final String dataPreview;
  final DateTime serverTime; // Waktu dari ESP32/Firebase
  final DateTime appReceiveTime; // Waktu diterima di HP
  final int latencyMs; // Selisih

  LogItem({
    required this.dataPreview,
    required this.serverTime,
    required this.appReceiveTime,
    required this.latencyMs,
  });
}

class RealtimeDebugConsole extends StatefulWidget {
  final String deviceId;
  const RealtimeDebugConsole({super.key, required this.deviceId});

  @override
  State<RealtimeDebugConsole> createState() => _RealtimeDebugConsoleState();
}

class _RealtimeDebugConsoleState extends State<RealtimeDebugConsole> {
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref();
  final List<LogItem> _logs = [];
  StreamSubscription? _subscription;
  final ScrollController _scrollController = ScrollController();
  bool _isExpanded = false; // Default tertutup

  @override
  void initState() {
    super.initState();
    _startListening();
  }

  void _startListening() {
    // Mendengarkan path spesifik device
    final path = 'Devices/${widget.deviceId}/SensorData';

    _subscription = _dbRef.child(path).onValue.listen((event) {
      if (event.snapshot.value == null) return;

      final now = DateTime.now(); // Waktu HP saat ini

      try {
        final data = Map<String, dynamic>.from(event.snapshot.value as Map);

        // 1. Ambil preview data (misal Suhu)
        final suhu = data['suhu'] ?? 0;
        final ph = data['ph'] ?? 0;

        // 2. Olah Timestamp (last_update)
        // Logika untuk menangani Detik (10 digit) vs Milidetik (13 digit)
        int serverTimestamp = 0;
        if (data['last_update'] != null) {
          num rawTime = data['last_update'];
          // Jika digit <= 10, berarti DETIK (seperti data kamu: 1770209552)
          if (rawTime.toString().length <= 10) {
            serverTimestamp = (rawTime * 1000).toInt();
          } else {
            serverTimestamp = rawTime.toInt();
          }
        } else {
          // Fallback jika tidak ada last_update
          serverTimestamp = now.millisecondsSinceEpoch;
        }

        final serverTime = DateTime.fromMillisecondsSinceEpoch(serverTimestamp);

        // 3. Hitung Latency
        final latency = now.difference(serverTime).inMilliseconds;

        final newLog = LogItem(
          dataPreview: "Suhu: $suhu | pH: $ph",
          serverTime: serverTime,
          appReceiveTime: now,
          latencyMs: latency,
        );

        if (mounted) {
          setState(() {
            _logs.insert(0, newLog); // Masukkan ke paling atas
            if (_logs.length > 50) _logs.removeLast(); // Batasi 50 log
          });
        }
      } catch (e) {
        print("Error parsing debug data: $e");
      }
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Material(
        color: Colors.transparent,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // --- HEADER / TOMBOL TOGGLE ---
            InkWell(
              onTap: () => setState(() => _isExpanded = !_isExpanded),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.black87,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                  boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, -2))],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.terminal, color: Colors.greenAccent, size: 18),
                        SizedBox(width: 8),
                        Text(
                          "Live Debug Monitor",
                          style: TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold, fontFamily: 'monospace'),
                        ),
                      ],
                    ),
                    Icon(
                      _isExpanded ? Icons.keyboard_arrow_down : Icons.keyboard_arrow_up,
                      color: Colors.white70,
                    )
                  ],
                ),
              ),
            ),

            // --- ISI CONSOLE ---
            if (_isExpanded)
              Container(
                height: 250,
                color: const Color(0xFF1E1E1E), // Hitam Terminal
                child: ListView.separated(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(8),
                  itemCount: _logs.length,
                  separatorBuilder: (_, __) => const Divider(color: Colors.white12, height: 1),
                  itemBuilder: (context, index) {
                    final log = _logs[index];
                    final fmt = DateFormat('HH:mm:ss');

                    // Warna indikator latency
                    Color latencyColor = Colors.greenAccent;
                    if (log.latencyMs > 3000) latencyColor = Colors.orangeAccent; // > 3 detik
                    if (log.latencyMs > 10000) latencyColor = Colors.redAccent;   // > 10 detik

                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("RX(App): ${fmt.format(log.appReceiveTime)}",
                                  style: const TextStyle(color: Colors.white, fontSize: 12, fontFamily: 'monospace')),
                              Text("${log.latencyMs} ms",
                                  style: TextStyle(color: latencyColor, fontSize: 12, fontWeight: FontWeight.bold, fontFamily: 'monospace')),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              Text("TX(IoT): ${fmt.format(log.serverTime)}",
                                  style: TextStyle(color: Colors.grey[500], fontSize: 11, fontFamily: 'monospace')),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(log.dataPreview,
                                    style: const TextStyle(color: Colors.blueAccent, fontSize: 11, fontFamily: 'monospace'), overflow: TextOverflow.ellipsis),
                              ),
                            ],
                          )
                        ],
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}