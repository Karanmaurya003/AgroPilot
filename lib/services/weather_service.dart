// ignore_for_file: avoid_print

import 'dart:convert';
import 'dart:async';
import 'dart:io';
import 'dart:developer' as developer;
import 'package:http/http.dart' as http;

class WeatherService {
  // Replace with your deployed backend URL
  final String _baseUrl = 'https://agropilot-backend.herokuapp.com';

  WeatherService();

  /// Fetch weather and location data from the backend
  Future<Map<String, dynamic>> fetchWeather(double lat, double lon) async {
    final url = Uri.parse('$_baseUrl/get_weather_and_location?lat=$lat&lon=$lon');
    developer.log('Request URL -> $url');

    try {
      final response = await http.get(url).timeout(const Duration(seconds: 10));
      developer.log('HTTP status -> ${response.statusCode}');

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        throw HttpException('Server responded with status: ${response.statusCode}');
      }
    } on TimeoutException {
      throw Exception('Timeout - could not connect to $_baseUrl');
    } on SocketException {
      throw Exception('Network error: Could not reach the server at $_baseUrl');
    } on HttpException catch (e) {
      throw Exception('HTTP error: ${e.message}');
    } on FormatException {
      throw Exception('Invalid response format from the server.');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }
}
