// ignore_for_file: avoid_print

import 'dart:convert';
import 'dart:async';
import 'dart:developer' as developer;
import 'package:http/http.dart' as http;

class WeatherService {
  // ✅ Use your live Render backend URL
  static const String baseUrl = "https://agropilot-backend.onrender.com";
  //static const String baseUrl = "https://agropilot-backend.onrender.com";

  Future<Map<String, dynamic>> fetchWeather(double lat, double lon) async {
    final url = Uri.parse('$baseUrl/get_weather_and_location?lat=$lat&lon=$lon');
    developer.log('Request URL -> $url');

    try {
      final response = await http.get(url).timeout(const Duration(seconds: 10));
      developer.log('HTTP status -> ${response.statusCode}');

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        throw Exception('Server responded with status: ${response.statusCode}');
      }
    } on TimeoutException {
      throw Exception('Timeout - could not connect to $baseUrl');
    } on Exception catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }
}
