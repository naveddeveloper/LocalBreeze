import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:localbreeze/screens/home_screen.dart';
import 'package:localbreeze/widgets/custom_toast.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:localbreeze/providers/weather_provider.dart';
import 'package:localbreeze/screens/saved_screen.dart';
import 'package:localbreeze/utils/time_formatting.dart';
import 'package:localbreeze/widgets/custom_icon.dart';

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Consumer<WeatherProvider>(
      builder: (context, value, child) {

        if(value.isLoading){
          return Scaffold(
            backgroundColor: Theme.of(context).primaryColor,
            body: Center(
              child: LottieBuilder.asset("assets/json-lottie/loading.json"),
            ),
          );
        }

        if(value.weatherData == null){
          return Scaffold(
            backgroundColor: Theme.of(context).primaryColor,
            body: Center(
              child: LottieBuilder.asset("assets/json-lottie/not-found.json"),
            ),
          );
        }

        final List<dynamic> forecastData =
            value.weatherData["forecast"]["forecastday"] ?? [];
        final List<dynamic> hourlyForecast =
            value.weatherData["forecast"]["forecastday"][0]["hour"] ?? [];
        final DateTime currentTime = DateTime.now();

        // Filter for remaining hours
        final List<dynamic> remainingForecast = hourlyForecast.where((hour) {
          DateTime forecastTime = DateTime.parse(hour["time"]);
          return forecastTime.isAfter(currentTime);
        }).toList();

        return Scaffold(
          backgroundColor: Theme.of(context).primaryColor,
          body: SafeArea(
            child: RefreshIndicator(
              color: Theme.of(context).hintColor,
              elevation: 3.0,
              onRefresh: () async {
                value.fetchWeatherCity(
                  value.weatherData["location"]["name"],
                  context,
                );
                showCustomToast(context, "Refresh wheather");
              },
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  child: Column(
                    children: [
                      topNavigationBar(context, value),
                      textDetectWeather(value),
                      shadowAndImage(size, value, context),
                      temperatureAndClear(value),
                      // Special Boxes!
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                buildWeatherCard(
                                  context,
                                  icon: FontAwesomeIcons.wind,
                                  label: "Wind",
                                  value: value.weatherData["current"]
                                          ["wind_kph"]
                                      .toString(),
                                  symbol: "km/h",
                                ),
                                buildWeatherCard(
                                  context,
                                  icon: Icons.light_mode,
                                  label: "Index UV",
                                  value: value.weatherData["current"]["uv"]
                                      .toString(),
                                  symbol: "",
                                ),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                buildWeatherCard(
                                  context,
                                  icon: FontAwesomeIcons.temperatureHalf,
                                  label: "Temperature",
                                  value: value.weatherData["current"]["temp_c"]
                                      .toString(),
                                  symbol: "°C",
                                ),
                                buildWeatherCard(
                                  context,
                                  icon: FontAwesomeIcons.droplet,
                                  label: "Humidity",
                                  value: value.weatherData["current"]
                                          ["humidity"]
                                      .toString(),
                                  symbol: "",
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      // Hourly Forecast Section
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "24-Hour Forecast",
                              style: TextStyle(
                                  fontFamily: "Kodchasan",
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 10),
                            SizedBox(
                              height: 150,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: remainingForecast.length,
                                itemBuilder: (context, index) {
                                  final hour = remainingForecast[index];
                                  return buildForecastCardHour(hour);
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Daily Forecast Section
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Forecast",
                              style: TextStyle(
                                  fontFamily: "Kodchasan",
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 10),
                            SizedBox(
                              height: 150,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: forecastData.length,
                                itemBuilder: (context, index) {
                                  final day = forecastData[index];
                                  return buildForecastCard(day);
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // Top Navigation Bar
  Widget topNavigationBar(BuildContext context, WeatherProvider value) {  
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Text(
                value.weatherData["location"]["name"].length > 12 ? '${value.weatherData["location"]["name"].substring(0, 12)}, ' : '${value.weatherData["location"]["name"]}, ',
                style: const TextStyle(
                    fontFamily: "Kodchasan",
                    fontSize: 18,
                    fontWeight: FontWeight.w600),
              ),
              Text(
                value.weatherData["location"]["region"].length > 15
                    ? '${value.weatherData["location"]["region"].substring(0, 15)}...'
                    : value.weatherData["location"]["region"],
                style: const TextStyle(
                    fontFamily: "Kodchasan",
                    fontSize: 16,
                    fontWeight: FontWeight.w300),
              ),
            ],
          ),
          Row(
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => HomeScreen()));
                },
                child: FaIcon(FontAwesomeIcons.magnifyingGlass,
                        size: 25, color: Theme.of(context).hintColor),
              ),
              GestureDetector(
                onTap: () {
                  value.toggleFavorite(value.weatherData);
                },
                child: Padding(
                  padding: EdgeInsets.only(left: 12.0),
                  child: value.isFavorites(value.weatherData)
                    ? FaIcon(FontAwesomeIcons.solidStar,
                        size: 25, color: Theme.of(context).hintColor)
                    : FaIcon(
                        FontAwesomeIcons.star,
                        size: 25,
                        color: Theme.of(context).hintColor,
                      ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const SavedScreen()),
                  );
                },
                child: Padding(
                  padding: EdgeInsets.only(left: 12.0),
                  child: FaIcon(Icons.location_on,
                      size: 30, color: Theme.of(context).hintColor),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Text and Detect Weather
  Widget textDetectWeather(WeatherProvider value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          formatLocalTime(
              value.weatherData["location"]["localtime"].toString()),
          style: TextStyle(
              fontFamily: "Sansation",
              color: Colors.grey.shade500,
              fontSize: 20,
              fontWeight: FontWeight.w400),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: GestureDetector(
            onTap: () async {
              await value.detectWeather(context);
            },
            child: Icon(FontAwesomeIcons.locationCrosshairs,
                size: 20, color: Colors.grey.shade500),
          ),
        ),
      ],
    );
  }

  // Shadow and Image
  Widget shadowAndImage(Size size, value, context) {
    return Container(
      width: size.width,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        gradient: RadialGradient(
          center: Alignment.center, // Center of the gradient
          radius: 1.0, // Gradient radius
          colors: [
            Theme.of(context).splashColor, // rgba(0, 212, 255, 1)
            Colors.transparent, // rgba(9, 9, 121, 0.15021008403361347)
          ],
          stops: Theme.of(context).brightness == Brightness.dark
              ? [0.0, 0.47]
              : [0.0, 0.30], // Stops for the gradient
        ),
      ),
      child: Image.asset(getWeatherIcon(
          value.weatherData["current"]["condition"]["code"], context)),
    );
  }

  // Temperature and Clear
  Widget temperatureAndClear(WeatherProvider value) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              value.weatherData["current"]["temp_c"].toString(),
              style: const TextStyle(
                  fontFamily: "SpaceMono",
                  fontSize: 80,
                  fontWeight: FontWeight.bold),
            ),
            const Text("°C",
                style: TextStyle(fontSize: 50, fontWeight: FontWeight.w300)),
          ],
        ),
        Text(
          value.weatherData["current"]["condition"]["text"],
          style: TextStyle(
              fontFamily: "Sansation",
              fontSize: 30,
              fontWeight: FontWeight.w200,
              color: Colors.grey.shade500),
        ),
      ],
    );
  }

  // Weather Card
  Widget buildWeatherCard(BuildContext context,
      {required IconData icon,
      required String label,
      required String value,
      required String symbol}) {
    return Container(
      width: 150,
      margin: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 6.0),
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 20.0),
      decoration: BoxDecoration(
        color: Theme.of(context).splashColor,
        borderRadius: BorderRadius.circular(20.0),
      ),
      child: Row(
        children: [
          Icon(icon, size: 30),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: const TextStyle(
                      fontFamily: "Sansation",
                      fontSize: 13,
                      fontWeight: FontWeight.w300)),
              const SizedBox(height: 4),
              Text('$value $symbol',
                  style: const TextStyle(
                      fontFamily: "Sansation",
                      fontSize: 16,
                      fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }

  // Forecast Card
  Widget buildForecastCard(dynamic day) {
    return Container(
      width: 120,
      margin: const EdgeInsets.only(right: 12.0),
      padding: const EdgeInsets.all(10.0),
      decoration: BoxDecoration(
        color: Theme.of(context).splashColor,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        children: [
          Text(
            convertDateFormat(day["date"]),
            style: const TextStyle(
                fontFamily: "Sansation",
                fontSize: 14,
                fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Image.asset(
            getWeatherIcon(day["day"]["condition"]["code"], context),
            height: 50,
            width: 50,
          ),
          const SizedBox(height: 8),
          Text(
            "Max: ${day["day"]["maxtemp_c"]}°C",
            style: const TextStyle(
                fontFamily: "SpaceMono",
                fontSize: 16,
                fontWeight: FontWeight.w600),
          ),
          Text(
            "Min: ${day["day"]["mintemp_c"]}°C",
            style: const TextStyle(
                fontFamily: "SpaceMono", fontSize: 14, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  // Hourly Forecast Card
  Widget buildForecastCardHour(dynamic hour) {
    return Container(
      width: 120,
      margin: const EdgeInsets.only(right: 12.0),
      padding: const EdgeInsets.all(10.0),
      decoration: BoxDecoration(
        color: Theme.of(context).splashColor,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        children: [
          Text(
            formatLocalTime(hour["time"].toString()),
            style: const TextStyle(
                fontFamily: "Sansation",
                fontSize: 14,
                fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Image.asset(
            getWeatherIconBasedTime(
                hour["condition"]["code"], context, hour["time"].toString()),
            height: 50,
            width: 50,
          ),
          const SizedBox(height: 8),
          Text(
            "${hour["temp_c"]}°C",
            style: const TextStyle(
                fontFamily: "SpaceMono",
                fontSize: 16,
                fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
