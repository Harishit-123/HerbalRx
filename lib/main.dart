// lib/main.dart

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart'; // Required for RootIsolateToken setup (though usually already imported)
import 'firebase_options.dart';
import 'services/data_service.dart';
import 'screens/auth_gate.dart';

// Initialize DataService globally
final DataService dataService = DataService();

void main() async {
  // 1. Initialize Flutter binding first
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // 3. Load all application data (plant data)
  await dataService.loadData();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Herbal Guide App',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      // FIX: Removed 'const' to pass the runtime instance of dataService.
      home: AuthGate(dataService: dataService),
    );
  }
}