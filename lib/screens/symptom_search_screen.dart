// lib/screens/symptom_search_screen.dart

import 'package:flutter/material.dart';
import '../models/plant.dart';
import '../services/data_service.dart';
import 'details_screen.dart';

class SymptomSearchScreen extends StatefulWidget {
  final DataService dataService;

  const SymptomSearchScreen({super.key, required this.dataService});

  @override
  State<SymptomSearchScreen> createState() => _SymptomSearchScreenState();
}

class _SymptomSearchScreenState extends State<SymptomSearchScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _controller = TextEditingController();
  List<Plant> _results = [];

  final List<Map<String, dynamic>> commonSymptoms = [
    {'name': 'Fever', 'icon': Icons.thermostat},
    {'name': 'Cough', 'icon': Icons.air},
    {'name': 'Cold', 'icon': Icons.ac_unit},
    {'name': 'Headache', 'icon': Icons.psychology},
    {'name': 'Burns', 'icon': Icons.local_fire_department},
    {'name': 'Stomach ache', 'icon': Icons.restaurant},
    {'name': 'Wounds', 'icon': Icons.healing},
    {'name': 'Allergy', 'icon': Icons.coronavirus},
    {'name': 'Skin infection', 'icon': Icons.spa},
    {'name': 'Diabetes', 'icon': Icons.bloodtype},
  ];

  @override
  void initState() {
    super.initState();
    _controller.addListener(_searchSymptoms);
  }

  @override
  void dispose() {
    _controller.removeListener(_searchSymptoms);
    _controller.dispose();
    super.dispose();
  }

  void _searchSymptoms() {
    final symptom = _controller.text.trim();
    _results = widget.dataService.getPlantsBySymptom(symptom);
    setState(() {});
  }

  Widget _buildResultsView() {
    if (_controller.text.isEmpty) {
      // ✅ Default state: show stylish grid
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          const Text(
            "🌿 Discover Healing Naturally",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.green,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            "Explore medicinal plants that can help you.",
            style: TextStyle(fontSize: 15, color: Colors.black54),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.2,
              ),
              itemCount: commonSymptoms.length,
              itemBuilder: (context, index) {
                final symptom = commonSymptoms[index];
                return GestureDetector(
                  onTap: () {
                    _controller.text = symptom['name'];
                    _searchSymptoms();
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.green.withOpacity(0.2),
                          blurRadius: 6,
                          offset: const Offset(2, 3),
                        ),
                      ],
                      gradient: LinearGradient(
                        colors: [
                          Colors.green.shade100,
                          Colors.green.shade50,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(18),
                      splashColor: Colors.green.withOpacity(0.2),
                      onTap: () {
                        _controller.text = symptom['name'];
                        _searchSymptoms();
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircleAvatar(
                              backgroundColor: Colors.green.shade100,
                              radius: 26,
                              child: Icon(
                                symptom['icon'],
                                color: Colors.green.shade700,
                                size: 30,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              symptom['name'],
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                                color: Colors.green,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      );
    }

    if (_results.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.sentiment_dissatisfied, size: 60, color: Colors.red[300]),
            const SizedBox(height: 12),
            Text(
              'No plants found that treat "${_controller.text}".',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: _results.length,
      itemBuilder: (context, index) {
        final plant = _results[index];
        return Card(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.symmetric(vertical: 8),
          child: ListTile(
            leading: const Icon(Icons.eco, color: Colors.green),
            title: Text(
              plant.commonName,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(plant.scientificName),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PlantDetailsScreen(plant: plant),
                ),
              );
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.green.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // ✅ Search bar with conditional back arrow
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                labelText: 'Enter Symptom (e.g., Headache, Burns)',
                hintText: 'Search or choose from below...',
                prefixIcon: _controller.text.isNotEmpty
                    ? IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.green),
                  onPressed: () {
                    _controller.clear();
                    FocusScope.of(context).unfocus();
                    setState(() {}); // Refresh to show the symptom grid again
                  },
                )
                    : const Icon(Icons.search, color: Colors.green),
                border: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(14)),
                ),
                focusedBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.green, width: 1.5),
                  borderRadius: BorderRadius.all(Radius.circular(14)),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(child: _buildResultsView()),
          ],
        ),
      ),
    );
  }
}
