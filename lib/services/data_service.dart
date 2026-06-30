// lib/services/data_service.dart

import 'dart:async';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import '../models/plant.dart';

class DataService {
  List<Plant> _plants = [];
  bool _isLoaded = false;

  List<String> get allPlantNames => _plants.map((p) => p.commonName).toList();

  // 1. Function to load data once
  Future<void> loadData() async {
    if (_isLoaded) return;

    try {
      final String jsonString = await rootBundle.loadString('assets/medicinal_Plants_data.json');
      final List<dynamic> jsonList = json.decode(jsonString);

      _plants = jsonList.map((json) => Plant.fromJson(json)).toList();
      _isLoaded = true;
      print('DEBUG: Plant data loaded successfully: ${_plants.length} plants.');

    } catch (e) {
      print('FATAL ERROR: Error loading plant data: $e');
    }
  }

  // Helper method to get a single Plant by its Common Name (used after prediction)
  Plant? getPlantByCommonName(String name) {
    if (!_isLoaded) return null;
    final normalizedName = name.trim().toLowerCase();

    Plant placeholder = Plant(
      commonName: name,
      scientificName: 'Details Not Found',
      uses: 'The model predicted "$name," but details are not available in the local database. Try refining your search query in the By Plant tab.',
      treats: [],
      preparationMethods: ['N/A'],
      safetyWarnings: 'Consult an expert before use.',
      references: 'Model prediction.',
      imageAsset: 'placeholder.jpg',
    );

    try {
      return _plants.firstWhere(
            (plant) => plant.commonName.toLowerCase() == normalizedName,
      );
    } catch (_) {
      try {
        return _plants.firstWhere(
              (plant) => plant.scientificName.toLowerCase().contains(normalizedName) ||
              plant.commonName.toLowerCase().contains(normalizedName),
        );
      } catch (_) {
        return placeholder;
      }
    }
  }

  // 2. Feature: Search by Plant Name (Partial Match, Case-Insensitive)
  List<Plant> searchPlantsByName(String query) {
    if (!_isLoaded) return [];

    if (query.isEmpty) return _plants;

    final normalizedQuery = query.trim().toLowerCase();

    return _plants.where((plant) {
      return plant.commonName.toLowerCase().contains(normalizedQuery) ||
          plant.scientificName.toLowerCase().contains(normalizedQuery);
    }).toList();
  }


  // 3. Feature: Search by Symptom (Partial Match, Case-Insensitive)
  List<Plant> getPlantsBySymptom(String symptom) {
    if (!_isLoaded || symptom.isEmpty) return [];

    final normalizedSymptom = symptom.trim().toLowerCase();

    return _plants.where((plant) {
      return plant.treats.any(
            (s) => s.toLowerCase().contains(normalizedSymptom),
      );
    }).toList();
  }
}