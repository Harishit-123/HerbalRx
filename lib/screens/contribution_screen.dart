// lib/screens/contribution_screen.dart

import 'package:flutter/material.dart';

class ContributionScreen extends StatelessWidget {
  const ContributionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.share, size: 50, color: Colors.amber.shade700),
            const SizedBox(height: 10),
            const Text('Share Your Natural Remedy', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 5),
            const Text(
              'A form will be implemented here to allow verified users to contribute their locally experienced natural remedies to the database for peer review and inclusion.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}