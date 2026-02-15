// Impor modul yang diperlukan
const functions = require("firebase-functions");
const admin = require("firebase-admin");
const {onValueUpdated} = require("firebase-functions/v2/database");

// Inisialisasi Firebase Admin (Metode otomatis ini sudah benar)
admin.initializeApp();

/**
 * Fungsi ini akan mengecek SEMUA data sensor (Kekeruhan, Jaringan, Suhu, pH, TDS, Turbidity)
 * dan mengirim notifikasi jika ada perubahan status dari "normal" ke "kritis".
 */
exports.onSensorDataUpdate = onValueUpdated(
    {
      ref: "/Devices/{deviceId}/realtime",
      region: "asia-southeast1",
      omitMissing: false,
    },
    async (event) => {
      // 'event.params' berisi wildcard {deviceId}
      const deviceId = event.params.deviceId;

      // 'event.data.before.val()' adalah data sebelum perubahan
      // 'event.data.after.val()' adalah data sesudah perubahan
      const beforeData = event.data.before.val();
      const afterData = event.data.after.val();

      // Jika data lama tidak ada (misal device baru dibuat), hentikan
      if (!beforeData) {
        console.log(`Data lama tidak ditemukan untuk ${deviceId}, skip.`);
        return null;
      }

      // 1. Ambil data parameter (settings)
      const paramsSnap = await admin.database()
          .ref(`/Devices/${deviceId}/parameters`).get();

      // 2. Ambil nama device
      const nameSnap = await admin.database()
          .ref(`/Devices/{deviceId}/deviceName`).get();
      const deviceName = nameSnap.val() || deviceId; // Fallback ke deviceId

      if (!paramsSnap.exists()) {
        console.warn(`Parameter settings tidak ditemukan untuk ${deviceId}.`);
        return null;
      }
      const params = paramsSnap.val();

      // Cek notifikasi 1: Kekeruhan (String)
      // Hanya kirim jika berubah dari Jernih -> Tidak Jernih
      if (beforeData.kekeruhan === "Jernih" && afterData.kekeruhan !== "Jernih") {
        const title = `Kualitas Air Buruk - ${deviceName}`;
        const body = `Peringatan: Kekeruhan air terdeteksi ${afterData.kekeruhan}!`;
        console.log(body);
        await sendFcmNotification(deviceId, title, body, "critical_alerts", "dashboard");
      }

      // Cek notifikasi 2: Jaringan (String)
      // Hanya kirim jika berubah dari WiFi -> GPRS
      if (beforeData.network === "WiFi" && afterData.network === "GPRS") {
        const title = `Jaringan Lemah - ${deviceName}`;
        const body = `Peringatan: Device beralih ke jaringan GPRS.`;
        console.log(body);
        // Perhatikan: channelId bisa berbeda jika mau (misal: "info_alerts")
        await sendFcmNotification(deviceId, title, body, "info_alerts", "dashboard");
      }

      // Cek notifikasi 3: Sensor Kritis (Angka)

      // --- PENGECEKAN SUHU ---
      // Cek Suhu Panas
      if (afterData.suhu > params.suhu_max && beforeData.suhu <= params.suhu_max) {
        const title = `Suhu Terlalu Panas - ${deviceName}`;
        const body = `Peringatan: Suhu ${afterData.suhu}°C melebihi batas (${params.suhu_max}°C)!`;
        console.log(body);
        await sendFcmNotification(deviceId, title, body, "critical_alerts", "dashboard");
      }
      // Cek Suhu Dingin
      if (afterData.suhu < params.suhu_min && beforeData.suhu >= params.suhu_min) {
        const title = `Suhu Terlalu Dingin - ${deviceName}`;
        const body = `Peringatan: Suhu ${afterData.suhu}°C di bawah batas (${params.suhu_min}°C)!`;
        console.log(body);
        await sendFcmNotification(deviceId, title, body, "critical_alerts", "dashboard");
      }

      // --- PENGECEKAN pH (TAMBAHAN) ---
      // Cek pH Basa
      if (afterData.ph > params.ph_max && beforeData.ph <= params.ph_max) {
        const title = `pH Terlalu Basa - ${deviceName}`;
        const body = `Peringatan: pH ${afterData.ph} melebihi batas (${params.ph_max})!`;
        console.log(body);
        await sendFcmNotification(deviceId, title, body, "critical_alerts", "dashboard");
      }
      // Cek pH Asam
      if (afterData.ph < params.ph_min && beforeData.ph >= params.ph_min) {
        const title = `pH Terlalu Asam - ${deviceName}`;
        const body = `Peringatan: pH ${afterData.ph} di bawah batas (${params.ph_min})!`;
        console.log(body);
        await sendFcmNotification(deviceId, title, body, "critical_alerts", "dashboard");
      }

      // Cek TDS Tinggi
      if (afterData.tds > params.tds_max && beforeData.tds <= params.tds_max) {
        const title = `TDS Terlalu Tinggi - ${deviceName}`;
        const body = `Peringatan: TDS ${afterData.tds} ppm melebihi batas (${params.tds_max} ppm)!`;
        console.log(body);
        await sendFcmNotification(deviceId, title, body, "critical_alerts", "dashboard");
      }
      // Cek TDS Rendah
      if (afterData.tds < params.tds_min && beforeData.tds >= params.tds_min) {
        const title = `TDS Terlalu Rendah - ${deviceName}`;
        const body = `Peringatan: TDS ${afterData.tds} ppm di bawah batas (${params.tds_min} ppm)!`;
        console.log(body);
        await sendFcmNotification(deviceId, title, body, "critical_alerts", "dashboard");
      }

      // Cek Turbidity Keruh
      if (afterData.turbidity > params.turbidity_max && beforeData.turbidity <= params.turbidity_max) {
        const title = `Turbidity Terlalu Keruh - ${deviceName}`;
        const body = `Peringatan: Turbidity ${afterData.turbidity} NTU melebihi batas (${params.turbidity_max} NTU)!`;
        console.log(body);
        await sendFcmNotification(deviceId, title, body, "critical_alerts", "dashboard");
      }
      // Cek Turbidity Terlalu Jernih (jika min > 0)
      if (afterData.turbidity < params.turbidity_min && beforeData.turbidity >= params.turbidity_min) {
        const title = `Turbidity Terlalu Jernih - ${deviceName}`;
        const body = `Peringatan: Turbidity ${afterData.turbidity} NTU di bawah batas (${params.turbidity_min} NTU)!`;
        console.log(body);
        await sendFcmNotification(deviceId, title, body, "critical_alerts", "dashboard");
      }

      return null;
    });

