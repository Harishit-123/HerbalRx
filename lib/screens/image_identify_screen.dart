// lib/screens/image_identify_screen.dart

import 'dart:io';
import 'dart:typed_data';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'
    show rootBundle, BackgroundIsolateBinaryMessenger, ServicesBinding;
import 'package:image_picker/image_picker.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;
import 'package:flutter/foundation.dart';
import 'dart:ui';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_tts/flutter_tts.dart'; // ✅ Added import

import '../services/data_service.dart';
import '../services/history_service.dart';
import 'details_screen.dart';

// ======================================================================
// BACKGROUND INFERENCE (runs in separate isolate)
// ======================================================================
Future<List<double>?> runInferenceInBackground(Map<String, dynamic> params) async {
  final Uint8List imageBytes = params['imageBytes'] as Uint8List;
  final Uint8List modelBytes = params['modelBytes'] as Uint8List;
  final int inputSize = params['inputSize'] as int;
  final int numLabels = params['numLabels'] as int;
  final RootIsolateToken token = params['rootIsolateToken'] as RootIsolateToken;

  try {
    BackgroundIsolateBinaryMessenger.ensureInitialized(token);

    img.Image? originalImage = img.decodeImage(imageBytes);
    if (originalImage == null) return null;

    originalImage = originalImage.convert(format: img.Format.uint8);
    final w = originalImage.width;
    final h = originalImage.height;
    final minDim = min(w, h);
    final left = ((w - minDim) / 2).round();
    final top = ((h - minDim) / 2).round();
    final cropped =
    img.copyCrop(originalImage, x: left, y: top, width: minDim, height: minDim);
    final resized = img.copyResize(cropped, width: inputSize, height: inputSize);

    var input =
    Float32List(1 * inputSize * inputSize * 3).reshape([1, inputSize, inputSize, 3]);
    final rawRgb = resized.getBytes();

    for (int y = 0; y < inputSize; y++) {
      for (int x = 0; x < inputSize; x++) {
        final i = (y * inputSize + x) * 3;
        input[0][y][x][0] = rawRgb[i] / 255.0;
        input[0][y][x][1] = rawRgb[i + 1] / 255.0;
        input[0][y][x][2] = rawRgb[i + 2] / 255.0;
      }
    }

    final interpreter = Interpreter.fromBuffer(modelBytes);
    var output = Float32List(numLabels).reshape([1, numLabels]);
    interpreter.run(input, output);
    interpreter.close();

    return output[0].cast<double>();
  } catch (e, st) {
    print('ISOLATE ERROR: $e');
    print(st);
    return null;
  }
}

// ======================================================================
// MAIN SCREEN
// ======================================================================
class ImageIdentifyScreen extends StatefulWidget {
  final DataService dataService;
  const ImageIdentifyScreen({super.key, required this.dataService});

  @override
  State<ImageIdentifyScreen> createState() => _ImageIdentifyScreenState();
}

class _ImageIdentifyScreenState extends State<ImageIdentifyScreen> {
  final HistoryService _historyService = HistoryService();

  File? _image;
  String _prediction = 'Awaiting image input...';
  double _confidence = 0.0;
  List<String> _labels = [];
  bool _isLoading = true;
  bool _isPlant = false;

  static const String modelPath = 'assets/ml_model/model_unquant.tflite';
  static const String labelPath = 'assets/ml_model/labels.txt';
  static const int inputSize = 224;
  late Uint8List _cachedModelBytes;

  late FlutterTts _flutterTts; // ✅ Added TTS instance

  @override
  void initState() {
    super.initState();
    _flutterTts = FlutterTts(); // ✅ Initialize TTS
    _loadLabels();
  }

  @override
  void dispose() {
    _flutterTts.stop(); // ✅ Stop TTS when leaving screen
    super.dispose();
  }

  // ✅ Function to speak prediction
  Future<void> _speak(String text) async {
    if (text.isEmpty) return;
    final String cleaned =
    text.replaceAll('_', ' ').replaceAll('Not_a_Plant', 'No plant detected');
    await _flutterTts.setLanguage('en-US');
    await _flutterTts.setPitch(1.0);
    await _flutterTts.speak(cleaned);
  }

