import 'package:get/get.dart';
import '../home/home_controller.dart'; // To access shared data and methods

class ResultController extends GetxController {
  late final HomeController _homeController;

  // Getter for the extracted text
  String get ocrText => _homeController.ocrTextForResultScreen.value;


  RxBool get isCallingApi => _homeController.isCallingApi;

  // Temperature related fields from HomeController (which gets them from TemperatureController)
  Rxn<double> get imageTemperature => _homeController.imageTemperature;
  Rxn<double> get apiTemperature => _homeController.apiTemperature;
  // RxString get apiCityName => _homeController.apiCityName; // Still not directly used by ResultScreen UI
  RxString get overallTemperatureStatusMessage => _homeController.overallTemperatureStatusMessage; // Updated
  RxString get temperatureComparisonResult => _homeController.temperatureComparisonResult;
  RxString get temperatureDifferenceDetails => _homeController.temperatureDifferenceDetails;
  RxBool get temperatureProcessingAttempted => _homeController.temperatureProcessingAttempted; // New
  RxBool get temperatureFoundInImage => _homeController.temperatureFoundInImage; // New

  // Product related fields from HomeController (which gets them from ProductController)
  RxList<String> get identifiedProductNames => _homeController.identifiedProductNames;
  RxBool get productSearchAttempted => _homeController.productSearchAttempted; // Replaces productSearchConcluded
  RxBool get productsWereFound => _homeController.productsWereFound; // New

  @override
  void onInit() {
    super.onInit();
    _homeController = Get.find<HomeController>();
  }

  // Method to initiate the API comparison using the text from HomeController
  Future<void> performApiComparison() async {
    final textToCompare = _homeController.ocrTextForResultScreen.value;

    await _homeController.compareWithApi(textToCompare);

  }
}
