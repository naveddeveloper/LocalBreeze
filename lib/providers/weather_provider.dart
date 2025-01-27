import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:localbreeze/widgets/custom_toast.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;
import 'package:localbreeze/screens/weather_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WeatherProvider extends ChangeNotifier {
  // Variables
  late dynamic _weatherData; // to store the weather data
  late bool _isLoading; // a loading state
  late List<Map<String, dynamic>> _weatherLocationSaved = []; // saved location data 

  // Getter
  dynamic get weatherData => _weatherData;
  bool get isLoading => _isLoading;
  List<Map<String, dynamic>> get weatherLocationSaved => _weatherLocationSaved;

  static const String APIKEY = 'c014ca23bca74b9f82f130128222406';
  static const String APIURLCURRENT =
      'http://api.weatherapi.com/v1/current.json';
  static const String APIURLFORECAST =
      'http://api.weatherapi.com/v1/forecast.json';

  WeatherProvider() {
    _isLoading = false;
    _loadWeatherDataFromPrefs();
  }

  // Load weather data from SharedPreferences
  Future<void> _loadWeatherDataFromPrefs() async {
    try {
      _isLoading = true;
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? jsonString = prefs.getString('weatherLocationSaved');
      if (jsonString != null) {
        _weatherLocationSaved =
            List<Map<String, dynamic>>.from(jsonDecode(jsonString));
        _isLoading = false;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('ERROR loadWeatherDataFromPrefs :: WeatherProvider $e');
    }
  }

  // Detect the wheather depends on your permissions
  Future<bool> detectWeather(BuildContext context) async {
    try {
      _isLoading = true;

      // Check permission for location
      if (await _checkLocationPermission()) {
        // Get the current location
        Position position = await _getUserLocation();

        // Fetch the weather data
        _weatherData =
            await _fetchWeatherData(position.latitude, position.longitude);
        // Set loading to false and notify listeners
        _isLoading = false;

        showCustomToast(context, "Loaded Weather Data Successfully");
        notifyListeners();
        return true;
      } else {
        showCustomToast(context, "Allow the permission of location");
        openAppSettings();
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      showCustomToast(context, 'ERROR DetectWeather :: WeatherProvider $e');
      debugPrint('ERROR DetectWeather :: WeatherProvider $e');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Check the permission of your location
  Future<bool> _checkLocationPermission() async {
    try {
      PermissionStatus status = await Permission.location.request();
      if (status.isGranted) {
        return true;
      } else {
        PermissionStatus newStatus = await Permission.location.request();
        if (newStatus.isGranted) {
          return true;
        } else if (newStatus.isDenied) {
          openAppSettings();
          return false;
        } else if (newStatus.isPermanentlyDenied) {
          openAppSettings();
          return false;
        }
      }
    } catch (e) {
      debugPrint("ERROR CheckLocationPermission :: WeatherProvider $e");
    }
    return false;
  }

  // Function to get the user's current location
  Future<Position> _getUserLocation() async {
    LocationSettings locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high, // High accuracy
      distanceFilter: 100, // Minimum distance (in meters) to receive updates
    );

    // Request the current position with the new settings parameter
    return await Geolocator.getCurrentPosition(
      locationSettings: locationSettings, // Use the settings parameter
    );
  }

  // Function to fetch weather data from OpenWeather API
  Future<dynamic> _fetchWeatherData(double latitude, double longitude) async {
    try {
      final response = await http.get(
        Uri.parse(
            '$APIURLFORECAST?key=$APIKEY&q=$latitude,$longitude&days=7&aqi=yes'),
      );

      if (response.statusCode == 200) {
        // Parse the JSON response
        return jsonDecode(response.body);
      } else {
        debugPrint("Failed to load wheather data");
        throw Exception('Failed to load weather data');
      }
    } on SocketException catch (e) {
      debugPrint('Could\'not connect to weather server socketexception: $e');
    } catch (e) {
      debugPrint("ERROR FetchWeatherData :: WeatherProvider $e");
    }
  }

  Future<void> fetchWeatherCity(String city, context) async {
    try {
      _isLoading = true;
      notifyListeners();

      final response = await http
          .get(Uri.parse('$APIURLFORECAST?key=$APIKEY&q=$city&days=7&aqi=yes'));
      if (response.statusCode == 200) {
        _weatherData = jsonDecode(response.body);
        _isLoading = false;
        notifyListeners();
        
        // Navigate to WeatherScreen here
        // Check if the widget is still mounted before navigation or actions
        if (context.mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const WeatherScreen()),
          );
        }
      } else {
        _isLoading = false;
        showCustomToast(context, "No City Found with this name!");
        notifyListeners();
        throw Exception("Failed to load weather data");
      }
    } catch (e) {
      _isLoading = false;
      debugPrint('ERROR FetchWeatherCity :: WeatherProvider $e');
    }
  }

  // Check if the weatherLocationSaved has contains the weatherData
  bool isFavorites(Map<String, dynamic> weatherData) {
    try {
      if (_weatherLocationSaved.isEmpty) {
        return false;
      } else {
        if (_weatherLocationSaved.any((data) =>
            data['location']["name"] == weatherData["location"]['name'])) {
          debugPrint("Data Saved");
          return true; // Persist the updated list
        } else {
          debugPrint("Data not saved");
          return false;
        }
      }
    } catch (e) {
      debugPrint("ERROR isFavorites :: WeatherProvider $e");
    }
    return false;
  }

  // Toggle the if data contains then remove that and add that
  Future<void> toggleFavorite(dynamic weatherData) async {
    try {
      addWeatherData(weatherData);
      notifyListeners();
    } catch (e) {
      debugPrint('ERROR toggleProvider :: WeatherProvider $e');
    }
  }

  // Add a WeatherData object if not already in the list
  Future<void> addWeatherData(Map<String, dynamic> weatherData) async {
    try {
      if (!isFavorites(weatherData)) {
        _weatherLocationSaved.add(weatherData);
        await _saveWeatherDataToPrefs(); // Persist the updated list
        notifyListeners();
      } else {
        _weatherLocationSaved.removeWhere((data) {
          // data['location']['name'] == 'Maxico'
          return data["location"]["name"] == weatherData["location"]["name"];
        });
        _weatherLocationSaved.remove(weatherData);
      }
    } catch (e) {
      debugPrint('ERROR addWeatherData :: WeatherProvider $e');
    }
  }

  // Save weather data to SharedPreferences
  Future<void> _saveWeatherDataToPrefs() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String jsonString = jsonEncode(_weatherLocationSaved);
      await prefs.setString('weatherLocationSaved', jsonString);
    } catch (e) {
      debugPrint('ERROR saveWeatherDataToPrefs :: WeatherProvider $e');
    }
  }
}
