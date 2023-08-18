// Weather data json
import 'dart:convert';
import 'package:http/http.dart';

class WeatherData {
  final String locationName;
  final String iconUrl;
  final double temperature;
  final String description;
  final DateTime date;

  WeatherData(
      {required this.locationName,
      required this.iconUrl,
      required this.temperature,
      required this.description,
      required this.date});

  factory WeatherData.fromJson(Map<String, dynamic> json) {
    final weather = json['weather'][0];
    final main = json['main'];
    final iconCode = weather['icon'];
    final iconUrl = 'https://openweathermap.org/img/wn/$iconCode.png';
    final temperature = main['temp'].toDouble();
    final description = weather['description'];
    final locationName = json['name'];
    return WeatherData(
        locationName: locationName,
        iconUrl: iconUrl,
        temperature: temperature,
        description: description,
        date: DateTime.fromMillisecondsSinceEpoch(json['dt'] * 1000,
            isUtc: false));
  }

  static Future<WeatherData> fetch(
      String apiKey, double latitude, double longitude) async {
    final url =
        'https://api.openweathermap.org/data/2.5/weather?lat=$latitude&lon=$longitude&appid=$apiKey&units=metric';
    final response = await get(Uri.parse(url));

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return WeatherData.fromJson(json);
    } else {
      throw Exception('Failed to load weather data');
    }
  }
}
