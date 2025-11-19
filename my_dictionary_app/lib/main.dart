import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:audioplayers/audioplayers.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
// Helper for date formatting if needed, but standard flutter is fine

// --- Model Classes ---
class WordDefinition {
  final String word;
  final String? phonetic;
  final String? audioUrl;
  final List<Meaning> meanings;

  WordDefinition({
    required this.word,
    this.phonetic,
    this.audioUrl,
    required this.meanings,
  });

  factory WordDefinition.fromJson(Map<String, dynamic> json) {
    String? audioUrl;
    String? phoneticText = json['phonetic'];

    if (json['phonetics'] != null && (json['phonetics'] as List).isNotEmpty) {
      if (phoneticText == null || phoneticText.isEmpty) {
         phoneticText = json['phonetics'][0]['text'];
      }
      for (var phonetic in json['phonetics']) {
        if (phonetic['audio'] != null && phonetic['audio'].isNotEmpty) {
          audioUrl = phonetic['audio'];
          phoneticText = phonetic['text'] ?? phoneticText; 
          break;
        }
      }
    }

    return WordDefinition(
      word: json['word'] ?? 'No word',
      phonetic: phoneticText,
      audioUrl: audioUrl,
      meanings: (json['meanings'] as List<dynamic>? ?? [])
          .map((m) => Meaning.fromJson(m))
          .toList(),
    );
  }
}

class Meaning {
  final String partOfSpeech;
  final List<Definition> definitions;

  Meaning({required this.partOfSpeech, required this.definitions});

  factory Meaning.fromJson(Map<String, dynamic> json) {
    return Meaning(
      partOfSpeech: json['partOfSpeech'] ?? 'Unknown',
      definitions: (json['definitions'] as List<dynamic>? ?? [])
          .map((d) => Definition.fromJson(d))
          .toList(),
    );
  }
}

class Definition {
  final String definition;
  final String? example;

  Definition({required this.definition, this.example});

  factory Definition.fromJson(Map<String, dynamic> json) {
    return Definition(
      definition: json['definition'] ?? 'No definition',
      example: json['example'],
    );
  }
}

// --- Main Application ---

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp();
    runApp(const MyApp());
  } catch (e) {
    runApp(ErrorApp(errorMessage: e.toString()));
  }
}

class ErrorApp extends StatelessWidget {
  final String errorMessage;
  const ErrorApp({super.key, required this.errorMessage});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.red[100],
        body: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              const Text(
                'Startup Error',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.red),
              ),
              const SizedBox(height: 16),
              Text(
                errorMessage,
                style: const TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Dictionary',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.light,
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.grey[200],
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        ),
      ),
      home: const AuthGate(),
      debugShowCheckedModeBanner: false,
    );
  }
}

