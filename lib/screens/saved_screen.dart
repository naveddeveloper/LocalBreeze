import 'package:flutter/material.dart';
import 'package:localbreeze/widgets/custom_icon.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:localbreeze/providers/weather_provider.dart';

class SavedScreen extends StatefulWidget {
  const SavedScreen({super.key});

  @override
  State<SavedScreen> createState() => _SavedScreenState();
}

class _SavedScreenState extends State<SavedScreen> {
  late BuildContext safeContext;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    safeContext = context;
  }

  @override
  Widget build(BuildContext context) {
    Brightness brightness = Theme.of(context).brightness;

    return Consumer<WeatherProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return Scaffold(
            backgroundColor: Theme.of(context).primaryColor,
            body: Center(
              child: LottieBuilder.asset("assets/json-lottie/loading.json"),
            ),
          );
        }

        if (provider.weatherLocationSaved.isEmpty) {
          return Scaffold(
            backgroundColor: Theme.of(context).primaryColor,
            body: SafeArea(
                child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0),
                    child: Column(
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Container(
                              alignment: Alignment.topLeft,
                              child: Icon(Icons.arrow_back_ios),
                            ),
                          ),
                        ),
                        Center(
                          child: LottieBuilder.asset(
                              "assets/json-lottie/not-found.json"),
                        )
                      ],
                    ))),
          );
        }

        return Scaffold(
          backgroundColor: Theme.of(context).primaryColor,
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: Column(
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        alignment: Alignment.topLeft,
                        child: Icon(Icons.arrow_back_ios),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20.0),
                    child: const Center(
                      child: Text(
                        "Manage Cities",
                        style: TextStyle(
                          fontFamily: "Kodchasan",
                          fontSize: 30,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: provider.weatherLocationSaved.length,
                      itemBuilder: (context, index) {
                        final cityWeather =
                            provider.weatherLocationSaved[index];

                        return GestureDetector(
                          onTap: () {
                            provider.fetchWeatherCity(
                                cityWeather["location"]["name"], safeContext);
                          },
                          child: Container(
                              padding: const EdgeInsets.all(10.0),
                              margin:
                                  const EdgeInsets.symmetric(vertical: 12.0),
                              height: 100,
                              decoration: BoxDecoration(
                                  color: brightness == Brightness.dark
                                      ? Colors.black.withValues(alpha: .6)
                                      : Colors.white.withValues(alpha: .5),
                                  borderRadius: BorderRadius.circular(20.0),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(
                                          alpha: 0.1), // Subtle shadow color
                                      blurRadius:
                                          4, // Minimal blur for a soft shadow
                                      spreadRadius: 0, // No extra spread
                                      offset: Offset(0,
                                          2), // Only a small shadow at the bottom
                                    ),
                                  ]),
                              // ignore: unnecessary_null_comparison
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        cityWeather["location"]["name"],
                                        style: const TextStyle(
                                          fontFamily: "Kodchasan",
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 4.0),
                                        child: Text(
                                          cityWeather["location"]["region"],
                                          style: const TextStyle(
                                            fontFamily: "Sansation",
                                            fontSize: 14,
                                            fontWeight: FontWeight.w400,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Text(
                                        "${cityWeather["current"]["temp_c"]}°C",
                                        style: const TextStyle(
                                          fontFamily: "SpaceMono",
                                          fontSize: 20,
                                          fontWeight: FontWeight.w900,
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 4.0),
                                        child: Image.asset(
                                          getWeatherIcon(
                                              cityWeather["current"]
                                                  ["condition"]["code"],
                                              context),
                                          width: 60,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              )),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
