# 🌱 Smart Farming App (Flutter)

Aplikasi **Smart Farming berbasis Flutter** yang dirancang untuk membantu pengelolaan pertanian modern secara **cerdas, efisien, dan terintegrasi**.
Aplikasi ini menggabungkan **IoT, REST API, dan AI (deteksi hama)** dalam satu dashboard yang modern dan mudah digunakan.

> Cocok untuk proyek kampus, riset smart farming, maupun prototype sistem pertanian cerdas.

---

## 🚀 Fitur Utama

### 💧 Kontrol Pompa Air

* Kontrol pompa air **ON / OFF** secara real-time
* Mendukung mode **manual dan otomatis**
* Siap diintegrasikan dengan sensor kelembapan tanah

### 🌦️ Monitoring Cuaca

* Menampilkan data cuaca terkini:

  * Suhu
  * Kelembapan
  * Kondisi cuaca
* Data berasal dari **API cuaca** atau sensor lingkungan

### 🚜 Kontrol Pembajak / Alat Pertanian

* Kontrol aktuator pembajak atau alat pertanian
* Monitoring status alat secara langsung
* Dapat dikembangkan ke sistem **penjadwalan otomatis**

### ❤️ Monitoring Kesehatan Tanaman

* Analisis kondisi tanaman berbasis data sensor
* Indikator status tanaman:

  * Sehat
  * Waspada
  * Perlu tindakan
* Mendukung pengembangan **logika fuzzy / machine learning**

### 🐛 Deteksi Hama Tanaman (AI-Based)

* Deteksi hama menggunakan **gambar tanaman**
* Integrasi dengan **AI / Machine Learning model**
* Menampilkan hasil klasifikasi dan rekomendasi tindakan

---

## 🛠️ Teknologi yang Digunakan

* **Flutter** (Mobile Application)
* **Dart**
* **REST API**
* **IoT Devices** (ESP32 / Arduino)
* **AI / Machine Learning** (Deteksi Hama)
* **HTTP & JSON**
* **State Management** (Provider / Bloc / Riverpod)

---

## 📱 Preview Aplikasi

> Tambahkan screenshot aplikasi di folder berikut:

```
/assets/screenshots/
```

---

## 🧩 Arsitektur Sistem (High Level)

```
[ Flutter Mobile App ]
          |
       REST API
          |
[ Backend Server ]
          |
[ IoT Devices / AI Service ]
```

---

## 📂 Struktur Folder Project

```
lib/
├── pages/
│   ├── pump_page.dart
│   ├── weather_page.dart
│   ├── plow_page.dart
│   ├── plant_health_page.dart
│   └── pest_detection_page.dart
├── services/
│   ├── api_service.dart
│   └── pest_api_service.dart
├── routes/
│   └── BottomNavBar.dart
└── main.dart
```

---

## ⚙️ Cara Menjalankan Project

1. Clone repository:

   ```bash
   git clone https://github.com/username/smart-farming-flutter.git
   ```

2. Masuk ke folder project:

   ```bash
   cd smart-farming-flutter
   ```

3. Install dependency:

   ```bash
   flutter pub get
   ```

4. Jalankan aplikasi:

   ```bash
   flutter run
   ```

---

## 🎯 Rencana Pengembangan

* 🔔 Notifikasi otomatis (Firebase / Local Notification)
* 📊 Visualisasi grafik data sensor
* 🤖 Otomatisasi berbasis AI & Fuzzy Logic
* 🌐 Multi-device & multi-lahan
* 🔐 Autentikasi & manajemen pengguna

---

## 👨‍💻 Kontributor

* **Bagus** – Mobile App & System Development
* Tim Smart Farming

---

## 📄 Lisensi

Project ini dikembangkan untuk **keperluan edukasi dan penelitian**.
Silakan digunakan, dimodifikasi, dan dikembangkan lebih lanjut.

---

🌾 *Smart Farming bukan soal teknologi mahal, tapi soal keputusan yang cerdas.*
