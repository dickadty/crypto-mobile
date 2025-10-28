

import 'dart:async';
import 'package:crypto_mvp_getx/features/market/presentastion/widgets/assets_tile.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/market_controller.dart';
import '../widgets/logo_widget.dart';
import '../widgets/section_card.dart';
import '../widgets/search_field.dart';

class CryptoFlowPage extends StatefulWidget {
  const CryptoFlowPage({super.key});

  @override
  State<CryptoFlowPage> createState() => _CryptoFlowPageState();
}

class _CryptoFlowPageState extends State<CryptoFlowPage> {
  String _query = '';
  Timer? _deb;

  @override
  void dispose() {
    _deb?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = Get.find<MarketController>();

    // Filtered assets based on search query
    final q = _query.toLowerCase();
    final filtered = c.assetInfos.where((a) {
      if (q.isEmpty) return true;
      return a.slug.contains(q) ||
          a.symbol.toLowerCase().contains(q) ||
          a.name.toLowerCase().contains(q);
    }).toList();

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(64),
        child: Container(
          decoration: const BoxDecoration(
            color: Color(0xFF0C1220),
            border: Border(bottom: BorderSide(color: Color(0xFF1A2440))),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: SafeArea(
            child: Row(
              children: [
                LogoWidget(),
                const SizedBox(width: 10),
                const Text(
                  'CryptoFlow',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
                ),
                const Spacer(),
                _circleIcon(Icons.settings),
                const SizedBox(width: 10),
                _circleIcon(Icons.notifications_none_rounded),
              ],
            ),
          ),
        ),
      ),
      body: Obx(() {
        if (c.isLoading.value && c.assetInfos.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        return ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // Top Gainers and Losers with fixed size
            Container(
              margin: const EdgeInsets.only(top: 10),
              child: Row(
                children: [
                  SectionCard(
                    title: 'TOP GAINERS',
                    emoji: '🚀',
                    child: SizedBox(height: 40),
                  ),
                  const SizedBox(width: 10),
                  SectionCard(
                    title: 'TOP LOSERS',
                    emoji: '📉',
                    child: SizedBox(height: 40),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),

            // Search Bar
            SearchField(
              hint: 'Search coins (BTC, ETH, ADA...)',
              onChanged: (v) {
                _deb?.cancel();
                _deb = Timer(const Duration(milliseconds: 250), () {
                  if (mounted) setState(() => _query = v);
                });
              },
            ),
            const SizedBox(height: 20),

            // "Your Assets" title - adjust font size to make it smaller
            Text(
              'YOUR ASSETS',
              style: Theme.of(context).textTheme.titleMedium!.copyWith(
                color: Colors.white70,
                fontSize: 14,
                letterSpacing: 0.4,
              ),
            ),
            const SizedBox(height: 12),

            // Filtered assets list
            Column(
              children: [
                for (final a in filtered) ...[
                  AssetTileLive(
                    slug: a.slug,
                    symbol: a.symbol,
                    name: a.name,
                    onTap: () async {
                      await c.changeAsset(a.slug);
                      // navigate to the detail chart page
                      Get.toNamed('/market');
                    },
                  ),
                  const SizedBox(height: 12),
                ],
                const SizedBox(height: 10),
              ],
            ),
          ],
        );
      }),
    );
  }

  // Circle icon widget
  static Widget _circleIcon(IconData icon) {
    return Container(
      width: 16,
      height: 16,
      decoration: BoxDecoration(
        color: const Color(0xFF111A2E),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF1A2440)),
      ),
      child: Icon(icon, size: 20, color: Colors.white70),
    );
  }
}
