import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Used for logout and getting user info
import 'package:fresh/screens/auth_screen.dart'; // <-- CORRECTED: Changed 'your_app_name' to 'fresh'

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  // Function to handle user logout
  void _logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    // After logging out, navigate back to the AuthScreen
    // The 'mounted' check is a good practice to ensure the widget is still in the tree
    if (context.mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (ctx) => const AuthScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Get the currently logged-in user from Firebase Auth
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Page'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        actions: [
          // Add a logout button to the app bar
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () {
              // Call the logout function when the button is pressed
              _logout(context);
            },
          )
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Welcome!',
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              // Display the user's email if available
              Text(
                'You are logged in as:',
                style: TextStyle(fontSize: 18, color: Colors.grey.shade700),
              ),
              const SizedBox(height: 8),
              Text(
                user?.email ?? 'No email found', // Safely display user's email
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
