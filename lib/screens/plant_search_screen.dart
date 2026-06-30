// lib/screens/plant_search_screen.dart

import 'package:flutter/material.dart';
import '../models/plant.dart';
import '../services/data_service.dart';
import 'details_screen.dart';

class PlantSearchScreen extends StatefulWidget {
  final DataService dataService;

  const PlantSearchScreen({super.key, required this.dataService});

  @override
  State<PlantSearchScreen> createState() => _PlantSearchScreenState();
}

class _PlantSearchScreenState extends State<PlantSearchScreen> {
  final TextEditingController _controller = TextEditingController();
  List<Plant> _filteredPlants = [];

  @override
  void initState() {
    super.initState();
    _filteredPlants = widget.dataService.searchPlantsByName('');
    _controller.addListener(_searchPlants);
  }

  @override
  void dispose() {
    _controller.removeListener(_searchPlants);
    _controller.dispose();
    super.dispose();
  }

  void _searchPlants() {
    setState(() {
      _filteredPlants = widget.dataService.searchPlantsByName(_controller.text);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      // ✅ Background: your preferred light green gradient
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFE8F5E9), Color(0xFFC8E6C9)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Column(
        children: [
          // ✅ Search bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _controller,
              decoration: InputDecoration(
                labelText: 'Enter Plant Name (e.g., Tulsi, Aloe)',
                hintText: 'Search by Common Name or Scientific Name',
                prefixIcon: _controller.text.isNotEmpty
                    ? IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.green),
                  onPressed: () {
                    _controller.clear();
                    FocusScope.of(context).unfocus();
                    setState(() {});
                  },
                )
                    : const Icon(Icons.search, color: Colors.green),
                border: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                ),
              ),
            ),
          ),

          // ✅ Search Results
          Expanded(
            child: _filteredPlants.isEmpty && _controller.text.isNotEmpty
                ? Center(
              child: Text(
                'No plant found matching "${_controller.text}"',
                style: const TextStyle(fontSize: 16),
              ),
            )
                : ListView.builder(
              itemCount: _filteredPlants.length,
              itemBuilder: (context, index) {
                final plant = _filteredPlants[index];
                return Container(
                  margin: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 6),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    gradient: LinearGradient(
                      colors: [
                        Colors.white.withOpacity(0.1),
                        const Color(0xFFE8F5E9).withOpacity(0.9),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.green.withOpacity(0.15),
                        offset: const Offset(0, 2),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                  child: ListTile(
                    leading:
                    const Icon(Icons.eco, color: Colors.green),
                    title: Text(
                      plant.commonName,
                      style:
                      const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(plant.scientificName),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              PlantDetailsScreen(plant: plant),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
