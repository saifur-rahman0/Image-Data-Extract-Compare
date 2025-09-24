import 'package:get/get.dart';
import 'home_controller.dart';
import '../../services/weather_service.dart';
import '../../services/product_service.dart';
// Updated controller imports
import '../controllers/temperature_controller.dart';
import '../controllers/product_controller.dart';
// Import for API configuration
import '../../core/config.dart'; // Path to your config file

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<WeatherService>(() => WeatherService(
          apiKey: ApiConfig.openWeatherApiKey,
          cityId: '1185241',
        ));

    Get.lazyPut<ProductService>(() => ProductService(
          apiKey: ApiConfig.huggingFaceApiKey,
        ));

    Get.lazyPut<TemperatureController>(() => TemperatureController());
    Get.lazyPut<ProductController>(() => ProductController());

    Get.lazyPut<HomeController>(() => HomeController());
  }
}
