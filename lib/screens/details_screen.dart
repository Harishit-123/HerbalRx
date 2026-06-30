// lib/screens/details_screen.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart'; // ✅ Added TTS package
import '../models/plant.dart';

class PlantDetailsScreen extends StatefulWidget {
  final Plant plant;
  final String? imagePath;

  const PlantDetailsScreen({
    super.key,
    required this.plant,
    this.imagePath,
  });

  @override
  State<PlantDetailsScreen> createState() => _PlantDetailsScreenState();
}

class _PlantDetailsScreenState extends State<PlantDetailsScreen> {
  late FlutterTts _flutterTts; // ✅ TTS instance

  @override
  void initState() {
    super.initState();
    _flutterTts = FlutterTts(); // ✅ Initialize
  }

  @override
  void dispose() {
    _flutterTts.stop(); // ✅ Stop on exit
    super.dispose();
  }

  // ✅ Speak helper
  Future<void> _speak(String text) async {
    if (text.isEmpty) return;
    await _flutterTts.setLanguage('en-US');
    await _flutterTts.setPitch(1.0);
    await _flutterTts.speak(text);
  }

  @override
  Widget build(BuildContext context) {
    final plant = widget.plant;
    final String? imagePath = widget.imagePath;

    final Color primaryGreen = Colors.green.shade700;
    final Color lightBackground = Colors.green.shade50;
    final Color sectionColor = Colors.green.shade900;

    return Scaffold(
      backgroundColor: lightBackground,
      body: NotificationListener<ScrollNotification>(
        onNotification: (_) => false,
        child: CustomScrollView(
          slivers: <Widget>[
            // 🌿 AppBar with image
            SliverAppBar(
              expandedHeight: 250.0,
              pinned: true,
              stretch: true,
              backgroundColor: primaryGreen,
              flexibleSpace: LayoutBuilder(
                builder: (BuildContext context, BoxConstraints constraints) {
                  final double top = constraints.biggest.height;
                  final double opacity =
                      (top - kToolbarHeight) / (250 - kToolbarHeight);
                  final double scale = 1.0 + (opacity * 0.05);
                  final double slideOffset = (1 - opacity) * 20.0;

                  return FlexibleSpaceBar(
                    titlePadding: const EdgeInsets.only(left: 16, bottom: 16),
                    title: Transform.translate(
                      offset: Offset(0, slideOffset),
                      child: Opacity(
                        opacity: opacity.clamp(0.0, 1.0),
                        child: Text(
                          plant.commonName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            shadows: [Shadow(blurRadius: 5, color: Colors.black)],
                          ),
                        ),
                      ),
                    ),
                    background: Stack(
                      fit: StackFit.expand,
                      children: [
                        Transform.scale(
                          scale: scale,
                          child: AnimatedOpacity(
                            opacity: opacity.clamp(0.3, 1.0),
                            duration: const Duration(milliseconds: 300),
                            child: _buildBackgroundImage(imagePath, primaryGreen),
                          ),
                        ),
                        Container(color: Colors.black26),

                        if (imagePath == null || imagePath.isEmpty)
                          Align(
                            alignment: Alignment.center,
                            child: Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.25),
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 2),
                                boxShadow: const [
                                  BoxShadow(
                                    blurRadius: 10,
                                    color: Colors.black26,
                                  )
                                ],
                              ),
                              child: const Icon(
                                Icons.spa,
                                size: 80,
                                color: Colors.white,
                              ),
                            ),
                          ),
                      ],
                    ),
                  );
                },
              ),
            ),

