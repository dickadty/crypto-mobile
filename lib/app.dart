import 'package:crypto_mvp_getx/features/market/presentastion/pages/crypto_flow_page.dart';
import 'package:crypto_mvp_getx/features/market/presentastion/pages/market_page.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'features/market/market_binding.dart';

class CryptoApp extends StatelessWidget {
  const CryptoApp({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: const Color(0xFF0C1220),
      colorScheme: const ColorScheme.dark(
        primary: Color(0xFF5B8CFF),
        secondary: Color(0xFF8E9AF0),
        surface: Color(0xFF111A2E),
      ),
      useMaterial3: true,
      textTheme: const TextTheme(
        headlineSmall: TextStyle(
          fontWeight: FontWeight.w700,
          letterSpacing: .2,
        ),
        titleMedium: TextStyle(fontWeight: FontWeight.w600),
        bodyMedium: TextStyle(height: 1.3),
      ),
      // ✅ gunakan CardThemeData (bukan CardTheme)
      cardTheme: CardThemeData(
        color: const Color(0xFF0F172A),
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
      ),
    );

    return GetMaterialApp(
      title: 'CryptoFlow',
      debugShowCheckedModeBanner: false,
      theme: theme,
      initialBinding: MarketBinding(), // ← inject controller & datasources
      home: const CryptoFlowPage(), // ← beranda baru
      getPages: [GetPage(name: '/market', page: () => const MarketPage())],
    );
  }
}
