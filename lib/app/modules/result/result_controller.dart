import 'package:get/get.dart';
import '../home/home_controller.dart'; // To access shared data and methods

class ResultController extends GetxController {
  // Dependency on HomeController, initialized in onInit
  late final HomeController _homeController;

  // Getter for the extracted text to be displayed on ResultScreen
  String get ocrText => _homeController.ocrTextForResultScreen.value;

  // --- Pass-through getters for API comparison observables from HomeController ---
  Rxn<double> get imageTemperature => _homeController.imageTemperature;
  Rxn<double> get apiTemperature => _homeController.apiTemperature;
  // RxString get apiCityName => _homeController.apiCityName; // Not directly used by ResultScreen UI currently
  RxString get overallApiStatusMessage => _homeController.overallApiStatusMessage;
  RxString get temperatureComparisonResult => _homeController.temperatureComparisonResult;
  RxString get temperatureDifferenceDetails => _homeController.temperatureDifferenceDetails;

  // Pass-through getter for API call status
  RxBool get isCallingApi => _homeController.isCallingApi;

  @override
  void onInit() {
    super.onInit();
    // Initialize HomeController instance.
    // HomeController should already be in memory, put by its binding.
    _homeController = Get.find<HomeController>();
  }

  // Method to initiate the API comparison using the text from HomeController
  Future<void> performApiComparison() async {
    final textToCompare = _homeController.ocrTextForResultScreen.value;
    if (textToCompare.isNotEmpty && !textToCompare.startsWith('No text found')) {
      await _homeController.compareWithApi(textToCompare);
    } else {
      // Update status messages directly or show a snackbar
      _homeController.overallApiStatusMessage.value = 'No valid text available for comparison.';
      _homeController.temperatureComparisonResult.value = '';
      _homeController.temperatureDifferenceDetails.value = 'Please go back and extract text from an image first.';

    }
  }
}
