import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/history_service.dart';
import '../services/data_service.dart';
import 'details_screen.dart';

final HistoryService historyService = HistoryService();

class HistoryScreen extends StatelessWidget {
  final DataService dataService;
  const HistoryScreen({super.key, required this.dataService});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFE8F5E9), // ✅ Soft light green background
      child: StreamBuilder<QuerySnapshot>(
        stream: historyService.getUserHistory(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error loading history: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(32.0),
                child: Text(
                  'No history found. Identify a plant to save your first entry!',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ),
            );
          }

          final docs = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(8.0),
            itemCount: docs.length,
            itemBuilder: (context, i) {
              final doc = docs[i];
              final item = doc.data() as Map<String, dynamic>;
              final docId = doc.id;

              final imageUrl = item['imageUrl'] ?? '';
              final confidence = item['confidence'] as double? ?? 0.0;
              final commonName = item['commonName'] ?? 'Unknown Plant';
              final predictedClass = item['predictedClass'] ?? 'N/A';
              final timestamp = (item['timestamp'] as Timestamp?)?.toDate();

              return Card(
                elevation: 2,
                margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
                child: ListTile(
                  leading: SizedBox(
                    width: 60,
                    height: 60,
                    child: imageUrl.isNotEmpty
                        ? Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (c, o, s) =>
                      const Icon(Icons.image_not_supported),
                    )
                        : const Icon(Icons.image_not_supported),
                  ),
                  title: Text(
                    commonName,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Predicted: $predictedClass'),
                      Text(
                        'Confidence: ${(confidence * 100).toStringAsFixed(1)}%',
                        style: TextStyle(
                          color: Colors.green.shade600,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        timestamp != null
                            ? 'On: ${timestamp.toString().substring(0, 10)}'
                            : 'N/A',
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                  isThreeLine: true,
                  onTap: () {
                    final plant =
                    dataService.getPlantByCommonName(predictedClass);
                    if (plant != null) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PlantDetailsScreen(
                            plant: plant,
                            imagePath:
                            imageUrl, // ✅ pass the Firebase image URL
                          ),
                        ),
                      );
                    }
                  },
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () async {
                      await historyService.deleteHistoryEntry(docId, imageUrl);
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
