import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert'; // For jsonDecode

void main() {
  runApp(const DictionaryApp());
}

class DictionaryApp extends StatelessWidget {
  const DictionaryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dictionary App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        // Use Material 3 design
        useMaterial3: true,
        // Define a modern color scheme
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.light,
        ),
        // Style text fields
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          filled: true,
          fillColor: Colors.grey[100],
        ),
        // Style buttons
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
          ),
        ),
      ),
      home: const DictionaryHomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class DictionaryHomePage extends StatefulWidget {
  const DictionaryHomePage({super.key});

  @override
  State<DictionaryHomePage> createState() => _DictionaryHomePageState();
}

class _DictionaryHomePageState extends State<DictionaryHomePage> {
  final TextEditingController _controller = TextEditingController();
  String _word = "";
  String _phonetic = "";
  String _definition = "";
  bool _isLoading = false;
  String _errorMessage = "";

  // Fetches the word definition from the free API
  Future<void> _searchWord() async {
    final String word = _controller.text.trim();
    if (word.isEmpty) {
      return;
    }

    // Update UI to show loading state
    setState(() {
      _isLoading = true;
      _errorMessage = "";
      _word = "";
      _phonetic = "";
      _definition = "";
    });

    // Free Dictionary API endpoint
    // https://dictionaryapi.dev/
    final String apiUrl =
        "https://api.dictionaryapi.dev/api/v2/entries/en/$word";

    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        // Successfully fetched the data
        final List<dynamic> data = json.decode(response.body);
        
        // Extract the first definition
        final wordData = data[0];
        final String fetchedWord = wordData['word'] ?? "N/A";
        final String fetchedPhonetic = wordData['phonetic'] ?? (wordData['phonetics']?.isNotEmpty == true ? wordData['phonetics'][0]['text'] : "N/A");
        final String fetchedDefinition = wordData['meanings']?[0]['definitions']?[0]['definition'] ?? "No definition found.";

        setState(() {
          _word = fetchedWord;
          _phonetic = fetchedPhonetic;
          _definition = fetchedDefinition;
        });

      } else if (response.statusCode == 404) {
        // Word not found
        setState(() {
          _errorMessage = "Sorry, the word '${_controller.text}' could not be found.";
        });
      } else {
        // Other server errors
        setState(() {
          _errorMessage = "An error occurred. Please try again.";
        });
      }
    } catch (e) {
      // Network or other exceptions
      setState(() {
        _errorMessage = "Failed to connect. Please check your internet connection.";
      });
    } finally {
      // Stop loading
      if(mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Flutter Dictionary',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        elevation: 2.0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Search Bar
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: 'Enter a word',
                      prefixIcon: Icon(Icons.search),
                    ),
                    onSubmitted: (value) => _searchWord(),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: _searchWord,
                  child: const Text('Search'),
                ),
              ],
            ),
            const SizedBox(height: 24.0),

            // Result Area
            Expanded(
              child: Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                  side: BorderSide(color: Colors.grey[300]!)
                ),
                color: Theme.of(context).colorScheme.surface,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: _buildResultWidget(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper widget to build the result display
  Widget _buildResultWidget() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage.isNotEmpty) {
      return Center(
        child: Text(
          _errorMessage,
          style: const TextStyle(color: Colors.red, fontSize: 16),
          textAlign: TextAlign.center,
        ),
      );
    }

    if (_word.isEmpty) {
      return const Center(
        child: Text(
          'Enter a word to see its definition.',
          style: TextStyle(fontSize: 18, color: Colors.grey),
          textAlign: TextAlign.center,
        ),
      );
    }

    // Display the found word and definition
    return ListView(
      children: [
        Text(
          _word,
          style: const TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          _phonetic,
          style: const TextStyle(
            fontSize: 18,
            fontStyle: FontStyle.italic,
            color: Colors.black54,
          ),
        ),
        const Divider(height: 32),
        const Text(
          'Definition',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          _definition,
          style: const TextStyle(fontSize: 18, height: 1.5),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}