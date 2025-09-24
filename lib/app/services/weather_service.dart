import 'dart:convert';
import 'package:http/http.dart' as http;

class WeatherService {
  final String _apiKey;
  final String _cityId;
  final String _baseUrl = 'http://api.openweathermap.org/data/2.5/weather';

  WeatherService({required String apiKey, required String cityId})
      : _apiKey = apiKey,
        _cityId = cityId;

  Future<Map<String, dynamic>> getCurrentTemperature() async {
    final String apiUrl = '$_baseUrl?id=$_cityId&appid=$_apiKey&units=metric';

    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);

        if (data.containsKey('main') &&
            data['main'] is Map &&
            data['main'].containsKey('temp') &&
            data['main']['temp'] is num &&
            data.containsKey('name') &&
            data['name'] is String) {
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
        }
        throw Exception(errorMsg);
      }
    } catch (e) {
      throw Exception('Error fetching weather data: ${e.toString()}');
    }
  }
}
