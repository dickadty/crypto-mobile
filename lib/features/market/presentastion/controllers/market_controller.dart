import 'package:crypto_mvp_getx/data/models/assets_info.dart';
import 'package:crypto_mvp_getx/data/models/chandle.dart';
import 'package:get/get.dart';
import '../../../../core/constants/assets.dart';
import '../../../../data/datasources/coincap_ws.dart';
import '../../../../data/datasources/coincap_rest.dart';
import '../../../../data/datasources/coincap_price_rest.dart';
import '../../../../data/datasources/coincap_assets_rest.dart';

class MarketController extends GetxController {
  final CoinCapWsClient _ws;
  final CoinCapRestClient _rest;
  final CoinCapPriceRest _priceRest;
  final CoinCapAssetsRest _assetsRest;
  MarketController(this._ws, this._rest, this._priceRest, this._assetsRest);

  // Aset dinamis
  final assetInfos = <AssetInfo>[].obs; // daftar banyak aset
  final assets = <String>[].obs;        // slug list
  final selected = RxnString();         // slug terpilih

  // Harga live
  final prices = <String, double>{}.obs;
  final lastPrice = 0.0.obs;

  // UI
  final isLoading = true.obs;
  final error = RxnString();
  final chartExpanded = false.obs;
  void toggleChartExpanded() => chartExpanded.toggle();

  // Chart
  final selectedInterval = kDefaultInterval.obs;  // mis. 'm5'
  final candles = <Candle>[].obs;
  static const _maxPoints = 300;

  // ===== Metrik dinamis =====
  final high24h = RxnDouble();
  final low24h  = RxnDouble();
  final marketCap = RxnDouble();
  final volume24h = RxnDouble();

  @override
  void onInit() {
    super.onInit();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    try {
      isLoading.value = true;

      // 1) ambil list aset (misal top-200)
      final list = await _assetsRest.fetchAssets(limit: 200);
      assetInfos.assignAll(list);
      assets.assignAll(list.map((e) => e.slug));
      selected.value = assets.contains('bitcoin')
          ? 'bitcoin'
          : (assets.isNotEmpty ? assets.first : null);

      // 2) load awal
      final sel = selected.value;
      if (sel != null) {
        await _loadHistory(assetSlug: sel);
        await _loadStats24h(sel);  // set metrik & detail
      }

      // 3) websocket harga (ALL agar banyak aset hidup)
      _connectWs(all: true);

      // fallback harga bila WS belum mengisi
      Future.delayed(const Duration(seconds: 3), _fallbackIfNoWsPrice);
    } catch (e) {
      error.value = 'Init gagal: $e';
    } finally {
      isLoading.value = false;
    }
  }

  AssetInfo? infoBySlug(String slug) {
    for (final a in assetInfos) {
      if (a.slug == slug) return a;
    }
    return null;
  }

  Future<void> _fallbackIfNoWsPrice() async {
    final slug = selected.value;
    if (slug == null || lastPrice.value > 0) return;
    final sym = infoBySlug(slug)?.symbol;
    if (sym == null) return;
    final p = await _priceRest.priceBySymbol(sym);
    if (p != null) lastPrice.value = p;
  }

  Future<void> _loadHistory({required String assetSlug}) async {
    error.value = null;
    candles.clear();
    try {
      final hist = await _rest.fetchCandlesLastN(
        slug: assetSlug,
        interval: selectedInterval.value,
        count: 200,
      );
      candles.assignAll(hist.take(_maxPoints).toList());
    } catch (e) {
      error.value = 'Gagal load candles: $e';
    }
  }

  /// Muat metrik dinamis:
  /// - Market Cap & 24h Volume: dari `/assets/{slug}` (detail → AssetInfo)
  /// - High/Low 24h: dari candle 24 jam interval m5
  Future<void> _loadStats24h(String slug) async {
    try {
      // 1) detail aset (AssetInfo with marketCap/volume)
      final detail = await _assetsRest.fetchAssetDetail(slug);
      marketCap.value = detail.marketCapUsd;
      volume24h.value = detail.volumeUsd24Hr;

      // optional: merge ke list agar info enak dipakai kemudian
      final idx = assetInfos.indexWhere((e) => e.slug == slug);
      if (idx >= 0) {
        assetInfos[idx] = assetInfos[idx].copyWith(
          marketCapUsd: detail.marketCapUsd,
          volumeUsd24Hr: detail.volumeUsd24Hr,
        );
      }

      // 2) high/low 24 jam dari candlestick
      final now = DateTime.now().toUtc();
      final end = now.millisecondsSinceEpoch;
      final start = now.subtract(const Duration(hours: 24)).millisecondsSinceEpoch;

      final cs = await _rest.fetchCandlesByTime(
        slug: slug,
        interval: 'm5',
        startMs: start,
        endMs: end,
      );

      if (cs.isEmpty) {
        high24h.value = null;
        low24h.value  = null;
      } else {
        double hi = cs.first.high;
        double lo = cs.first.low;
        for (final c in cs) {
          if (c.high > hi) hi = c.high;
          if (c.low  < lo) lo = c.low;
        }
        high24h.value = hi;
        low24h.value  = lo;
      }
    } catch (_) {
      high24h.value = null;
      low24h.value  = null;
      marketCap.value = null;
      volume24h.value = null;
    }
  }

  void _connectWs({bool all = false}) {
    _ws.close();
    _ws.connect(
      assets: all ? <String>[] : assets.toList(), // [] => ALL
      onPrices: (map) {
        prices.addAll(map);
        final sel = selected.value;
        if (sel != null) {
          final p = map[sel];
          if (p != null) lastPrice.value = p;
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
    await _loadStats24h(slug); // muat ulang metrik + detail
    if (prices.containsKey(slug)) {
      lastPrice.value = prices[slug]!;
    } else {
      lastPrice.value = 0.0;
      Future.delayed(const Duration(seconds: 1), _fallbackIfNoWsPrice);
    }
  }

  Future<void> changeInterval(String interval) async {
    if (interval == selectedInterval.value) return;
    selectedInterval.value = interval;
    final slug = selected.value;
    if (slug != null) await _loadHistory(assetSlug: slug);
  }

  @override
  void onClose() {
    _ws.close();
    super.onClose();
  }
}
