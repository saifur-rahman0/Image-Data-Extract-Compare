import 'package:flutter/material.dart'; // Added for Colors
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

import '../../services/weather_service.dart';
import '../../routes/app_routes.dart'; // Added for named navigation

class HomeController extends GetxController {
  final ImagePicker _picker = ImagePicker();
  final TextRecognizer _textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
  final WeatherService _weatherService = Get.find<WeatherService>();

  var selectedImagePath = ''.obs;
  var extractedText = ''.obs; // General extracted text
  final RxString ocrTextForResultScreen = ''.obs; // Specific for ResultScreen
  var isProcessingImage = false.obs;
  var isCallingApi = false.obs;

  // Observables for API comparison results (used by ResultScreen via ResultController)
  final Rxn<double> imageTemperature = Rxn<double>();
  final Rxn<double> apiTemperature = Rxn<double>();
  final RxString apiCityName = ''.obs;
  final RxString overallApiStatusMessage = ''.obs;
  final RxString temperatureComparisonResult = ''.obs;
  final RxString temperatureDifferenceDetails = ''.obs;

  HomeController();

  @override
  void onClose() {
    _textRecognizer.close();
    super.onClose();
  }

  void _resetApiComparisonFields() {
    imageTemperature.value = null;
    apiTemperature.value = null;
    apiCityName.value = '';
    overallApiStatusMessage.value = '';
    temperatureComparisonResult.value = '';
    temperatureDifferenceDetails.value = '';
  }

  Future<void> _initiateImageProcessing(ImageSource source) async {
    isProcessingImage.value = true;
    selectedImagePath.value = '';
    extractedText.value = '';
    ocrTextForResultScreen.value = ''; // Reset this as well
    _resetApiComparisonFields();

    try {
      final XFile? imageFile = await _picker.pickImage(source: source);
      if (imageFile != null) {
        selectedImagePath.value = imageFile.path;
        await _extractTextAndNavigate(imageFile.path);
      } else {
        Get.snackbar('Info', source == ImageSource.camera ? 'No photo taken.' : 'No image selected.');
        isProcessingImage.value = false;
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to ${source == ImageSource.camera ? "take photo" : "pick image"}: ${e.toString()}');
      isProcessingImage.value = false;
    }
  }

  Future<void> pickImage() async {
    await _initiateImageProcessing(ImageSource.gallery);
  }

  Future<void> takePhoto() async {
    await _initiateImageProcessing(ImageSource.camera);
  }

  Future<void> _extractTextAndNavigate(String imagePath) async {
    try {
      final inputImage = InputImage.fromFilePath(imagePath);
      final RecognizedText recognizedText = await _textRecognizer.processImage(inputImage);
      String text = recognizedText.text;
      if (text.isNotEmpty) {
        extractedText.value = text; // For general purpose if any
        ocrTextForResultScreen.value = text; // Specifically for ResultScreen
        Get.toNamed(Routes.RESULT); // Navigate by named route
      } else {
        extractedText.value = 'No text found in the image.';
        ocrTextForResultScreen.value = 'No text found in the image.';
        Get.snackbar('OCR Result', 'No text found in the image.');
      }
    } catch (e) {
      String errorMsg = 'Failed to extract text: ${e.toString()}';
      extractedText.value = errorMsg;
      ocrTextForResultScreen.value = errorMsg;
      Get.snackbar('Error', errorMsg);
    } finally {
      isProcessingImage.value = false;
    }
  }

  double? _parseTemperatureFromText(String text) {
    final RegExp tempRegExp = RegExp(
      r'([-+]?\d+(?:\.\d+)?)\s*°?\s*(?:[Cc]|celsius|celcius|Celsius|Celcius)',
      caseSensitive: false,
    );
    final RegExpMatch? match = tempRegExp.firstMatch(text);
    if (match != null && match.group(1) != null) {
      return double.tryParse(match.group(1)!);
    }
    return null;
  }

  Future<void> compareWithApi(String imageText) async {
    if (imageText.isEmpty) {
      Get.snackbar('Info', 'No text provided for API comparison.');
      return;
    }

    _resetApiComparisonFields();
    isCallingApi.value = true;

    double? parsedImageTemp = _parseTemperatureFromText(imageText);
    imageTemperature.value = parsedImageTemp;

    if (parsedImageTemp == null) {
      overallApiStatusMessage.value = 'Could not find temperature in image text.';
      temperatureDifferenceDetails.value = 'Please ensure the image contains a clear temperature reading (e.g., 25°C).';
      Get.snackbar('OCR Info', 'No parseable temperature found in image text.', snackPosition: SnackPosition.BOTTOM);
      isCallingApi.value = false;
      return;
    }

    Get.snackbar(
      'OCR Success',
      'Temperature found in image: ${parsedImageTemp.toStringAsFixed(1)}°C',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.lightGreen[100],
      colorText: Colors.green[700],
      margin: const EdgeInsets.all(10),
      borderRadius: 8,
    );

    try {
      final Map<String, dynamic> weatherData = await _weatherService.getCurrentTemperature();
      final double? fetchedApiTemp = weatherData['temperature'] as double?;
      final String fetchedCityName = weatherData['cityName'] as String? ?? 'your city';

      apiTemperature.value = fetchedApiTemp;
      apiCityName.value = fetchedCityName;

      if (fetchedApiTemp != null) {
        overallApiStatusMessage.value = 'Current temperature in $fetchedCityName: ${fetchedApiTemp.toStringAsFixed(1)}°C.';
        double difference = (parsedImageTemp - fetchedApiTemp).abs();

        if (difference < 0.5) {
          temperatureComparisonResult.value = 'Temperatures match!';
          temperatureDifferenceDetails.value = 'Both sources confirm ${parsedImageTemp.toStringAsFixed(1)}°C.';
        } else {
          temperatureComparisonResult.value = 'Temperatures differ.';
          temperatureDifferenceDetails.value = 'Difference: ${difference.toStringAsFixed(1)}°C';
        }
      } else {
        overallApiStatusMessage.value = 'API Error: Could not fetch temperature data.';
        temperatureDifferenceDetails.value = 'API response did not contain valid temperature data.';
      }
    } catch (e) {
      overallApiStatusMessage.value = 'API Call Failed.';
      temperatureDifferenceDetails.value = 'Error: ${e.toString()}';
      apiTemperature.value = null;
      Get.snackbar('API Error', 'Failed to get data from API: ${e.toString()}');
    } finally {
      isCallingApi.value = false;
    }
  }
}
