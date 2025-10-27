import 'package:crypto_mvp_getx/features/market/presentastion/controllers/market_controller.dart';
import 'package:get/get.dart';
import '../../data/datasources/coincap_ws.dart';
import '../../data/datasources/coincap_rest.dart';
import '../../data/datasources/coincap_price_rest.dart';
import '../../data/datasources/coincap_assets_rest.dart';


class MarketBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(CoinCapWsClient(), permanent: true);
    Get.put(CoinCapRestClient(), permanent: true);
    Get.put(CoinCapPriceRest(), permanent: true);
    Get.put(CoinCapAssetsRest(), permanent: true);
    Get.put(MarketController(Get.find(), Get.find(), Get.find(), Get.find()),
        permanent: true);
  }
}
