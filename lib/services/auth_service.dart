// lib/services/auth_service.dart

import 'package:firebase_auth/firebase_auth.dart';

// A simple service to handle signing out
class AuthService {
  // This method must be async to use await
  Future<void> signOut() async {
    await FirebaseAuth.instance.signOut();
  }
}