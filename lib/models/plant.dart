class Plant {
  final String commonName; 
  final String scientificName;
  final String uses; // Still stored as a single string
  final List<String> treats; 
  final List<String> preparationMethods; 
  final String safetyWarnings;
  final String references; // Still stored as a single string
  final String imageAsset;

  Plant({
    required this.commonName,
    required this.scientificName,
    required this.uses,
    required this.treats,
    required this.preparationMethods,
    required this.safetyWarnings,
    required this.references,
    required this.imageAsset,
  });

  // Helper function to normalize keys for case/space insensitive lookup
  static String _lookupKey(Map<String, dynamic> json, String targetKey) {
      final normalizedTarget = targetKey.toLowerCase().replaceAll(' ', '_');
      for (final k in json.keys) {
          if (k.toLowerCase().replaceAll(' ', '_') == normalizedTarget) {
              return k;
          }
      }
      return targetKey; 
  }

  // Helper function to convert dynamic content (String or List) into a single String
  static String _toSingleString(dynamic rawData) {
      if (rawData is List) {
          // If it's a list (e.g., ["Use 1", "Use 2"]), join it into one string.
          return rawData.join('; ');
      }
      if (rawData is String) {
          return rawData;
      }
      return ''; // Default to empty string if null or unknown type
  }

  factory Plant.fromJson(Map<String, dynamic> json) {
    String lookup(String targetKey) => _lookupKey(json, targetKey);

    // --- TREATS PARSING (Handles String or List) ---
    final rawTreats = json[lookup('Treats')];
    List<String> parsedTreats;

    if (rawTreats is String) {
        // Fix: If it's a single comma-separated string, split it and clean it up.
        parsedTreats = rawTreats
            .split(',')
            .map((s) => s.trim())
            .where((s) => s.isNotEmpty)
            .toList();
    } else if (rawTreats is List) {
        // Casts list elements to string, handling dynamic types
        parsedTreats = rawTreats.map((e) => e.toString()).toList();
    } else {
        parsedTreats = [];
    }
    
    // --- PREPARATION METHODS PARSING (Handles List) ---
    final rawPreparation = json[lookup('Preparation Methods')];
    List<String> parsedPreparation;
    
    if (rawPreparation is List) {
        // Fix: Converts the List<dynamic> from JSON directly to List<String>
        parsedPreparation = List<String>.from(rawPreparation);
    } else if (rawPreparation is String) {
        // Fallback: If somehow it's a string, treat it as a single entry list
        parsedPreparation = [rawPreparation];
    } else {
        parsedPreparation = [];
    }


    return Plant(
      commonName: json[lookup('Common Name')] as String,
      scientificName: json[lookup('Scientific Name')] as String,
      
      // --- FIX: Safely convert 'Uses' (which may be a list in JSON) to a single String ---
      uses: _toSingleString(json[lookup('Uses')]),
      
      treats: parsedTreats, 
      preparationMethods: parsedPreparation, 
      safetyWarnings: json[lookup('Safety Warnings')] as String,
      
      // --- FIX: Safely convert 'References' (which may be a list in JSON) to a single String ---
      references: _toSingleString(json[lookup('References')]),
      
      imageAsset: json[lookup('image_asset')] ?? 'placeholder.jpg',
    );
  }
}