/**
 * Pemicu v2: Setiap kali data di /Devices/{deviceId}/Battery/Status di-update
 */
exports.onBatteryStatusUpdate = onValueUpdated(
    {
      ref: "/Devices/{deviceId}/Battery/Status",
      region: "asia-southeast1", // Sesuai pilihan Anda
      omitMissing: false,
    },
    async (event) => {
      const deviceId = event.params.deviceId;
      const beforeStatus = event.data.before.val();
      const afterStatus = event.data.after.val();

      // Jika data lama tidak ada, hentikan
      if (!beforeStatus) {
        console.log(`Status baterai lama tidak ditemukan untuk ${deviceId}, skip.`);
        return null;
      }

      // Ambil nama device
      const nameSnap = await admin.database()
          .ref(`/Devices/${deviceId}/deviceName`).get();
      const deviceName = nameSnap.val() || deviceId; // Fallback ke deviceId

      // Cek Notifikasi 3: Listrik Padam
      if (beforeStatus.toLowerCase() !== "discharging" && afterStatus.toLowerCase() === "discharging") {
        const title = `Listrik Padam - ${deviceName}`;
        const body = `Perhatian: Listrik padam! ${deviceName} sekarang menggunakan baterai.`;
        console.log(body);
        await sendFcmNotification(deviceId, title, body, "critical_alerts", "battery"); // Channel Kritis
      }

      // Notifikasi Bonus: Listrik Nyala
      if (beforeStatus.toLowerCase() === "discharging" && afterStatus.toLowerCase() !== "discharging") {
        const title = `Listrik Normal - ${deviceName}`;
        const body = `Info: Listrik kembali normal untuk ${deviceName}.`;
        console.log(body);
        await sendFcmNotification(deviceId, title, body, "info_alerts", "battery"); // Channel Info
      }
      return null;
    });

/**
 * PERBAIKAN V3: Menambahkan channelId, icon, color, dan priority
 */
async function sendFcmNotification(deviceId, title, body, channelId = "default", navigationTarget = "dashboard") {
  // 1. Cek apakah notifikasi diaktifkan oleh user
  //    (Saya asumsikan Anda ingin semua notifikasi kritis tetap masuk,
  //     atau Anda bisa cek setting yang berbeda di sini)
  const notifSnap = await admin.database()
      .ref(`/Devices/${deviceId}/notification_settings/critical_alerts_enabled`).get();

  if (notifSnap.val() !== true && channelId === "critical_alerts") {
    console.log(`Notifikasi Kritis dimatikan oleh user untuk ${deviceId}.`);
    return;
  }

  // 2. Kumpulkan semua FCM Token
  const tokensSnap = await admin.database()
      .ref(`/Devices/${deviceId}/fcm_tokens`).get();

  if (!tokensSnap.exists()) {
    console.log(`Tidak ada FCM token yang terdaftar untuk device ${deviceId}.`);
    return;
  }

  const tokens = Object.keys(tokensSnap.val());

  if (tokens.length === 0) {
    console.log("Tidak ada FCM token yang ditemukan.");
    return;
  }

  // 3. Buat payload notifikasi
  const message = {
    notification: {
      title: title,
      body: body,
    },
    data: {
      deviceId: deviceId,
      click_action: "FLUTTER_NOTIFICATION_CLICK",
      channel_id: channelId,
      title: title,
      body: body,
      navigation_target: navigationTarget,
    },
    android: {
      notification: {
        sound: "default",
        icon: "ic_notification", // Nama file ikon di folder res/drawable
        color: "#B71C1C", // Warna merah tua untuk peringatan
        channel_id: channelId, // ID Saluran Notifikasi
      },
      priority: "high", // Untuk Heads-Up Notification
    },
    apns: {
      payload: {
        aps: {
          sound: "default",
          "thread-id": channelId, // Mengelompokkan notifikasi di iOS
          // (iOS) Untuk notifikasi kritis, perlu setup lebih lanjut
        },
      },
      headers: {
        "apns-priority": "10", // Prioritas tinggi di iOS
      },
    },
    tokens: tokens,
  };

  // 4. Kirim notifikasi menggunakan sendEachForMulticast
  console.log(`Mengirim FCM (Target: ${navigationTarget}) ke ${tokens.length} token.`);
    const response = await admin.messaging().sendEachForMulticast(message);

  // 5. (Opsional) Bersihkan token yang sudah tidak valid
  const tokensToRemove = [];
  response.responses.forEach((resp, index) => {
    const error = resp.error;
    if (error) {
      console.error("Gagal mengirim notifikasi ke", tokens[index], error);
      if (error.code === "messaging/registration-token-not-registered" ||
          error.code === "messaging/invalid-registration-token") {
        tokensToRemove.push(tokensSnap.ref.child(tokens[index]).remove());
      }
    }
  });

  // Hapus semua token yang tidak valid dari database
  return Promise.all(tokensToRemove);
}