import 'package:get/get.dart';
import '../../services/weather_service.dart'; // Adjusted path

class TemperatureController extends GetxController {
  final WeatherService _weatherService = Get.find<WeatherService>();

  final Rxn<double> imageTemperature = Rxn<double>();
  final Rxn<double> apiTemperature = Rxn<double>();
  final RxString apiCityName = ''.obs;
  final RxString overallTemperatureStatusMessage = ''.obs;
  final RxString temperatureComparisonResult = ''.obs;
  final RxString temperatureDifferenceDetails = ''.obs;

  // Indicates if temperature was successfully found in image AND API call logic completed (even if data fetch failed)
  final RxBool temperatureProcessingAttempted = false.obs;
  // Indicates if a temperature was found in the image text
  final RxBool temperatureFoundInImage = false.obs;


  void resetFields() {
    imageTemperature.value = null;
    apiTemperature.value = null;
    apiCityName.value = '';
    overallTemperatureStatusMessage.value = '';
    temperatureComparisonResult.value = '';
    temperatureDifferenceDetails.value = '';
    temperatureProcessingAttempted.value = false;
    temperatureFoundInImage.value = false;
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

  // Returns true if temperature was found in image and API call sequence was completed.
  // Returns false if no temperature was found in image to begin with.
  Future<bool> processAndCompare(String imageText) async {
    resetFields(); // Reset at the beginning of an attempt
    temperatureProcessingAttempted.value = true; // Mark that an attempt is being made

    if (imageText.isEmpty) {
      overallTemperatureStatusMessage.value = 'No text provided for temperature check.';
      return false; // No text, so can't find temp
    }

    double? parsedImageTemp = _parseTemperatureFromText(imageText);
    imageTemperature.value = parsedImageTemp;

    if (parsedImageTemp == null) {
      overallTemperatureStatusMessage.value = 'Could not find temperature in image text.';
      temperatureDifferenceDetails.value = 'Ensure image text has a clear temperature reading (e.g., 25°C).';
      temperatureFoundInImage.value = false;
      return false; // Temperature not found in image
    }
    temperatureFoundInImage.value = true;

    // Notify calling controller (HomeController) to show OCR success SnackBar
    // This method focuses on its core logic and returns status.

    try {
      final Map<String, dynamic> weatherData = await _weatherService.getCurrentTemperature();
      final double? fetchedApiTemp = weatherData['temperature'] as double?;
      final String fetchedCityName = weatherData['cityName'] as String? ?? 'your city';

      apiTemperature.value = fetchedApiTemp;
      apiCityName.value = fetchedCityName;

      if (fetchedApiTemp != null) {
        overallTemperatureStatusMessage.value = 'Current temperature in $fetchedCityName: ${fetchedApiTemp.toStringAsFixed(1)}°C.';
        double difference = (parsedImageTemp - fetchedApiTemp).abs();

        if (difference < 0.5) {
          temperatureComparisonResult.value = 'Temperatures match!';
          temperatureDifferenceDetails.value = 'Both sources confirm ${parsedImageTemp.toStringAsFixed(1)}°C.';
        } else {
          temperatureComparisonResult.value = 'Temperatures differ.';
          temperatureDifferenceDetails.value = 'Difference: ${difference.toStringAsFixed(1)}°C.';
        }
      } else {
        overallTemperatureStatusMessage.value = 'API Error: Could not fetch temperature data.';
        temperatureDifferenceDetails.value = 'API response did not contain valid temperature data.';
      }
    } catch (e) {
      overallTemperatureStatusMessage.value = 'Weather API Call Failed.';
      temperatureDifferenceDetails.value = 'Error fetching weather: ${e.toString()}';
      apiTemperature.value = null;
      // SnackBar for API error should be handled by HomeController
    }
    return true; // Processing completed (even if API failed, the attempt was made based on found image temp)
  }
}
