import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:convert';

Future<void> main() async {
  // Load environment variables before app starts
  await dotenv.load(fileName: ".env");
  runApp(const WeatherApp());
}

class WeatherApp extends StatelessWidget {
  const WeatherApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Weather App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const WeatherHome(),
    );
  }
}

class WeatherHome extends StatefulWidget {
  const WeatherHome({super.key});

  @override
  State<WeatherHome> createState() => _WeatherHomeState();
}

class _WeatherHomeState extends State<WeatherHome> {
  final TextEditingController _controller = TextEditingController();
  Map<String, dynamic>? weatherData;
  bool isLoading = false;
  String? errorMessage;

  Future<void> fetchWeather(String city) async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    final apiKey = dotenv.env['API_KEY']; // Securely loaded from .env
    final url = Uri.parse(
      "https://api.openweathermap.org/data/2.5/weather?q=$city&appid=$apiKey&units=metric",
    );

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        setState(() {
          weatherData = json.decode(response.body);
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = "City not found!";
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = "Failed to connect. Check your internet connection.";
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("🌦️ Weather App"), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: "Enter city name",
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () {
                    if (_controller.text.isNotEmpty) {
                      fetchWeather(_controller.text.trim());
                    }
                  },
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 20),
            if (isLoading)
              const CircularProgressIndicator()
            else if (errorMessage != null)
              Text(
                errorMessage!,
                style: const TextStyle(color: Colors.red, fontSize: 18),
              )
            else if (weatherData != null)
              WeatherCard(data: weatherData!),
          ],
        ),
      ),
    );
  }
}

class WeatherCard extends StatelessWidget {
  final Map<String, dynamic> data;

  const WeatherCard({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final city = data['name'];
    final temp = data['main']['temp'].toString();
    final description = data['weather'][0]['description'];
    final icon = data['weather'][0]['icon'];

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 6,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Text(
              city,
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Image.network(
              "https://openweathermap.org/img/wn/$icon@2x.png",
              width: 80,
              height: 80,
            ),
            Text(
              "$temp°C",
              style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold),
            ),
            Text(
              description.toUpperCase(),
              style: const TextStyle(fontSize: 18, letterSpacing: 1.2),
            ),
          ],
        ),
      ),
    );
  }
}
