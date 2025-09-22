import 'dart:convert';
import 'package:http/http.dart' as http;

class WeatherService {
  final String _apiKey;
  final String _baseUrl = 'http://api.openweathermap.org/data/2.5/weather';

  WeatherService({required String apiKey}) : _apiKey = apiKey;

  Future<Map<String, dynamic>> getCurrentTemperature(String cityId) async {
    final String apiUrl = '$_baseUrl?id=$cityId&appid=$_apiKey&units=metric';

    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);

        if (data.containsKey('main') &&
            data['main'] is Map &&
            data['main'].containsKey('temp') &&
            data['main']['temp'] is num && // Ensure temp is a number
            data.containsKey('name') &&
            data['name'] is String) { // Ensure name is a string

          return {
            'temperature': (data['main']['temp'] as num).toDouble(),
            'cityName': data['name'] as String,
          };
        } else {
          throw Exception('API response does not contain expected temperature or city name data structure.');
        }
      } else {
        String errorMsg = 'Failed to load weather data. Status: ${response.statusCode}.';
        try {
          final Map<String, dynamic> errorData = jsonDecode(response.body);
          if (errorData.containsKey('message')) {
            errorMsg += ' Message: ${errorData['message']}';
          }
        } catch (_) {
          // Ignore if error response is not JSON
        }
        throw Exception(errorMsg);
      }
    } catch (e) {
      // Rethrow the exception to be handled by the caller
      // Or handle it here and return a specific error structure if preferred
      throw Exception('Error fetching weather data: ${e.toString()}');
    }
  }
}
