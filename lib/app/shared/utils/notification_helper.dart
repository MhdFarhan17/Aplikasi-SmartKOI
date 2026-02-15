import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';

// Imports Halaman
import 'package:smartkoi/app/features/dashboard/screens/dashboard_screen.dart';
import 'package:smartkoi/app/features/battery/screen/battery_screen.dart';

class NotificationHelper {
  static final FlutterLocalNotificationsPlugin _localNotifications =
  FlutterLocalNotificationsPlugin();
  static final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  // --- CHANNEL DEFINITIONS ---
  static const AndroidNotificationChannel _criticalChannel =
  AndroidNotificationChannel(
    'critical_alerts',
    'Peringatan Kritis',
    description: 'Notifikasi prioritas tinggi (Suhu, pH, Listrik padam).',
    importance: Importance.max,
    playSound: true,
    // Menggunakan suara default sistem agar aman jika file custom tidak ada
    // Jika ingin custom, pastikan file ada di android/app/src/main/res/raw/
  );

  static const AndroidNotificationChannel _infoChannel =
  AndroidNotificationChannel(
    'info_alerts',
    'Info Umum',
    description: 'Notifikasi informatif umum.',
    importance: Importance.defaultImportance,
    playSound: true,
  );

  static bool _isInitialized = false;

  static Future<void> initialize() async {
    if (_isInitialized) return;

    // 1. Minta Izin Notifikasi (Wajib untuk Android 13+)
    await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    // 2. Setup Local Notifications (Android)
    // Gunakan @mipmap/ic_launcher agar menggunakan ikon aplikasi default
    // Jika punya ikon khusus transparan, ganti jadi 'ic_notification'
    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
    InitializationSettings(android: initializationSettingsAndroid);

    // 3. Inisialisasi Plugin & Handler Ketukan (Tap)
    await _localNotifications.initialize(
      initializationSettings,
      // Handler saat notifikasi lokal (Foreground) diklik
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        if (response.payload != null) {
          try {
            final data = jsonDecode(response.payload!);
            _handleNavigation(data);
          } catch (e) {
            print("Error parsing notification payload: $e");
          }
        }
      },
    );

    // 4. Buat Channel di Android System
    final androidImplementation =
    _localNotifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    await androidImplementation?.createNotificationChannel(_criticalChannel);
    await androidImplementation?.createNotificationChannel(_infoChannel);

    // 5. Konfigurasi Foreground Firebase (Agar tidak double notif dari Firebase sendiri)
    // Kita set false, karena kita akan menampilkannya manual lewat LocalNotification
    await _firebaseMessaging.setForegroundNotificationPresentationOptions(
      alert: false,
      badge: true,
      sound: true,
    );

    // 6. Listener: Saat ada pesan masuk ketika aplikasi TERBUKA
    FirebaseMessaging.onMessage.listen(_showNotification);

    // 7. Listener: Saat notifikasi diklik dari BACKGROUND
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      _handleNavigation(message.data);
    });

    // 8. Listener: Saat aplikasi dibuka dari notifikasi (Terminated State)
    _firebaseMessaging.getInitialMessage().then((RemoteMessage? message) {
      if (message != null) {
        Future.delayed(const Duration(milliseconds: 500), () {
          _handleNavigation(message.data);
        });
      }
    });

    _isInitialized = true;
    print("✅ Notification Helper Initialized");
  }

  // --- LOGIKA NAVIGASI TERPUSAT ---
  static void _handleNavigation(Map<String, dynamic> data) {
    final String? target = data['navigation_target']; // key dari backend
    final String? deviceId = data['deviceId'];

    print("🔔 Notification Tapped! Target: $target, DeviceID: $deviceId");

    if (target == 'battery') {
      // Ke Layar Baterai
      Get.to(() => const BatteryScreen(), arguments: {'deviceId': deviceId});
    } else if (target == 'dashboard' || target == 'sensor') {
      // Ke Dashboard (Bisa diarahin ke tab sensor kalau mau logic lebih lanjut)
      Get.offAll(() => const DashboardScreen());
    } else {
      // Default: Buka Dashboard saja
      Get.offAll(() => const DashboardScreen());
    }
  }

  // --- MENAMPILKAN NOTIFIKASI LOKAL ---
  static void _showNotification(RemoteMessage message) {
    RemoteNotification? notification = message.notification;
    AndroidNotification? android = message.notification?.android;
    Map<String, dynamic> data = message.data;

    // Jika notifikasi valid
    if (notification != null && android != null) {
      // Tentukan channel berdasarkan data dari backend atau default
      final String channelId = message.data['channel_id'] ?? 'info_alerts';

      AndroidNotificationChannel channel;
      if (channelId == 'critical_alerts') {
        channel = _criticalChannel;
      } else {
        channel = _infoChannel;
      }

      _localNotifications.show(
        notification.hashCode,
        notification.title ?? 'Notifikasi SmartKOI',
        notification.body ?? 'Ada pembaruan status.',
        NotificationDetails(
          android: AndroidNotificationDetails(
            channel.id,
            channel.name,
            channelDescription: channel.description,
            icon: '@mipmap/ic_launcher', // Ikon Default
            importance: channel.importance,
            priority: Priority.high,
            color: const Color(0xFF1565C0), // Warna aksen (Biru)
            styleInformation: const BigTextStyleInformation(''), // Agar teks panjang bisa terbaca
          ),
        ),
        // PENTING: Kirim data sebagai payload agar bisa dinavigasikan saat diklik
        payload: jsonEncode(data),
      );
    }
  }
}