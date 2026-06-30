// lib/screens/auth_gate.dart

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'auth_screen.dart';
import 'main_screen.dart';
import '../services/data_service.dart';

class AuthGate extends StatelessWidget {
  final DataService dataService;
  const AuthGate({super.key, required this.dataService});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      // Listen to Firebase's real-time authentication state
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // While the connection is loading, show a spinner
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        // If the snapshot has user data, the user is signed in
        if (snapshot.hasData) {
          // Show the main app screen, passing the DataService instance
          return MainScreen(dataService: dataService);
        }

        // Otherwise, the user is not signed in
        return const AuthScreen(); // Show the login/signup screen
      },
    );
  }
}