import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

// Enter your API key here.
const String OPENWEATHER_API_KEY = 'YOUR_API_KEY';


// ------------------------- Data model -------------------------
class WeatherData {
  final String cityName;
  final double temperature;
  final int humidity;
  final String description;

  WeatherData({
    required this.cityName,
    required this.temperature,
    required this.humidity,
    required this.description,
  });

  factory WeatherData.fromJson(Map<String, dynamic> json) {
    if (!json.containsKey('name') ||
        !json.containsKey('main') ||
        !json.containsKey('weather') ||
        (json['weather'] as List?)?.isEmpty == true) {
      throw FormatException('API response has invalid structure');
    }

    final main = json['main'] as Map<String, dynamic>;
    final weatherList = json['weather'] as List<dynamic>;
    final weather = weatherList.first as Map<String, dynamic>;

    return WeatherData(
      cityName: json['name'] as String,
      temperature: (main['temp'] as num).toDouble(),
      humidity: main['humidity'] as int,
      description: weather['description'] as String,
    );
  }

  @override
  String toString() {
    return '''
┌───────────────────────────────
│ 🌍 City: $cityName
│ 🌡️ Temperature: ${temperature.toStringAsFixed(1)}°C
│ 💧 Humidity: $humidity%
│ ☁️ Description: $description
└───────────────────────────────
''';
  }
}

// ------------------------- Weather service -------------------------
class CityNotFoundException implements Exception {
  final String message;
  CityNotFoundException(this.message);
  @override
  String toString() => message;
}

class WeatherService {
  static const String _baseUrl =
      'https://api.openweathermap.org/data/2.5/weather';

  Future<WeatherData> getWeather(String cityName) async {
    final uri = Uri.parse(_baseUrl).replace(queryParameters: {
      'q': cityName,
      'appid': OPENWEATHER_API_KEY,
      'units': 'metric',
    });

    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final Map<String, dynamic> json = jsonDecode(response.body);
      return WeatherData.fromJson(json);
    } else if (response.statusCode == 404) {
      throw CityNotFoundException('City "$cityName" not found');
    } else if (response.statusCode == 401) {
      throw Exception('The API key is invalid. Please check the key.');
    } else {
      throw Exception('Unknown error from server: ${response.statusCode}');
    }
  }
}

// ------------------------- Favorites Storage-------------------------
class FavoritesStorage {
  final String _filePath;

  FavoritesStorage({String? filePath})
      : _filePath = filePath ?? '${Directory.current.path}/favorites.json';

  Future<List<String>> loadFavorites() async {
    final file = File(_filePath);
    if (!await file.exists()) {
      return [];
    }
    try {
      final contents = await file.readAsString();
      final List<dynamic> jsonList = jsonDecode(contents);
      return jsonList.map((e) => e as String).toList();
    } catch (e) {
      await file.writeAsString('[]');
      return [];
    }
  }

  Future<void> saveFavorites(List<String> cities) async {
    final file = File(_filePath);
    final jsonString = jsonEncode(cities);
    await file.writeAsString(jsonString);
  }

  Future<void> addFavorite(String city) async {
    final favorites = await loadFavorites();
    if (!favorites.contains(city)) {
      favorites.add(city);
      await saveFavorites(favorites);
    }
  }

  Future<void> removeFavorite(String city) async {
    final favorites = await loadFavorites();
    favorites.remove(city);
    await saveFavorites(favorites);
  }
}

// ------------------------- Main program -------------------------
Future<void> main() async {
  final weatherService = WeatherService();
  final favoritesStorage = FavoritesStorage();

  while (true) {
    print('\n═══ Weather menu ═══');
    print('1. View the status of a city');
    print('2. Favorite Cities');
    print('3. Add a city to favorites');
    print('4. Exit');
    stdout.write('Enter the desired option: ');
    final choice = stdin.readLineSync()?.trim();

    switch (choice) {
      case '1':
        await _showWeather(weatherService, favoritesStorage);
        break;
      case '2':
        await _manageFavorites(weatherService, favoritesStorage);
        break;
      case '3':
        await _addToFavorites(favoritesStorage, weatherService);
        break;
      case '4':
        print('Good Bye!');
        return;
      default:
        print('Invalid option. Please enter a number between 1 and 4.');
    }
  }
}

Future<void> _showWeather(
    WeatherService weatherService, FavoritesStorage storage) async {
  stdout.write('Enter city name: ');
  final city = stdin.readLineSync()?.trim();
  if (city == null || city.isEmpty) {
    print('City name cannot be empty.');
    return;
  }

  try {
    print('Receiving information...');
    final weather = await weatherService.getWeather(city);
    print(weather);

    stdout.write('Do you want to add this city to your favorites? (y/n): ');
    final addChoice = stdin.readLineSync()?.trim().toLowerCase();
    if (addChoice == 'y') {
      await storage.addFavorite(city);
      print('$city added to favorites.');
    }
  } on CityNotFoundException catch (e) {
    print(e);
  } on FormatException catch (e) {
    print('Error processing data: $e');
  } catch (e) {
    print('Error retrieving information: $e');
  }
}

Future<void> _manageFavorites(
    WeatherService weatherService, FavoritesStorage storage) async {
  final favorites = await storage.loadFavorites();
  if (favorites.isEmpty) {
    print('You have not saved a city yet.');
    return;
  }

  print('Favorite cities:');
  for (var i = 0; i < favorites.length; i++) {
    print('${i + 1}. ${favorites[i]}');
  }
  stdout.write('City number to view status (or 0 to return): ');
  final indexStr = stdin.readLineSync();
  final index = int.tryParse(indexStr ?? '');
  if (index == null || index < 0 || index > favorites.length) {
    print('Invalid input.');
    return;
  }
  if (index == 0) return;

  final city = favorites[index - 1];
  try {
    final weather = await weatherService.getWeather(city);
    print(weather);
    stdout.write('Do you want to remove this city from the list? (y/n): ');
    final delChoice = stdin.readLineSync()?.trim().toLowerCase();
    if (delChoice == 'y') {
      await storage.removeFavorite(city);
      print('$city removed from list.');
    }
  } catch (e) {
    print('Error getting city status: $e');
  }
}

Future<void> _addToFavorites(
    FavoritesStorage storage, WeatherService weatherService) async {
  stdout.write('Name of the city you want to add: ');
  final city = stdin.readLineSync()?.trim();
  if (city == null || city.isEmpty) {
    print('City name cannot be empty.');
    return;
  }

  try {
    await weatherService.getWeather(city);
    await storage.addFavorite(city);
    print('$city successfully added to favorites.');
  } on CityNotFoundException {
    print(
        'The city "$city" was not found. But it was added to the list anyway.');
    await storage.addFavorite(city);
  } catch (e) {
    print('Error checking city: $e');
  }
}
