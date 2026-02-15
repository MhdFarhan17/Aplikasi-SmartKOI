# 🐟 Aplikasi SmartKOI

> **Sistem Monitoring Kualitas Air & Daya Cadangan Akuarium Ikan Koi Berbasis IoT.**

Aplikasi Android yang dikembangkan dengan Flutter untuk memonitoring kualitas air akuarium secara *real-time*. Terintegrasi dengan perangkat keras IoT (ESP32), aplikasi ini memastikan lingkungan ikan Koi tetap ideal dan memberikan notifikasi cerdas saat terjadi anomali suhu atau pemadaman listrik (transisi ke *Backup Power*).

---

## ✨ Fitur Utama

* **📱 Manajemen Multi-Perangkat:** Kelola beberapa perangkat IoT sekaligus menggunakan ID unik (contoh: `KOI001`).
* **💧 Real-time Water Monitoring:** Pantau Suhu, pH, TDS, dan Kekeruhan (*Turbidity*) secara langsung.
* **🔋 Battery & Backup Power:** Pantau status *State of Charge* (SoC %), Arus, Tegangan, dan Kapasitas Baterai (Ah).
* **🔔 Push Notifications (FCM):**
  * **Peringatan Kritis:** Notifikasi instan jika parameter air di luar batas aman (misal: Suhu > 30°C).
  * **Status Kelistrikan:** Notifikasi saat listrik PLN mati (baterai *discharging*) dan saat listrik kembali normal.
* **📊 Riwayat Data:** Log historis seluruh sensor untuk analisis jangka panjang.
* **🔐 Autentikasi:** Sistem Sign Up, Login, Forgot Password, dan Manajemen Profil Pengguna.

---

## 🛠️ Teknologi & Stack

* **Framework:** Flutter (Android Only)
* **Backend:** Firebase Realtime Database
* **Auth & Security:** Firebase Authentication
* **Notifikasi:** Firebase Cloud Messaging (FCM)
* **Performance:** Firebase Performance Monitoring

---

## 🗄️ Struktur Database

Aplikasi membaca dan menulis data ke Firebase dengan *path* berikut:
* `Devices/{Device_ID}/realtime` : Data sensor kualitas air (*Real-time*).
* `Devices/{Device_ID}/Battery` : Detail kelistrikan sistem *backup*.
* `History_Sensors` : Log pergerakan data sensor (Suhu, pH, TDS, Turbidity).

---

## 🚀 Getting Started

Untuk menjalankan kode ini di lokal:

1. **Clone repository:**
   ```bash
   git clone [https://github.com/MhdFarhan17/Aplikasi-SmartKOI.git](https://github.com/MhdFarhan17/Aplikasi-SmartKOI.git)
   ```

2. **Install dependencies:**
   ```bash
   flutter pub get
   ```

3. **Firebase Setup:**
   * Buat project di Firebase Console.
   * Unduh `google-services.json` dan letakkan di `android/app/`.

4. **Run App:**
   ```bash
   flutter run
   ```

---

## 👨‍💻 Author

**Muhammad Farhan**

* Teknik Elektro UNDIP, Konsentrasi Teknologi Informasi
* Focus: System IoT, Mobile App, & Web Development
* [LinkedIn](https://www.linkedin.com/in/mhd-farhan/) | [Email](mfsn2806@gmail.com) | [Website](https://mdfarhan.site)
