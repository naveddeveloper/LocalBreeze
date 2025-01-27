import 'package:flutter/material.dart';
import 'package:localbreeze/widgets/custom_toast.dart';
import 'package:provider/provider.dart';
import 'package:localbreeze/providers/theme_provider.dart';
import 'package:localbreeze/providers/weather_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late TextEditingController _weatherText;

  @override
  void initState() {
    super.initState();
    _weatherText = TextEditingController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _weatherText.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var weatherProvider = Provider.of<WeatherProvider>(context);
    var themeMode = Provider.of<ThemeProvider>(context).themeMode;

    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0),
          child: Column(
            children: [
              // Image
              Container(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment.center, // Center of the gradient
                    radius: 1.0, // Gradient radius
                    colors: [
                      Theme.of(context).splashColor, // rgba(0, 212, 255, 1)
                      Colors
                          .transparent, // rgba(9, 9, 121, 0.15021008403361347)
                    ],
                    stops: themeMode == ThemeMode.dark
                        ? [0.0, 0.47]
                        : [0.0, 0.30], // Stops for the gradient
                  ),
                ),
                child: themeMode == ThemeMode.dark
                    ? Image.asset("assets/icons/dark/night.png")
                    : Image.asset("assets/icons/light/sunny.png"),
              ),
              // App Title
              Container(
                padding: EdgeInsets.only(bottom: 30.0),
                alignment: Alignment.center,
                child: Center(
                  child: Text(
                    "WeatherApp",
                    style: TextStyle(
                        color: Theme.of(context).hintColor,
                        fontSize: 45,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Kodchasan'),
                  ),
                ),
              ),
              // InputBar
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _weatherText,
                      cursorColor: Theme.of(context).hintColor,
                      decoration: InputDecoration(
                        suffixIcon: IconButton(
                          icon: Icon(Icons.arrow_forward_ios,
                              size: 16,
                              color: Theme.of(context).primaryColorLight),
                          onPressed: () {
                            final input = _weatherText.text.trim();

                            if (input.isEmpty) {
                              // Handle empty input case if needed
                              showCustomToast(context, "Please enter a valid city name");
                            } else {
                              // Input is a string (city name)
                              weatherProvider.fetchWeatherCity(input, context);
                            }
                          },
                        ),
                        prefixIcon: IconButton(
                          onPressed: () {},
                          icon: Icon(Icons.search,
                              size: 24,
                              color: Theme.of(context).primaryColorLight),
                        ),
                        hintText: "Search...",
                        hintStyle: TextStyle(
                            color: Theme.of(context).primaryColorLight,
                            fontFamily: 'Kodchasan'),
                        filled: true,
                        fillColor: Theme.of(context).splashColor,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical:
                                15), // Adjust padding for better alignment
                      ),
                      style:
                          TextStyle(color: Theme.of(context).primaryColorLight),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
