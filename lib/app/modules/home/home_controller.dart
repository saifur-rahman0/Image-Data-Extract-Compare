import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

// Import the new WeatherService
import '../../services/weather_service.dart';
import '../result/result_screen.dart';

class HomeController extends GetxController {
  final ImagePicker _picker = ImagePicker();
  final TextRecognizer _textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
  
  // Instantiate WeatherService
  // The API key is now managed by the WeatherService
  final WeatherService _weatherService = WeatherService(apiKey: '90015d5b8676feecdc7641bd4a5af88f');
  final String _cityId = '1185241'; // Dhaka

  var selectedImagePath = ''.obs;
  var extractedText = ''.obs;
  var isProcessingImage = false.obs;
  var isCallingApi = false.obs;

  var apiResult = ''.obs;
  var comparisonMessage = ''.obs;

  // Constructor no longer needs to initialize _apiUrl
  HomeController() {
    // Initialization for _apiUrl removed
  }

  @override
  void onClose() {
    _textRecognizer.close();
    super.onClose();
  }

  Future<void> _initiateImageProcessing(ImageSource source) async {
    isProcessingImage.value = true;
    selectedImagePath.value = '';
    extractedText.value = '';
    apiResult.value = '';
    comparisonMessage.value = '';

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
        extractedText.value = text;
        Get.to(() => ResultScreen(extractedText: text));
      } else {
        extractedText.value = 'No text found in the image.';
        Get.snackbar('OCR Result', 'No text found in the image.');
      }
    } catch (e) {
      extractedText.value = 'Failed to extract text: ${e.toString()}';
      Get.snackbar('Error', 'Failed to extract text: ${e.toString()}');
    } finally {
      isProcessingImage.value = false;
    }
  }

  double? _parseTemperatureFromText(String text) {
    final RegExp tempRegExp = RegExp(r'(\d+\.?\d*)\s?°?C', caseSensitive: false);
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

    double? imageTemp = _parseTemperatureFromText(imageText);

    if (imageTemp == null) {
      apiResult.value = 'Could not find a temperature in the image text.';
      comparisonMessage.value = 'Please ensure the image contains a clear temperature reading (e.g., 25°C).';
      Get.snackbar('OCR Info', 'No parseable temperature found in image text.');
      return;
    }

    isCallingApi.value = true;
    apiResult.value = '';
    comparisonMessage.value = '';

    try {
      // Use WeatherService to get temperature
      final Map<String, dynamic> weatherData = await _weatherService.getCurrentTemperature(_cityId);
      final double? apiTemp = weatherData['temperature'] as double?;
      final String cityName = weatherData['cityName'] as String? ?? 'your city';

      if (apiTemp != null) {
        apiResult.value = 'Current temperature in $cityName: ${apiTemp.toStringAsFixed(1)}°C.';
        double difference = (imageTemp - apiTemp).abs();
        if (difference < 0.5) { // Threshold for "match"
          comparisonMessage.value = 'Temperatures match! (Image: ${imageTemp.toStringAsFixed(1)}°C, API: ${apiTemp.toStringAsFixed(1)}°C)';
        } else {
          comparisonMessage.value = 'Temperatures differ. Image: ${imageTemp.toStringAsFixed(1)}°C, API: ${apiTemp.toStringAsFixed(1)}°C. Difference: ${difference.toStringAsFixed(1)}°C.';
        }
      } else {
        // This case should ideally be covered by exceptions from WeatherService
        throw Exception('Temperature data is not in the expected format or missing in API response.');
      }
    } catch (e) {
      apiResult.value = 'API Call Failed.';
      comparisonMessage.value = 'Error: ${e.toString()}';
      Get.snackbar('API Error', 'Failed to get data from API: ${e.toString()}');
    } finally {
      isCallingApi.value = false;
    }
  }
}
