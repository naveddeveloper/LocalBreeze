import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:localbreeze/providers/theme_provider.dart';
import 'package:localbreeze/providers/weather_provider.dart';
import 'package:localbreeze/screens/home_screen.dart';
import 'package:localbreeze/screens/weather_screen.dart';
import 'package:localbreeze/styles/theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final themeProvider = ThemeProvider();
  // Intialize the theme depends upon what the current time is!
  themeProvider.initialize();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => WeatherProvider()),
        ChangeNotifierProvider(create: (_) => themeProvider),
      ],
      child: const WeatherApp(),
    ),
  );
}

class WeatherApp extends StatelessWidget {
  const WeatherApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, value, child) {
        return MaterialApp(
          theme: lightTheme,
          darkTheme: darkTheme,
          themeMode: value.themeMode,
          debugShowCheckedModeBanner: false,
          home: const AnimatedSplashScreenHandler(),
        );
      },
    );
  }
}

class AnimatedSplashScreenHandler extends StatefulWidget {
  const AnimatedSplashScreenHandler({super.key});

  @override
  State<AnimatedSplashScreenHandler> createState() =>
      _AnimatedSplashScreenHandlerState();
}

class _AnimatedSplashScreenHandlerState
    extends State<AnimatedSplashScreenHandler> {
  late Future<void> _initializeFuture;
  late bool isDetected;

  @override
  void initState() {
    super.initState();
    _initializeFuture = _initializeApp();
  }

  Future<void> _initializeApp() async {
    try {
      final weatherProvider =
          Provider.of<WeatherProvider>(context, listen: false);
      isDetected = await weatherProvider.detectWeather(context);
    } catch (error) {
      debugPrint("Error initializing app: $error");
    }
  }

  @override
  Widget build(BuildContext context) {
    var themeMode = Provider.of<ThemeProvider>(context).themeMode;

    return FutureBuilder(
      future: _initializeFuture,
      builder: (context, snapshot) {
        // If it done then return the animated splash screen
        if (snapshot.connectionState == ConnectionState.done) {
          return AnimatedSplashScreen(
              duration: 3000,
              splash: Center(
                child: themeMode == ThemeMode.dark
                    ? LottieBuilder.asset(
                        "assets/json-lottie/weathernightsplashscreen.json")
                    : LottieBuilder.asset(
                        "assets/json-lottie/weatherlightsplashscreen.json"),
              ),
              nextScreen:
                  isDetected ? const WeatherScreen() : const HomeScreen(),
              splashTransition: SplashTransition.fadeTransition,
              backgroundColor: Theme.of(context).primaryColor,
              splashIconSize: 700);
        }

        // Display loading screen while initializing
        return Scaffold(
          backgroundColor: Theme.of(context).primaryColor,
          body: Center(
              child: themeMode == ThemeMode.dark ? LottieBuilder.asset(
                      "assets/json-lottie/weathernightsplashscreen.json")
                  : LottieBuilder.asset(
                      "assets/json-lottie/weatherlightsplashscreen.json")),
        );
      },
    );
  }
}
