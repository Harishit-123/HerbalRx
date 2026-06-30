// lib/screens/main_screen.dart

import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import '../services/data_service.dart';
import 'plant_search_screen.dart';
import 'symptom_search_screen.dart';
import 'image_identify_screen.dart';
import 'history_screen.dart';
import 'contribution_screen.dart';

class MainScreen extends StatelessWidget {
  final DataService dataService;
  const MainScreen({super.key, required this.dataService});

  @override
  Widget build(BuildContext context) {
    // Set length to 5 for all tabs
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Herbal Remedy Guide'),
          backgroundColor: Colors.green[800],
          foregroundColor: Colors.white,
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              tooltip: 'Logout',
              onPressed: () {
                AuthService().signOut();
              },
            ),
          ],
          bottom: const TabBar(
            indicatorColor: Colors.white,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            isScrollable: true,
            tabs: [
              Tab(icon: Icon(Icons.search), text: 'By Plant'),
              Tab(icon: Icon(Icons.healing), text: 'By Symptom'),
              Tab(icon: Icon(Icons.camera_alt), text: 'Identify'),
              Tab(icon: Icon(Icons.history), text: 'History'),
              // Tab(icon: Icon(Icons.share), text: 'Contribute'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            PlantSearchScreen(dataService: dataService),
            SymptomSearchScreen(dataService: dataService),
            ImageIdentifyScreen(dataService: dataService), // ML Integrated Screen
            // FIX: Pass the required dataService instance to HistoryScreen and ContributionScreen
            HistoryScreen(dataService: dataService),
            // ContributionScreen(),
          ],
        ),
      ),
    );
  }
}