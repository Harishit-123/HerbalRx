import 'package:flutter/material.dart';
import '../models/plant.dart';

class PlantDetailsScreen extends StatelessWidget {
  final Plant plant;
  final String? imageUrl; // 👈 new parameter to receive input image

  const PlantDetailsScreen({
    super.key,
    required this.plant,
    this.imageUrl, // optional for search results
  });

  @override
  Widget build(BuildContext context) {
    final Color primaryGreen = Colors.green.shade700;
    final Color lightBackground = Colors.green.shade50;
    final Color sectionColor = Colors.green.shade900;

    return Scaffold(
      backgroundColor: lightBackground,
      body: CustomScrollView(
        slivers: <Widget>[
          // --- Collapsing AppBar with Dynamic Image ---
          SliverAppBar(
            expandedHeight: 250.0,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.only(left: 16, bottom: 16),
              title: Text(
                plant.commonName,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  shadows: [Shadow(blurRadius: 5, color: Colors.black)],
                ),
              ),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // 👇 Show image if available, else green gradient background
                  if (imageUrl != null)
                    Image.file(
                      File(imageUrl!),
                      fit: BoxFit.cover,
                    )
                  else
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            primaryGreen.withOpacity(0.8),
                            primaryGreen.withOpacity(1.0),
                          ],
                        ),
                      ),
                    ),

                  // Dark overlay for readability
                  Container(
                    color: Colors.black.withOpacity(0.3),
                  ),

                  // Optional decorative icon overlay (small leaf icon)
                  Align(
                    alignment: Alignment.center,
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                        boxShadow: const [BoxShadow(blurRadius: 10, color: Colors.black26)],
                      ),
                      child: const Icon(
                        Icons.eco,
                        size: 60,
                        color: Colors.white70,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // --- Plant Info ---
          SliverList(
            delegate: SliverChildListDelegate(
              [
                _buildInfoCard(
                  title: 'Scientific Name & Uses',
                  color: primaryGreen,
                  children: [
                    _buildDataRow('Scientific Name', plant.scientificName, isBold: true),
                    const Divider(height: 20),
                    _buildSectionTitle('Primary Uses'),
                    Text(plant.uses, style: const TextStyle(fontSize: 16, height: 1.5)),
                  ],
                ),

                _buildInfoCard(
                  title: 'Treats (Cures Symptoms)',
                  color: sectionColor,
                  children: [
                    Wrap(
                      spacing: 8.0,
                      runSpacing: 8.0,
                      children: plant.treats
                          .map((s) => Chip(
                                label: Text(s),
                                backgroundColor: Colors.lightGreen[100],
                                labelStyle: TextStyle(
                                  color: primaryGreen,
                                  fontWeight: FontWeight.w500,
                                ),
                              ))
                          .toList(),
                    ),
                  ],
                ),

                _buildInfoCard(
                  title: 'Preparation Methods',
                  color: sectionColor,
                  children: [
                    ...plant.preparationMethods.asMap().entries.map(
                          (entry) => Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${entry.key + 1}. ',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: primaryGreen,
                                  ),
                                ),
                                Expanded(
                                  child: Text(entry.value, style: const TextStyle(fontSize: 15)),
                                ),
                              ],
                            ),
                          ),
                        ),
                  ],
                ),

                _buildInfoCard(
                  title: 'Safety Warnings',
                  color: Colors.red[700]!,
                  children: [
                    _buildDataRow('', plant.safetyWarnings, color: Colors.red.shade900),
                  ],
                ),

                _buildInfoCard(
                  title: 'References',
                  color: Colors.blueGrey,
                  children: [
                    Text(
                      plant.references,
                      style: const TextStyle(fontSize: 14, fontStyle: FontStyle.italic),
                    ),
                  ],
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
                  child: Text(
                    'Disclaimer: The herbal information presented here is for educational and reference purposes only. '
                    'It is not intended as medical advice. Please consult a qualified healthcare professional before using '
                    'any plant or herbal preparation for treatment.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.redAccent.shade700,
                      fontStyle: FontStyle.italic,
                      height: 1.4,
                    ),
                  ),
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- Helper Methods ---
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.green[800],
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required String title,
    required Color color,
    required List<Widget> children,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
          const Divider(thickness: 2, color: Colors.black12, height: 20),
          ...children,
        ],
      ),
    );
  }

  Widget _buildDataRow(String label, String value, {bool isBold = false, Color? color}) {
    if (label.isNotEmpty) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label: ',
            style: TextStyle(
              fontSize: 16,
              fontWeight: isBold ? FontWeight.w700 : FontWeight.w500,
              color: color ?? Colors.black,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: isBold ? FontWeight.w600 : FontWeight.normal,
                fontStyle: isBold ? FontStyle.italic : FontStyle.normal,
                color: color ?? Colors.grey[700],
              ),
            ),
          ),
        ],
      );
    } else {
      return Text(
        value,
        style: TextStyle(
          fontSize: 16,
          fontWeight: isBold ? FontWeight.w600 : FontWeight.normal,
          fontStyle: isBold ? FontStyle.italic : FontStyle.normal,
          color: color ?? Colors.grey[700],
        ),
      );
    }
  }
}
