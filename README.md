📱 **CryptoFlow - Real-Time Crypto Asset Tracker**

CryptoFlow adalah aplikasi **Flutter** berbasis **GetX Architecture Pattern (MVC + Reactive State Management)** yang dirancang untuk memantau harga, volume, dan grafik aset kripto secara **real-time** menggunakan **CoinCap API** (REST & WebSocket).  
Dengan antarmuka modern dan mode gelap yang elegan, CryptoFlow memberikan pengalaman pemantauan aset digital yang cepat, interaktif, dan intuitif.


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

| Lokasi File / Folder | Deskripsi |
| --------------------- | ---------- |
| **lib/core/constants/** | Berisi konstanta global seperti warna, interval waktu, dan aset. |
| ┗ **app_constants.dart** | Definisi konstanta utama aplikasi. |
| **lib/data/datasources/** | Koneksi ke API eksternal (REST & WebSocket). |
| ┗ **coincap_service.dart** | Implementasi CoinCap REST API & WebSocket client. |
| **lib/data/models/** | Model data untuk parsing JSON dari API. |
| ┣ **asset_info.dart** | Model data untuk informasi aset kripto. |
| ┗ **candle_model.dart** | Model data untuk grafik candlestick. |
| **lib/features/market/controllers/** | Logic & state management menggunakan GetX. |
| ┗ **market_controller.dart** | Controller utama untuk mengelola data pasar kripto. |
| **lib/features/market/presentation/pages/** | Halaman utama aplikasi (UI). |
| ┣ **crypto_flow_page.dart** | Halaman dashboard utama CryptoFlow. |
| ┣ **market_page.dart** | Tampilan daftar aset kripto dan harga real-time. |
| ┗ **fullscreen_chart_page.dart** | Halaman grafik candlestick penuh. |
| **lib/features/market/presentation/widgets/** | Widget custom untuk menampilkan komponen UI. |
| ┣ **asset_tile.dart** | Komponen untuk menampilkan satu aset kripto. |
| ┣ **candles_chart.dart** | Widget grafik candlestick interaktif. |
| ┗ **stat_tile.dart** | Komponen statistik (volume, market cap, dll). |
| **app.dart** | Entry point aplikasi, berisi `GetMaterialApp` dan konfigurasi tema. |



## ⚙️ Cara Menjalankan Proyek
1️⃣ Clone Repositori
```bash
git clone [(https://github.com/dickadty/crypto-mobile)]
```
2️⃣ Masuk ke Direktori
```bash
cd crypto-mobile
```
3️⃣ Install Dependencies
```bash
flutter pub get
```
4️⃣ Jalankan Aplikasi
```bash
flutter run
```

### 🔗 API Source

Data diambil dari CoinCap API

REST Endpoint: https://api.coincap.io/v2/assets

WebSocket Stream: wss://ws.coincap.io/prices?assets=bitcoin,ethereum,...


### 🧠 Teknologi yang Digunakan
| Kategori         | Teknologi                                    |
| ---------------- | -------------------------------------------- |
| Framework        | Flutter 3.x                                  |
| State Management | GetX                                         |
| Data Source      | CoinCap API                                  |
| UI Library       | Flutter Material Widgets                     |
| Chart Library    | `candlesticks` / `syncfusion_flutter_charts` |
| Language         | Dart                                         |


