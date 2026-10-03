import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
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

abstract class WeatherEvent extends Equatable {
  const WeatherEvent();
  @override
  List<Object> get props => [];
}

class SearchWeatherEvent extends WeatherEvent {
  final String query;
  const SearchWeatherEvent(this.query);
  @override
  List<Object> get props => [query];
}

class RefreshWeatherEvent extends WeatherEvent {}

abstract class WeatherState extends Equatable {
  const WeatherState();
  @override
  List<Object> get props => [];
}

class WeatherInitial extends WeatherState {}
class WeatherLoading extends WeatherState {}
class WeatherLoaded extends WeatherState {
  final WeatherDTO weather;
  const WeatherLoaded(this.weather);
  @override
  List<Object> get props => [weather];
}
class WeatherError extends WeatherState {
  final String message;
  const WeatherError(this.message);
  @override
  List<Object> get props => [message];
}

class WeatherRepository {
  Future<WeatherDTO> getWeather() async {
    final url = Uri.parse(
        'https://api.open-meteo.com/v1/forecast?latitude=52.52&longitude=13.41&current_weather=true');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      return WeatherDTO.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load weather data');
    }
  }
}

class WeatherBloc extends Bloc<WeatherEvent, WeatherState> {
  final WeatherRepository repository;
  Timer? _debounce;

  WeatherBloc(this.repository) : super(WeatherInitial()) {
    on<SearchWeatherEvent>((event, emit) async {
      if (_debounce?.isActive ?? false) _debounce!.cancel();

      _debounce = Timer(const Duration(milliseconds: 500), () async {
        emit(WeatherLoading());
        try {
          final weather = await repository.getWeather();
          emit(WeatherLoaded(weather));
        } catch (e) {
          emit(WeatherError(e.toString()));
        }
      });
    });

    on<RefreshWeatherEvent>((event, emit) async {
      emit(WeatherLoading());
      try {
        final weather = await repository.getWeather();
        emit(WeatherLoaded(weather));
      } catch (e) {
        emit(WeatherError(e.toString()));
      }
    });
  }

  @override
  Future<void> close() {
    _debounce?.cancel();
    return super.close();
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
      title: 'Lab 6 - BLoC',
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
      home: BlocProvider(
        create: (context) => WeatherBloc(WeatherRepository()),
        child: const WeatherScreen(),
      ),
    );
  }
}

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Lab 6 - BLoC Weather')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _controller,
              decoration: InputDecoration(
                labelText: 'Search city (Debounced)',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () {
                    context.read<WeatherBloc>().add(SearchWeatherEvent(_controller.text));
                  },
                ),
              ),
              onChanged: (value) {
                context.read<WeatherBloc>().add(SearchWeatherEvent(value));
              },
            ),
          ),

          Expanded(
            child: BlocBuilder<WeatherBloc, WeatherState>(
              builder: (context, state) {
                if (state is WeatherLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is WeatherLoaded) {
                  return RefreshIndicator(
                    onRefresh: () async {
                      context.read<WeatherBloc>().add(RefreshWeatherEvent());
                    },
                    child: ListView(
                      children: [
                        const SizedBox(height: 100),
                        Card(
                          margin: const EdgeInsets.all(20),
                          child: Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Column(
                              children: [
                                Text('Temperature: ${state.weather.temperature}°C',
                                    style: const TextStyle(fontSize: 24)),
                                const SizedBox(height: 10),
                                Text('Wind Speed: ${state.weather.windSpeed} km/h',
                                    style: const TextStyle(fontSize: 20)),
                                const SizedBox(height: 20),
                                const Text('Pull down to refresh!'),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                } else if (state is WeatherError) {
                  return Center(child: Text(state.message, style: const TextStyle(color: Colors.red)));
                }
                return const Center(child: Text('Start typing to search...'));
              },
            ),
          ),
        ],
      ),
    );
  }
}