  Future<void> _loadLabels() async {
    try {
      final rawLabels = await rootBundle.loadString(labelPath);
      _labels = rawLabels
          .split('\n')
          .map((s) => s.trim().split(' ').last)
          .where((s) => s.isNotEmpty)
          .toList();

      final modelData = await rootBundle.load(modelPath);
      _cachedModelBytes = modelData.buffer.asUint8List();

      setState(() {
        _isLoading = false;
        _prediction = 'Pick an image';
      });
    } catch (e) {
      setState(() {
        _prediction = 'Error loading model: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    if (_isLoading) return;

    final picker = ImagePicker();
    final pickedFile =
    await picker.pickImage(source: source, imageQuality: 70, maxWidth: 1000);
    if (pickedFile == null) return;

    setState(() {
      _image = File(pickedFile.path);
      _prediction = 'Processing...';
      _confidence = 0.0;
      _isLoading = true;
      _isPlant = false;
    });

    final imageBytes = await pickedFile.readAsBytes();
    final RootIsolateToken? rootToken = RootIsolateToken.instance;

    if (rootToken == null) {
      setState(() => _prediction = 'Isolate token error.');
      return;
    }

    await _runInference(imageBytes, rootToken);
  }

  Future<void> _runInference(Uint8List imageBytes, RootIsolateToken rootToken) async {
    try {
      final probs = await compute(runInferenceInBackground, {
        'imageBytes': imageBytes,
        'modelBytes': _cachedModelBytes,
        'inputSize': inputSize,
        'numLabels': _labels.length,
        'rootIsolateToken': rootToken,
      });

      if (probs == null) {
        setState(() => _prediction = 'Inference failed.');
        return;
      }

      int bestIndex = probs.indexWhere((v) => v == probs.reduce(max));
      double maxConf = probs[bestIndex];
      String predictedLabel = _labels[bestIndex];
      const double confidenceThreshold = 0.70;

      if (predictedLabel.toLowerCase().contains('not_a_plant') ||
          maxConf < confidenceThreshold) {
        setState(() {
          _prediction = 'Not_a_Plant';
          _confidence = maxConf;
          _isPlant = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              '🚫 No valid plant detected. Please use a clear, centered leaf image.',
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.redAccent,
            duration: Duration(seconds: 3),
          ),
        );
        return;
      }

      final plant = widget.dataService.getPlantByCommonName(predictedLabel);
      if (plant != null && _image != null) {
        await _historyService.addHistoryEntry(
          imageFile: _image!,
          commonName: plant.commonName,
          scientificName: plant.scientificName,
          method: 'Identify (ML)',
          predictedClass: predictedLabel,
          confidence: maxConf,
        );
      }

      setState(() {
        _prediction = predictedLabel;
        _confidence = maxConf;
        _isPlant = true;
      });
    } catch (e, st) {
      print('MAIN THREAD ERROR: $e');
      print(st);
      setState(() => _prediction = 'Inference crashed: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _navigateToDetails(String commonName) {
    final plant = widget.dataService.getPlantByCommonName(commonName);
    if (plant != null) {
      Navigator.push(
        context,
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => PlantDetailsScreen(
            plant: plant,
            imagePath: _image?.path,
          ),
          transitionsBuilder: (_, animation, __, child) {
            return FadeTransition(
              opacity: CurvedAnimation(parent: animation, curve: Curves.easeInOut),
              child: child,
            );
          },
          transitionDuration: const Duration(milliseconds: 600),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isNotAPlant = _prediction == 'Not_a_Plant';
    final bool showDetails = _confidence > 0.0 &&
        !_prediction.contains('Error') &&
        !_prediction.contains('Awaiting') &&
        !_prediction.contains('Processing') &&
        !isNotAPlant;

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFE8F5E9), Color(0xFFC8E6C9)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // --- IMAGE PREVIEW ---
            Container(
              height: 250,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.green, width: 2),
              ),
              child: _image == null
                  ? Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Text(
                    '📸 Please upload a clear, centered image of a plant leaf.\n\n'
                        '🌿 This helps ensure accurate identification and results.',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 16,
                      fontStyle: FontStyle.italic,
                      height: 1.5,
                    ),
                  ),
                ),
              )
                  : ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.file(_image!, fit: BoxFit.cover),
              ),
            ),
            const SizedBox(height: 20),

            // --- CAMERA + GALLERY BUTTONS ---
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.camera_alt),
                    label: const Text('Camera'),
                    onPressed: _isLoading ? null : () => _pickImage(ImageSource.camera),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green[700],
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.photo),
                    label: const Text('Gallery'),
                    onPressed: _isLoading ? null : () => _pickImage(ImageSource.gallery),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green[700],
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 25),

            // --- RESULT CARD ---
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const Text(
                      'Prediction Result',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Divider(),
                    if (_isLoading)
                      const CircularProgressIndicator()
                    else
                      Column(
                        children: [
                          Center(
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  isNotAPlant ? '🚫 No Results Found' : _prediction,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black87,
                                  ),
                                ),
                                if (!isNotAPlant &&
                                    !_prediction.contains('Awaiting') &&
                                    !_prediction.contains('Processing'))
                                  Padding(
                                    padding: const EdgeInsets.only(left: 8.0),
                                    child: IconButton(
                                      icon: const Icon(Icons.volume_up, color: Colors.green, size: 26),
                                      tooltip: 'Speak',
                                      onPressed: () => _speak(_prediction),
                                    ),
                                  ),
                              ],
                            ),
                          ),

                          if (!isNotAPlant && _confidence > 0.0)
                            Text(
                              'Confidence: ${(100 * _confidence).toStringAsFixed(2)}%',
                              style: const TextStyle(color: Colors.grey),
                            ),
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 600),
                            child: showDetails
                                ? Column(
                              key: const ValueKey('details_section'),
                              children: [
                                ElevatedButton.icon(
                                  icon: const Icon(Icons.info_outline),
                                  label: const Text('View Details'),
                                  onPressed: () =>
                                      _navigateToDetails(_prediction),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.teal,
                                    foregroundColor: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                AnimatedOpacity(
                                  opacity: showDetails ? 1.0 : 0.0,
                                  duration:
                                  const Duration(milliseconds: 800),
                                  child: Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: Colors.red.shade50,
                                      borderRadius:
                                      BorderRadius.circular(8),
                                    ),
                                    child: const Text(
                                      'Disclaimer: This plant identification result is for informational purposes only. '
                                          'Always verify plant identity before using it for medicinal or edible purposes.',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: Colors.redAccent,
                                        fontStyle: FontStyle.italic,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            )
                                : const SizedBox.shrink(),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),

            // 🌿 TIPS FOR BETTER RESULTS
            if (isNotAPlant) ...[
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.white, Color(0xFFE8F5E9)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.green.withOpacity(0.15),
                      offset: const Offset(0, 2),
                      blurRadius: 4,
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Center(
                      child: Text(
                        '🌿 Tips for Better Results',
                        style: TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      '• Use a clear photo of a single leaf, centered in the frame.\n'
                          '• Avoid cluttered backgrounds or other plants.\n'
                          '• Ensure good natural daylight or consistent lighting.\n'
                          '• Try to capture a healthy leaf (no heavy damage or discoloration).',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black87,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
