import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: firebaseOptions);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Exp 12: Firebase Auth',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: AuthPage(),
    );
  }
}

class AuthPage extends StatefulWidget {
  @override
  _AuthPageState createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? user;

  @override
  void initState() {
    super.initState();
    user = _auth.currentUser;
    _auth.authStateChanges().listen((u) {
      setState(() {
        user = u;
      });
    });
  }

  Future<void> _signUp() async {
    try {
      await _auth.createUserWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );
    } catch (e) {
      _showError(e.toString());
    }
  }

  Future<void> _signIn() async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );
    } catch (e) {
      _showError(e.toString());
    }
  }

  Future<void> _signOut() async {
    await _auth.signOut();
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Firebase Auth')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: user == null ? _buildAuthForm() : _buildUserInfo(),
      ),
    );
  }

  Widget _buildAuthForm() {
    return Column(
      children: [
        TextField(
          controller: _emailController,
          decoration: InputDecoration(labelText: 'Email'),
        ),
        TextField(
          controller: _passwordController,
          decoration: InputDecoration(labelText: 'Password'),
          obscureText: true,
        ),
        SizedBox(height: 10),
        Row(
          children: [
            ElevatedButton(onPressed: _signUp, child: Text('Sign Up')),
            SizedBox(width: 10),
            ElevatedButton(onPressed: _signIn, child: Text('Sign In')),
          ],
        ),
      ],
    );
  }

  Widget _buildUserInfo() {
    return Column(
      children: [
        Text('Signed in as: ${user!.email}', style: TextStyle(fontSize: 16)),
        SizedBox(height: 10),
        ElevatedButton(onPressed: _signOut, child: Text('Sign Out')),
      ],
    );
  }
}
