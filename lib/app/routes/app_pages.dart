import 'package:get/get.dart';
import 'app_routes.dart';

// Home Screen and Binding
import '../modules/home/home_screen.dart';
import '../modules/home/home_binding.dart';

// Result Screen, Controller, and Binding (Controller and Binding will be created next)
import '../modules/result/result_screen.dart';
import '../modules/result/result_controller.dart';
import '../modules/result/result_binding.dart';

class AppPages {
  static const INITIAL = Routes.HOME; // The initial route is now Home

  static final routes = [
    GetPage(
      name: Routes.HOME,
      page: () => const HomeScreen(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: Routes.RESULT,
      page: () => const ResultScreen(), // ResultScreen will no longer take constructor args
      binding: ResultBinding(),       // We'll create ResultBinding soon
    ),
  ];
}
