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
          apiKey: ApiConfig.openWeatherApiKey, // Use key from ApiConfig
          cityId: '1185241',
        ));

    Get.lazyPut<ProductService>(() => ProductService(
          apiKey: ApiConfig.huggingFaceApiKey, // Use key from ApiConfig
        ));

    // Register the new controllers
    Get.lazyPut<TemperatureController>(() => TemperatureController());
    Get.lazyPut<ProductController>(() => ProductController());

    // HomeController depends on the above controllers being registered
    Get.lazyPut<HomeController>(() => HomeController());
  }
}