            // 🌿 Scrollable content
            SliverList(
              delegate: SliverChildListDelegate(
                [
                  // 🌿 Scientific Name & Uses
                  _buildInfoCard(
                    title: 'Scientific Name & Uses',
                    color: primaryGreen,
                    children: [
                      // 🌿 Scientific Name Row with Speak Button
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              'Scientific Name: ${plant.scientificName}',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                fontStyle: FontStyle.italic,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.volume_up, color: Colors.green),
                            tooltip: 'Speak Scientific Name',
                            onPressed: () => _speak(plant.scientificName),
                          ),
                        ],
                      ),
                      const Divider(height: 20),


                      // --- Primary Uses with TTS button ---
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Primary Uses',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: sectionColor,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.volume_up, color: Colors.green),
                            tooltip: 'Speak Uses',
                            onPressed: () => _speak(plant.uses),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.green.shade100.withOpacity(0.6),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: plant.uses
                              .split(',')
                              .map((use) => use.trim())
                              .where((use) => use.isNotEmpty)
                              .map(
                                (use) => Padding(
                              padding: const EdgeInsets.only(bottom: 6.0),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text("• ", style: TextStyle(fontSize: 18)),
                                  Expanded(
                                    child: Text(
                                      use,
                                      style: TextStyle(
                                        fontSize: 16,
                                        height: 1.5,
                                        color: Colors.green.shade900,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                              .toList(),
                        ),
                      ),
                    ],
                  ),

                  // 🌿 Treats Section
                  _buildInfoCard(
                    title: 'Treats (Cures Symptoms)',
                    color: sectionColor,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Treats (Cures Symptoms)',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.volume_up, color: Colors.green),
                            tooltip: 'Speak Treats',
                            onPressed: () => _speak(plant.treats.join(', ')),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8.0,
                        runSpacing: 8.0,
                        children: plant.treats
                            .map(
                              (s) => Chip(
                            label: Text(s),
                            backgroundColor: Colors.lightGreen[100],
                            labelStyle: TextStyle(
                              color: primaryGreen,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        )
                            .toList(),
                      ),
                    ],
                  ),

                  // 🌿 Preparation Methods Section
                  _buildInfoCard(
                    title: 'Preparation Methods',
                    color: sectionColor,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Preparation Methods',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.volume_up, color: Colors.green),
                            tooltip: 'Speak Preparation Methods',
                            onPressed: () =>
                                _speak(plant.preparationMethods.join('. ')),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.green.shade100.withOpacity(0.6),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: plant.preparationMethods.asMap().entries.map(
                                (entry) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 10.0),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      height: 26,
                                      width: 26,
                                      alignment: Alignment.center,
                                      margin: const EdgeInsets.only(right: 10),
                                      decoration: BoxDecoration(
                                        color: sectionColor,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Text(
                                        '${entry.key + 1}',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Text(
                                        entry.value,
                                        style: TextStyle(
                                          fontSize: 15.5,
                                          color: Colors.green.shade900,
                                          height: 1.4,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ).toList(),
                        ),
                      ),
                    ],
                  ),

                  // 🌿 Safety Warnings Section
                  _buildInfoCard(
                    title: 'Safety Warnings',
                    color: Colors.red[700]!,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Safety Warnings',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.red,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.volume_up, color: Colors.red),
                            tooltip: 'Speak Safety Warnings',
                            onPressed: () => _speak(plant.safetyWarnings),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: plant.safetyWarnings
                            .split('.')
                            .map((warn) => warn.trim())
                            .where((warn) => warn.isNotEmpty)
                            .map(
                              (warn) => Padding(
                            padding: const EdgeInsets.only(bottom: 6.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text("• ",
                                    style: TextStyle(
                                        fontSize: 18, color: Colors.red)),
                                Expanded(
                                  child: Text(
                                    warn,
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.red.shade900,
                                      height: 1.4,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                            .toList(),
                      ),
                    ],
                  ),

                  // 🌿 Disclaimer
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 10.0),
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
      ),
    );
  }

  Widget _buildBackgroundImage(String? imagePath, Color primaryGreen) {
    if (imagePath != null && imagePath.isNotEmpty) {
      return imagePath.startsWith('http')
          ? Image.network(
        imagePath,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) =>
            _buildFallbackBackground(primaryGreen),
      )
          : Image.file(
        File(imagePath),
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) =>
            _buildFallbackBackground(primaryGreen),
      );
    } else {
      return _buildFallbackBackground(primaryGreen);
    }
  }

  Widget _buildFallbackBackground(Color primaryGreen) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            primaryGreen.withOpacity(0.8),
            primaryGreen.withOpacity(1.0),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
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

  Widget _buildDataRow(String label, String value,
      {bool isBold = false, Color? color}) {
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
