import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'firebase_options.dart';
import 'package:smartkoi/app/features/authentication/screens/welcome_screen.dart';
import 'package:smartkoi/app/features/dashboard/screens/dashboard_screen.dart';
import 'package:smartkoi/app/features/dashboard/controllers/dashboard_controller.dart';
import 'package:smartkoi/app/features/device/devices_controller.dart';
import 'package:smartkoi/app/shared/utils/notification_helper.dart';
import 'package:smartkoi/app/features/authentication/controllers/auth_binding.dart';
// Pastikan file auth_binding.dart sudah ada atau hapus baris ini jika belum dibuat.

// Handler untuk notifikasi saat aplikasi ditutup/background
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  print("🌙 Notifikasi masuk saat aplikasi tertutup: ${message.messageId}");
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Inisialisasi Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // 2. Inisialisasi Penyimpanan Lokal
  await GetStorage.init();

  // 3. Inisialisasi Notifikasi
  await NotificationHelper.initialize();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // 4. Atur Orientasi & Status Bar (Estetika)
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent, // Transparan agar menyatu dengan background
    statusBarIconBrightness: Brightness.dark, // Ikon status bar gelap
  ));

  // 5. Cek Status Login
  final String initialRoute =
  FirebaseAuth.instance.currentUser == null ? '/welcome' : '/dashboard';

  runApp(MyApp(initialRoute: initialRoute));
}

class MyApp extends StatelessWidget {
  final String initialRoute;
  const MyApp({super.key, required this.initialRoute});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Smart KOI',

      // --- TEMA APLIKASI ---
      theme: ThemeData(
        fontFamily: GoogleFonts.inter().fontFamily,
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          primary: Colors.blue[800],
        ),
        scaffoldBackgroundColor: const Color(0xFFF4F7F8),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFF4F7F8),
          surfaceTintColor: Colors.transparent,
        ),
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          backgroundColor: Colors.white,
          selectedItemColor: Colors.blue[800],
          unselectedItemColor: Colors.grey[500],
          showUnselectedLabels: true,
          type: BottomNavigationBarType.fixed,
          elevation: 8,
        ),
      ),

      // Binding awal (misal AuthController)
      initialBinding: AuthBinding(),

      // --- PENGATURAN ROUTE ---
      initialRoute: initialRoute,
      getPages: [
        GetPage(
          name: '/welcome',
          page: () => const WelcomeScreen(),
          transition: Transition.fadeIn,
        ),
        GetPage(
          name: '/dashboard',
          page: () => const DashboardScreen(),
          binding: DashboardBinding(),
          transition: Transition.fadeIn,
        ),
      ],
    );
  }
}

// --- BINDING KHUSUS DASHBOARD ---
// Menginisialisasi Controller penting saat masuk ke Dashboard
class DashboardBinding extends Bindings {
  @override
  void dependencies() {
    // LazyPut: Controller hanya dibuat saat dibutuhkan, dan dihapus saat keluar
    Get.lazyPut<DashboardController>(() => DashboardController());
    Get.lazyPut<DevicesController>(() => DevicesController());
  }
}