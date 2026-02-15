import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

enum AlertType { success, error, warning }

class CustomAlert {
  /// Menampilkan Alert/Snackbar kustom
  static void show(AlertType type, String title, String message) {
    // Menutup snackbar sebelumnya jika masih tampil agar tidak menumpuk
    if (Get.isSnackbarOpen) {
      Get.closeCurrentSnackbar();
    }

    Color backgroundColor;
    Color borderColor;
    Color iconColor;
    IconData icon;

    // Menentukan warna dan ikon berdasarkan tipe alert
    switch (type) {
      case AlertType.success:
        backgroundColor = Colors.green.shade50;
        borderColor = Colors.green.shade300;
        iconColor = Colors.green.shade700;
        icon = Iconsax.tick_circle;
        break;
      case AlertType.error:
        backgroundColor = Colors.red.shade50;
        borderColor = Colors.red.shade300;
        iconColor = Colors.red.shade700;
        icon = Iconsax.danger;
        break;
      case AlertType.warning:
        backgroundColor = Colors.orange.shade50;
        borderColor = Colors.orange.shade300;
        iconColor = Colors.orange.shade700;
        icon = Iconsax.warning_2;
        break;
    }

    Get.rawSnackbar(
      // Properti Kontainer Utama
      backgroundColor: backgroundColor,
      margin: const EdgeInsets.all(16),
      borderRadius: 16,
      borderWidth: 2,
      borderColor: borderColor,

      // Konten Snackbar
      messageText: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2.0, vertical: 0.4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. IKON
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: iconColor.withOpacity(0.2),
              ),
              child: Icon(icon, color: iconColor, size: 24),
            ),

            const SizedBox(width: 16.0),

            // 2. TEKS (Judul & Pesan)
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.black87,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      decoration: TextDecoration.none,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    message,
                    style: TextStyle(
                      color: Colors.grey[700],
                      fontSize: 14,
                      height: 1.3,
                      decoration: TextDecoration.none,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            const SizedBox(width: 4.0),

            // 3. TOMBOL TUTUP MANUAL
            InkWell(
              onTap: () => Get.closeCurrentSnackbar(),
              child: Padding(
                padding: const EdgeInsets.all(2.0),
                child: Icon(
                  Icons.close,
                  color: Colors.grey[600],
                  size: 20,
                ),
              ),
            ),
          ],
        ),
      ),

      // Konfigurasi Snackbar
      duration: const Duration(seconds: 4),
      snackPosition: SnackPosition.TOP,
      isDismissible: true,
      onTap: (_) => Get.closeCurrentSnackbar(),
    );
  }
}