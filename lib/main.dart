import 'package:bytestodo/Login.dart';
import 'package:bytestodo/voicebot/voicebotscreen.dart';

import 'package:bytestodo/signup_screen.dart.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    // Firebase initialization for Android/iOS platforms
    await Firebase.initializeApp();
  } catch (e) {
    print("Error initializing Firebase: $e");
  }

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // Counter to track visits
  final int _screenVisitCount = 0;

  @override
  void initState() {
    super.initState();
    _checkUserVisitCount();
  }

  // Method to check and update the visit count
  void _checkUserVisitCount() {
    // You can use SharedPreferences or any other local storage solution
    // to persist the visit count, for now, we're using a simple counter.
    // If you're using SharedPreferences, the logic can be added here to 
    // store and retrieve the count across app restarts.
    if (_screenVisitCount > 5) {
      // If the visit count exceeds 5, navigate directly to the home screen
      Future.delayed(Duration.zero, () {
        Navigator.pushReplacementNamed(context, '/home');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home:VoiceBotApp(),
      routes: {
        '/signup': (context) => const Signup(),
        '/login': (context) => const Login(),
        '/home': (context) => const VoiceBotApp(),
      },
    );
  }
}
