import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
class WeatherDTO {
  final double temperature;
  final double windSpeed;

  WeatherDTO({required this.temperature, required this.windSpeed});
  factory WeatherDTO.fromJson(Map<String, dynamic> json) {
    return WeatherDTO(
      temperature: json['current_weather']['temperature'],
      windSpeed: json['current_weather']['wind_speed'],
    );
  }
}
abstract class WeatherRepository {
  Future<WeatherDTO> getWeather(String city);
}
class WeatherRepositoryImpl implements WeatherRepository {
  @override
  Future<WeatherDTO> getWeather(String city) async {
    final url = Uri.parse(
        'https://api.open-meteo.com/v1/forecast?latitude=52.52&longitude=13.41&current_weather=true');

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return WeatherDTO.fromJson(data);
    } else {
      throw Exception('Failed to load weather data');
    }
  }
}
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lab 5 - API',
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
      home: const WeatherScreen(),
    );
  }
}

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  final WeatherRepository repository = WeatherRepositoryImpl();
  WeatherDTO? weather;
  bool isLoading = false;
  String errorMessage = '';

  final TextEditingController _controller = TextEditingController();

  void fetchWeather() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      final result = await repository.getWeather(_controller.text);
      setState(() {
        weather = result;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Error: $e';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Lab 5 - Weather API')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                labelText: 'Enter city (e.g., Berlin)',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: fetchWeather,
                ),
              ),
            ),
            const SizedBox(height: 20),
            if (isLoading) const CircularProgressIndicator(),
            if (errorMessage.isNotEmpty)
              Text(errorMessage, style: const TextStyle(color: Colors.red)),
            if (weather != null && !isLoading)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Text('Temperature: ${weather!.temperature}°C',
                          style: const TextStyle(fontSize: 20)),
                      Text('Wind Speed: ${weather!.windSpeed} km/h',
                          style: const TextStyle(fontSize: 18)),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}