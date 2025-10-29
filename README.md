CRYPTOFLOW - REAL-TIME CRYPTO ASSET TRACKER
Proyek Ujian Tengah Semester (UTS) Mobile Programming

Aplikasi Flutter yang dibangun menggunakan GetX untuk memonitor harga, volume, dan grafik aset kripto secara real-time menggunakan data dari CoinCap API.

Fitur Utama
Real-time Price Update: Menggunakan WebSocket CoinCap untuk pembaruan harga live.

Tampilan Detail Aset: Menyajikan harga, volume 24 jam, Market Cap, High/Low, dan Persentase Perubahan 24 jam.

Grafik Candlestick Interaktif: Menampilkan data historis yang dapat di-zoom, di-pan, dan diubah intervalnya (m5, h1, d1, dll.).

Dark Mode Interface: Desain clean dan modern dengan skema warna gelap yang konsisten.

Pencarian Aset: Filter aset kripto berdasarkan nama, simbol, atau slug dengan debounce yang efisien.

Struktur Proyek (MVC + GetX)
lib/
├── core/
│   └── constants/ (Definisi interval waktu, assets, dll.)
├── data/
│   ├── datasources/ (CoinCapService - REST & WebSocket API clients)
│   └── models/ (AssetInfo, Candle model, dll.)
├── features/
│   └── market/
│       ├── controllers/ (MarketController - Logic & State Management)
│       └── presentastion/
│           ├── pages/ (CryptoFlowPage, MarketPage, FullscreenChartPage)
│           └── widgets/ (AssetTile, CandlesChart, StatTile, dll.)
└── main.dart (Entry point & GetMaterialApp)
Cara Menjalankan Proyek
Clone Repositori:

Bash

git clone [Link Repositori Anda]
Masuk ke Direktori:

Bash

cd crypto_mvp_getx
Install Dependencies:

Bash

flutter pub get
Jalankan Aplikasi:

Bash

flutter run
