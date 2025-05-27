import 'dart:convert';
import 'package:http/http.dart' as http;

Future<Map<String, dynamic>> getWeather(double lat, double lon) async {
  const apiKey = 'YOUR_OPENWEATHERMAP_API_KEY';
  final url = 'https://api.openweathermap.org/data/2.5/weather?lat=$lat&lon=$lon&appid=$apiKey&units=metric';

  final response = await http.get(Uri.parse(url));
  final data = jsonDecode(response.body);

  return {
    'temperature': data['main']['temp'],
    'humidity': data['main']['humidity'],
    'rainfall': data['rain']?['1h'] ?? 0.0,
  };
}
