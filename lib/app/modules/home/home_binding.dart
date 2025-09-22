import 'package:get/get.dart';
import 'home_controller.dart'; // Import the controller

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HomeController>(() => HomeController());
  }
}