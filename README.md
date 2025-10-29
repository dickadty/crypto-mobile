# 💹 CRYPTOFLOW - Real-Time Crypto Asset Tracker

📱 **Proyek Ujian Tengah Semester (UTS) - Mobile Programming**

CryptoFlow adalah aplikasi **Flutter** yang dibangun menggunakan **GetX Architecture Pattern (MVC + Reactive State Management)** untuk memantau harga aset kripto secara **real-time** menggunakan **CoinCap API** (REST & WebSocket).

---

## 🚀 Fitur Utama

### 🔄 Real-time Price Update
- Mendapatkan pembaruan harga **secara live** melalui **WebSocket CoinCap**.
- Menampilkan perubahan harga, volume, dan persentase secara dinamis.

### 📊 Tampilan Detail Aset
- Menyajikan informasi lengkap:
  - Harga terkini
  - Volume 24 jam
  - Market Cap
  - High / Low
  - Persentase perubahan (24 jam)

### 🕯️ Grafik Candlestick Interaktif
- Menampilkan grafik historis harga dalam berbagai interval (m5, h1, d1, dll).
- Mendukung fitur **zoom**, **pan**, dan **tooltip interaktif**.

### 🌙 Dark Mode Interface
- Desain **modern dan elegan** dengan skema warna **dark mode** yang konsisten.
- Mendukung tampilan **responsif** di berbagai ukuran layar.

### 🔍 Pencarian Aset
- Fitur pencarian dengan **debounce** untuk performa cepat dan efisien.
- Filter berdasarkan **nama**, **simbol**, atau **slug** aset kripto.

---

## 🧩 Struktur Proyek (MVC + GetX)

lib/
├── core/
│ └── constants/
│ └── app_constants.dart # Interval waktu, assets, warna, dll.
│
├── data/
│ ├── datasources/
│ │ └── coincap_service.dart # REST & WebSocket API client
│ └── models/
│ ├── asset_info.dart
│ └── candle_model.dart
│
├── features/
│ └── market/
│ ├── controllers/
│ │ └── market_controller.dart # Logic & State Management (GetX)
│ └── presentation/
│ ├── pages/
│ │ ├── crypto_flow_page.dart
│ │ ├── market_page.dart
│ │ └── fullscreen_chart_page.dart
│ └── widgets/
│ ├── asset_tile.dart
│ ├── candles_chart.dart
│ └── stat_tile.dart
│
└── main.dart 


## ⚙️ Cara Menjalankan Proyek

### 1️⃣ Clone Repositori
```bash
git clone [Link Repositori Anda]

cd crypto_mvp_getx

flutter pub get

flutter run


🔗 API Source

Data diambil dari CoinCap API

REST Endpoint: https://api.coincap.io/v2/assets

WebSocket Stream: wss://ws.coincap.io/prices?assets=bitcoin,ethereum,...

🧠 Teknologi yang Digunakan
Kategori	Teknologi
Framework	Flutter 3.x
State Management	GetX
Data Source	CoinCap API
UI Library	Flutter Material Widgets
Chart Library	candlesticks / syncfusion_flutter_charts
Language	Dart
