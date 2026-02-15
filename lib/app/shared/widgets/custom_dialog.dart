// lib/app/shared/widgets/custom_dialog.dart

import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

class CustomSuccessDialog extends StatelessWidget {
  final String title;
  final Widget content;
  final VoidCallback onOkPressed;

  const CustomSuccessDialog({
    super.key,
    required this.title,
    required this.content,
    required this.onOkPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
      ),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(24.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 5),
            )
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min, // Agar tinggi dialog menyesuaikan konten
          children: [
            // Ikon Sukses
            CircleAvatar(
              radius: 32,
              backgroundColor: Colors.green[100],
              child: const Icon(Iconsax.tick_circle, color: Colors.green, size: 36),
            ),
            const SizedBox(height: 20),

            // Judul
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            // Konten/Pesan
            // Flexible memastikan jika konten panjang, tidak error overflow
            Flexible(
              child: SingleChildScrollView(
                child: content,
              ),
            ),
            const SizedBox(height: 24),

            // Tombol OK
            ElevatedButton(
              onPressed: onOkPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[700],
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Mengerti', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}

class CustomActionDialog extends StatelessWidget {
  final String title;
  final Widget content;
  final List<Widget> actions;

  const CustomActionDialog({
    super.key,
    required this.title,
    required this.content,
    required this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
      ),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20.0),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Judul
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            // Konten (misalnya: TextField)
            // REVISI: Dibungkus Flexible & SingleChildScrollView agar aman dari Keyboard
            Flexible(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: content,
              ),
            ),

            const SizedBox(height: 24),

            // Area Tombol Aksi
            OverflowBar(
              alignment: MainAxisAlignment.end,
              spacing: 8, // Jarak horizontal antar tombol
              overflowSpacing: 8, // Jarak vertikal jika tombol turun ke bawah
              children: actions,
            ),
          ],
        ),
      ),
    );
  }
}