import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/market_controller.dart';

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
    final width = MediaQuery.sizeOf(context).width;
    final isWide = width >= 900;
    final c = Get.find<MarketController>();

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
                _logo(),
                const SizedBox(width: 12),
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
            Flex(
              direction: isWide ? Axis.horizontal : Axis.vertical,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Expanded(
                  child: _SectionCard(
                    title: 'TOP GAINERS',
                    emoji: '🚀',
                    child: SizedBox(height: 120),
                  ),
                ),
                SizedBox(width: 20, height: 20),
                Expanded(
                  child: _SectionCard(
                    title: 'TOP LOSERS',
                    emoji: '📉',
                    child: SizedBox(height: 120),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _SearchField(
              hint: 'Search coins (BTC, ETH, ADA...)',
              onChanged: (v) {
                _deb?.cancel();
                _deb = Timer(const Duration(milliseconds: 250), () {
                  if (mounted) setState(() => _query = v);
                });
              },
            ),
            const SizedBox(height: 24),
            Text(
              'YOUR ASSETS',
              style: Theme.of(context).textTheme.titleMedium!.copyWith(
                color: Colors.white70,
                letterSpacing: 0.6,
              ),
            ),
            const SizedBox(height: 12),
            Column(
              children: [
                for (final a in filtered) ...[
                  _AssetTileLive(
                    slug: a.slug,
                    symbol: a.symbol,
                    name: a.name,
                    onTap: () async {
                      await c.changeAsset(a.slug);
                      // navigate ke halaman detail chart
                      Get.toNamed(
                        '/market',
                      ); // atau Get.to(() => const MarketPage());
                    },
                  ),
                  const SizedBox(height: 12),
                ],
                const SizedBox(height: 60),
              ],
            ),
          ],
        );
      }),
    );
  }

  Widget _logo() {
    return Container(
      width: 34,
      height: 34,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        gradient: const LinearGradient(
          colors: [Color(0xFF59C2FF), Color(0xFF5B8CFF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x803B82F6),
            blurRadius: 12,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: const Icon(
        Icons.currency_bitcoin_rounded,
        size: 18,
        color: Colors.white,
      ),
    );
  }

  static Widget _circleIcon(IconData icon) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: const Color(0xFF111A2E),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF1A2440)),
      ),
      child: Icon(icon, size: 20, color: Colors.white70),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final String emoji;
  final Widget child;
  const _SectionCard({
    required this.title,
    required this.emoji,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Container(
        padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: const LinearGradient(
            colors: [Color(0xFF0F172A), Color(0xFF0D1527)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          border: const Border.fromBorderSide(
            BorderSide(color: Color(0xFF1A2440)),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$emoji  $title',
              style: Theme.of(context).textTheme.titleMedium!.copyWith(
                color: Colors.white70,
                letterSpacing: .6,
              ),
            ),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }
}

class _AssetTileLive extends StatelessWidget {
  final String slug;
  final String symbol;
  final String name;
  final VoidCallback onTap;
  const _AssetTileLive({
    required this.slug,
    required this.symbol,
    required this.name,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final c = Get.find<MarketController>();
    return Obx(() {
      final price =
          c.prices[slug] ??
          (c.selected.value == slug ? c.lastPrice.value : 0.0);
      final pct = c.selected.value == slug ? c.change24hPct.value : null;
      final up = (pct ?? 0) >= 0;
      final pctColor = up ? const Color(0xFF22C55E) : const Color(0xFFF43F5E);
      final pctStr = pct == null
          ? '—'
          : '${up ? '+' : ''}${pct.toStringAsFixed(2)}%';

      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF0F172A),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFF1A2440)),
          ),
          child: Row(
            children: [
              _assetIcon(),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          symbol,
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          name,
                          style: const TextStyle(
                            color: Colors.white60,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Vol: —',
                      style: TextStyle(color: Colors.white54, fontSize: 12),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    price > 0 ? '\$${_fmt(price)}' : '--',
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    pctStr,
                    style: TextStyle(
                      color: pctColor,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _assetIcon() => Container(
    width: 40,
    height: 40,
    decoration: BoxDecoration(
      color: const Color(0xFF0A1222),
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: const Color(0xFF1A2440)),
    ),
    child: const Icon(Icons.currency_bitcoin_rounded, color: Colors.white70),
  );
}

class _SearchField extends StatelessWidget {
  final String hint;
  final ValueChanged<String>? onChanged;
  const _SearchField({required this.hint, this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF1A2440)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Row(
        children: [
          const Icon(Icons.search_rounded, color: Colors.white54),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              onChanged: onChanged,
              style: const TextStyle(fontSize: 14),
              decoration: const InputDecoration(
                hintText: 'Search coins (BTC, ETH, ADA...)',
                hintStyle: TextStyle(color: Colors.white54),
                border: InputBorder.none,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// util format angka
String _fmt(double v) {
  final s = v.toStringAsFixed(2);
  final parts = s.split('.');
  final ints = parts[0];
  final buff = StringBuffer();
  for (int i = 0; i < ints.length; i++) {
    final idx = ints.length - i - 1;
    buff.write(ints[idx]);
    final pos = i + 1;
    if (pos % 3 == 0 && idx != 0) buff.write(',');
  }
  final rev = buff.toString().split('').reversed.join();
  return '$rev.${parts[1]}';
}
