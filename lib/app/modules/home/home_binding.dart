import 'package:get/get.dart';
import 'home_controller.dart';
import '../../services/weather_service.dart'; // Import WeatherService

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    // Register WeatherService
    // It will be created when first requested by Get.find<WeatherService>()
    Get.lazyPut<WeatherService>(() => WeatherService(
          apiKey: '90015d5b8676feecdc7641bd4a5af88f', // Your API key
          cityId: '1185241', // Your City ID (Dhaka)
        ));

    // Register HomeController
    // HomeController will now be able to find the WeatherService instance
    Get.lazyPut<HomeController>(() => HomeController());
  }
}
