import 'dart:async';
import 'package:crypto_mvp_getx/core/constants/assets.dart';
import 'package:get/get.dart';
import 'package:crypto_mvp_getx/data/models/assets_info.dart';
import 'package:crypto_mvp_getx/data/models/chandle.dart';
import '../../../../data/datasources/coincap_assets_rest.dart';
import '../../../../data/datasources/coincap_price_rest.dart';
import '../../../../data/datasources/coincap_rest.dart';
import '../../../../data/datasources/coincap_ws.dart';

class MarketController extends GetxController {
  final CoinCapWsClient _ws;
  final CoinCapRestClient _rest;
  final CoinCapPriceRest _priceRest;
  final CoinCapAssetsRest _assetsRest;

  MarketController(this._ws, this._rest, this._priceRest, this._assetsRest);

  // Data
  final assetInfos = <AssetInfo>[].obs;
  final assets = <String>[].obs; // slugs
  final selected = RxnString();

  // Live prices
  final prices = <String, double>{}.obs; // Prices per asset
  final volumes = <String, double>{}.obs; // Volumes per asset
  final pctChanges = <String, double>{}.obs;
  final lastPrice = 0.0.obs;

  // UI
  final isLoading = true.obs;
  final error = RxnString();
  final chartExpanded = false.obs;
  void toggleChartExpanded() => chartExpanded.toggle();

  // Chart
  final selectedInterval = 'm5'.obs; // Default interval
  final candles = <Candle>[].obs;
  static const _maxPoints = 300;

  // Metrics
  final high24h = RxnDouble();
  final low24h = RxnDouble();
  final marketCap = RxnDouble();
  final volume24h = RxnDouble();
  final change24hPct = RxnDouble();

  // Cache candles (slug::interval)
  final _cache = <String, List<Candle>>{};

  Timer? _fallbackTimer;

  @override
  void onInit() {
    super.onInit();
    _bootstrap();
    _loadAssets();
  }

  @override
  void onClose() {
    _ws.close();
    _fallbackTimer?.cancel();
    super.onClose();
  }

  Future<void> _bootstrap() async {
    try {
      isLoading.value = true;
      final list = await _assetsRest.fetchAssets(limit: 200);
      assetInfos.assignAll(list);
      assets.assignAll(list.map((e) => e.slug));
      selected.value = assets.contains('bitcoin')
          ? 'bitcoin'
          : (assets.isNotEmpty ? assets.first : null);

      final sel = selected.value;
      if (sel != null) {
        await _loadHistory(assetSlug: sel);
        await _loadStats24h(sel);
      }

      _connectWs(all: true);
      _fallbackTimer = Timer(const Duration(seconds: 3), _fallbackIfNoWsPrice);
    } catch (e) {
      error.value = 'Init gagal: $e';
    } finally {
      isLoading.value = false;
    }
  }

  AssetInfo? infoBySlug(String slug) =>
      assetInfos.firstWhereOrNull((a) => a.slug == slug);

  Future<void> _fallbackIfNoWsPrice() async {
    final slug = selected.value;
    if (slug == null || prices[slug] != null) return;
    final sym = infoBySlug(slug)?.symbol;
    if (sym == null) return;
    final p = await _priceRest.priceBySymbol(sym);
    if (p != null) prices[slug] = p;
  }

  String _key(String slug, String interval) => '$slug::$interval';

  Future<void> _loadHistory({required String assetSlug}) async {
    error.value = null;
    final key = _key(assetSlug, selectedInterval.value);
    final cached = _cache[key];
    if (cached != null && cached.isNotEmpty) {
      candles.assignAll(cached.take(_maxPoints).toList());
      return;
    }

    candles.clear();
    try {
      final hist = await _rest.fetchCandlesLastN(
        slug: assetSlug,
        interval: selectedInterval.value,
        count: 200,
      );
      final cut = hist.take(_maxPoints).toList();
      _cache[key] = cut;
      candles.assignAll(cut);
    } catch (e) {
      error.value = 'Gagal load candles: $e';
    }
  }

  Future<void> _loadStats24h(String slug) async {
    try {
      // 1) detail
      final detail = await _assetsRest.fetchAssetDetail(slug);
      marketCap.value = detail.marketCapUsd;
      volume24h.value = detail.volumeUsd24Hr;

      // 2) candles 24h untuk high/low dan %change
      final now = DateTime.now().toUtc();
      final end = now.millisecondsSinceEpoch;
      final start = now
          .subtract(const Duration(hours: 24))
          .millisecondsSinceEpoch;

      final cs = await _rest.fetchCandlesByTime(
        slug: slug,
        interval: 'm5',
        startMs: start,
        endMs: end,
      );

      if (cs.isEmpty) {
        high24h.value = null;
        low24h.value = null;
        change24hPct.value = null;
      } else {
        double hi = cs.first.high;
        double lo = cs.first.low;
        for (final c in cs) {
          if (c.high > hi) hi = c.high;
          if (c.low < lo) lo = c.low;
        }
        high24h.value = hi;
        low24h.value = lo;

        if (cs.length >= 2) {
          final first = cs.first.close;
          final last = cs.last.close;
          change24hPct.value = first == 0
              ? null
              : ((last - first) / first) * 100.0;
        } else {
          change24hPct.value = null;
        }
      }

      // Sync the data to volumes and pctChanges maps
      volumes[slug] = detail.volumeUsd24Hr ?? 0.0;
      pctChanges[slug] = change24hPct.value ?? 0.0;
      volumes.refresh();
      pctChanges.refresh();
    } catch (_) {
      high24h.value = null;
      low24h.value = null;
      marketCap.value = null;
      volume24h.value = null;
      change24hPct.value = null;
    }
  }

  void _connectWs({bool all = false}) {
    _ws.close();
    _ws.connect(
      assets: all ? <String>[] : assets.toList(),
      onPrices: (map) {
        prices.addAll(map);
        final sel = selected.value;
        if (sel != null) {
          final p = map[sel];
          if (p != null) prices[sel] = p;
        }
      },
      onError: (e) => error.value = 'WS error: $e',
      onDone: () => error.value = 'WS closed',
    );
  }

  Future<void> changeAsset(String slug) async {
    if (slug == selected.value) return;
    selected.value = slug;
    await _loadHistory(assetSlug: slug);
    await _loadStats24h(slug);
    if (prices.containsKey(slug)) {
      lastPrice.value = prices[slug]!;
    } else {
      lastPrice.value = 0.0;
      _fallbackTimer?.cancel();
      _fallbackTimer = Timer(const Duration(seconds: 1), _fallbackIfNoWsPrice);
    }
  }

  Future<void> changeInterval(String? interval) async {
    if (interval == null) return;
    if (!kIntervals.contains(interval)) return;
    if (interval == selectedInterval.value) return;
    selectedInterval.value = interval;

    final slug = selected.value;
    if (slug != null) await _loadHistory(assetSlug: slug);
  }

  Future<void> _loadAssets() async {
    try {
      isLoading.value = true;
      // Mengambil data dari API atau sumber data lainnya
      final list = await _assetsRest.fetchAssets(limit: 200);
      assetInfos.assignAll(list); // Update data yang di-observe
    } catch (e) {
      // Menangani error jika terjadi masalah
      print("Gagal memuat data: $e");
    } finally {
      isLoading.value = false;
    }
  }
}
