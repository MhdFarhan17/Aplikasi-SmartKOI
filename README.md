# Aplikasi SmartKOI berbasis Android 🐟

Aplikasi Android berbasis Flutter untuk memonitoring kualitas air dan sistem daya cadangan (Backup Power) pada akuarium ikan Koi secara *real-time* menggunakan teknologi IoT. 

Aplikasi ini terhubung langsung dengan perangkat keras IoT dan memberikan informasi krusial serta notifikasi cerdas untuk memastikan lingkungan hidup ikan Koi tetap ideal, bahkan saat terjadi pemadaman listrik PLN.

## ✨ Fitur Utama

* **Manajemen Multi-Perangkat:** Tambah dan kelola berbagai perangkat IoT akuarium secara bersamaan menggunakan ID unik (contoh: `KOI001`).
* **Monitoring Kualitas Air (Real-time):** Pantau parameter air secara langsung meliputi Suhu, pH, TDS, dan Kekeruhan (*Turbidity*).
* **Pemantauan Baterai & Daya Cadangan:** Pantau status kelistrikan sistem *backup*, termasuk *State of Charge* (SoC %), Arus masuk/keluar, Tegangan, dan Kapasitas Baterai (Ah).
* **Sistem Notifikasi Pintar (Push Notifications):**
  * **Peringatan Kritis:** Notifikasi otomatis jika parameter air melewati batas ideal (misal: Suhu > 30°C).
  * **Peringatan Listrik:** Notifikasi transisi daya, seperti saat listrik PLN mati (status berubah menjadi *discharging*) dan saat listrik kembali normal.
* **Riwayat Data (History):** Akses data historis dari seluruh sensor untuk analisis jangka panjang.
* **Autentikasi Pengguna yang Aman:** Dilengkapi fitur *Sign Up*, *Login*, *Forgot Password*, dan Manajemen Profil (Ubah Nama & Password).

## 🛠️ Teknologi yang Digunakan

* **Framework:** Flutter
* **Platform Target:** Android
* **Backend & Database:** Firebase Realtime Database
* **Autentikasi:** Firebase Authentication
* **Notifikasi:** Firebase Cloud Messaging (FCM)
* **Monitoring Kinerja:** Firebase Performance Monitoring

## 🗄️ Struktur Database (Firebase Realtime Database)

Aplikasi ini membaca dan menulis data ke Firebase dengan struktur *path* berikut:
* `Devices/{Device_ID}/realtime`: Menyimpan data sensor kualitas air secara *real-time*.
* `Devices/{Device_ID}/Battery`: Menyimpan informasi detail terkait baterai dan daya cadangan.
* `History_Sensors`: Menyimpan log atau riwayat pergerakan data sensor (Suhu, pH, TDS, Turbidity).

## 🚀 Cara Menjalankan Project (Instalasi Lokal)

Karena ini menggunakan Firebase, kamu memerlukan file konfigurasi kredensial agar aplikasi bisa berjalan.

1. **Clone repository ini**
   ```bash
   git clone [https://github.com/username_kamu/smartkoi.git](https://github.com/username_kamu/smartkoi.git)