// --- Authentication ---

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return const MainScreen(); // Changed to MainScreen for Tabs
        }
        return const LoginScreen();
      },
    );
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLogin = true; 
  String? _errorMessage;

  Future<void> _authenticate() async {
    FocusScope.of(context).unfocus();
    setState(() => _errorMessage = null);
    try {
      if (_isLogin) {
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
      } else {
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
      }
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      setState(() => _errorMessage = e.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Icon(
                Icons.book,
                size: 80,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 20),
              Text(
                _isLogin ? 'Welcome Back' : 'Create Account',
                style: Theme.of(context).textTheme.headlineMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.email),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _passwordController,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  prefixIcon: Icon(Icons.lock),
                ),
                obscureText: true,
              ),
              if (_errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: Text(
                    _errorMessage!,
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: _authenticate,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(_isLogin ? 'Login' : 'Sign Up'),
                ),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => setState(() => _isLogin = !_isLogin),
                child: Text(_isLogin
                    ? 'Need an account? Sign Up'
                    : 'Already have an account? Login'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// --- Main Screen with Tabs ---

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  
  // Key to control the SearchTab from other tabs
  final GlobalKey<_SearchTabState> _searchTabKey = GlobalKey();

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  void _navigateToSearch(String word) {
    setState(() {
      _currentIndex = 0;
    });
    // Wait for the tab to switch then search
    Future.delayed(const Duration(milliseconds: 100), () {
       _searchTabKey.currentState?.searchExternal(word);
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> tabs = [
      SearchTab(key: _searchTabKey),
      ListTab(collectionName: 'favorites', title: 'Favorites', onWordTap: _navigateToSearch),
      ListTab(collectionName: 'history', title: 'History', onWordTap: _navigateToSearch),
      const ProfileTab(),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: tabs,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: _onItemTapped,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.search),
            label: 'Search',
          ),
          NavigationDestination(
            icon: Icon(Icons.favorite),
            label: 'Favorites',
          ),
          NavigationDestination(
            icon: Icon(Icons.history),
            label: 'History',
          ),
          NavigationDestination(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

// --- 1. Search Tab ---

class SearchTab extends StatefulWidget {
  const SearchTab({super.key});

  @override
  State<SearchTab> createState() => _SearchTabState();
}

class _SearchTabState extends State<SearchTab> {
  final TextEditingController _searchController = TextEditingController();
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isLoading = false;
  String? _errorMessage;
  WordDefinition? _wordDefinition;
  final User? user = FirebaseAuth.instance.currentUser;

  // Allow parent to trigger search
  void searchExternal(String word) {
    _searchController.text = word;
    _searchWord();
  }

  Future<void> _searchWord() async {
    final String word = _searchController.text.trim();
    if (word.isEmpty) return;

    FocusScope.of(context).unfocus();

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _wordDefinition = null;
    });

    try {
      final Uri uri = Uri.parse('https://api.dictionaryapi.dev/api/v2/entries/en/$word');
      final response = await http.get(uri);

      if (!mounted) return;

      if (response.statusCode == 200) {
        final List<dynamic> jsonResponse = json.decode(response.body);
        final definition = WordDefinition.fromJson(jsonResponse[0]);
        
        setState(() {
          _wordDefinition = definition;
          _isLoading = false;
        });
        
        // Save to History in Firestore
        _addToHistory(definition.word);

      } else if (response.statusCode == 404) {
        setState(() {
          _errorMessage = 'Word not found. Please check the spelling.';
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = 'Failed to fetch definition. Please try again later.';
          _isLoading = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'An error occurred. Please check your connection.';
        _isLoading = false;
      });
    }
  }

  Future<void> _addToHistory(String word) async {
    if (user == null) return;
    try {
      // Use the word as the document ID to prevent duplicates, or just add it.
      // Using word as ID makes it easy to update the timestamp if searched again.
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user!.uid)
          .collection('history')
          .doc(word.toLowerCase())
          .set({
        'word': word,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint("Error adding to history: $e");
    }
  }

  Future<void> _toggleFavorite(String word) async {
    if (user == null) return;
    final docRef = FirebaseFirestore.instance
        .collection('users')
        .doc(user!.uid)
        .collection('favorites')
        .doc(word.toLowerCase());

    try {
      final doc = await docRef.get();
      if (doc.exists) {
        await docRef.delete();
      } else {
        await docRef.set({
          'word': word,
          'timestamp': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      if(!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  Future<void> _playAudio(String? url) async {
    if (url == null || url.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No pronunciation audio available.'), backgroundColor: Colors.redAccent),
      );
      return;
    }
    try {
      await _audioPlayer.play(UrlSource(url));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to play audio: $e'), backgroundColor: Colors.redAccent),
      );
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter Dictionary'),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(
                      hintText: 'Enter a word...',
                      prefixIcon: Icon(Icons.search),
                    ),
                    onSubmitted: (_) => _searchWord(),
                  ),
                ),
                const SizedBox(width: 10),
                IconButton.filled(
                  icon: const Icon(Icons.search),
                  onPressed: _searchWord,
                ),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(child: _buildResultWidget()),
          ],
        ),
      ),
    );
  }

  Widget _buildResultWidget() {
    if (_isLoading) return const Center(child: CircularProgressIndicator());
    if (_errorMessage != null) {
      return Center(
        child: Text(_errorMessage!, style: const TextStyle(color: Colors.red, fontSize: 16)),
      );
    }
    if (_wordDefinition == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.menu_book, size: 64, color: Colors.grey[300]),
            const SizedBox(height: 16),
            const Text('Search for a word to begin', style: TextStyle(fontSize: 18, color: Colors.grey)),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Card
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(_wordDefinition!.word, style: Theme.of(context).textTheme.headlineLarge),
                      if (_wordDefinition!.phonetic != null)
                        Text(_wordDefinition!.phonetic!, style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.grey[700])),
                    ],
                  ),
                  Row(
                    children: [
                      if (_wordDefinition!.audioUrl != null)
                        IconButton(
                          icon: const Icon(Icons.volume_up),
                          onPressed: () => _playAudio(_wordDefinition!.audioUrl),
                        ),
                      // Favorite Button Stream
                      StreamBuilder<DocumentSnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('users')
                            .doc(user?.uid)
                            .collection('favorites')
                            .doc(_wordDefinition!.word.toLowerCase())
                            .snapshots(),
                        builder: (context, snapshot) {
                          bool isFav = snapshot.hasData && snapshot.data!.exists;
                          return IconButton(
                            icon: Icon(isFav ? Icons.favorite : Icons.favorite_border),
                            color: isFav ? Colors.red : null,
                            onPressed: () => _toggleFavorite(_wordDefinition!.word),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          // Meanings
          ..._wordDefinition!.meanings.map((meaning) {
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 8),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(meaning.partOfSpeech, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary)),
                    const Divider(),
                    ...meaning.definitions.asMap().entries.map((entry) {
                      int idx = entry.key + 1;
                      Definition def = entry.value;
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('$idx. ${def.definition}', style: Theme.of(context).textTheme.bodyLarge),
                            if (def.example != null)
                              Padding(
                                padding: const EdgeInsets.only(left: 16.0, top: 4.0),
                                child: Text('"${def.example}"', style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontStyle: FontStyle.italic, color: Colors.grey[600])),
                              ),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

// --- 2 & 3. Favorites and History Tabs (Reusable) ---

class ListTab extends StatelessWidget {
  final String collectionName;
  final String title;
  final Function(String) onWordTap;

  const ListTab({
    super.key, 
    required this.collectionName, 
    required this.title,
    required this.onWordTap
  });

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(user?.uid)
            .collection(collectionName)
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text("Something went wrong"));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data?.docs ?? [];

          if (docs.isEmpty) {
            return Center(child: Text("No $title yet."));
          }

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;
              final word = data['word'] ?? '';
              
              return ListTile(
                leading: Icon(collectionName == 'favorites' ? Icons.favorite : Icons.history),
                title: Text(word, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () => onWordTap(word),
              );
            },
          );
        },
      ),
    );
  }
}

// --- 4. Profile Tab ---

class ProfileTab extends StatelessWidget {
  const ProfileTab({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircleAvatar(
                radius: 50,
                child: Icon(Icons.person, size: 50),
              ),
              const SizedBox(height: 24),
              Text(
                user?.email ?? 'No Email',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(
                'User ID: ${user?.uid.substring(0, 5)}...',
                style: const TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 48),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () async {
                    await FirebaseAuth.instance.signOut();
                    // AuthGate will handle the redirect to Login
                  },
                  icon: const Icon(Icons.logout),
                  label: const Text('Logout'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}