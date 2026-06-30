import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

class HistoryService {
  final _firestore = FirebaseFirestore.instance;
  final _storage = FirebaseStorage.instance;
  final _auth = FirebaseAuth.instance;

  /// Add new history entry with image upload
  Future<void> addHistoryEntry({
    required File imageFile,
    required String commonName,
    required String scientificName,
    required String method,
    required String predictedClass,
    required double confidence,
  }) async {
    try {
      // 1️⃣ Ensure we have a valid user
      User? user = _auth.currentUser;
      if (user == null) {
        await _auth.signInAnonymously();
        user = _auth.currentUser;
      }
      if (user == null) {
        throw Exception("User authentication failed");
      }
      final userId = user.uid;

      // 2️⃣ Upload image to Firebase Storage
      final fileName =
          'history_images/${userId}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final storageRef = _storage.ref().child(fileName);

      await storageRef.putFile(imageFile);
      final imageUrl = await storageRef.getDownloadURL();

      // 3️⃣ Save history record in Firestore
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('history')
          .add({
        'commonName': commonName,
        'scientificName': scientificName,
        'method': method,
        'predictedClass': predictedClass,
        'confidence': confidence,
        'imageUrl': imageUrl,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print("🔥 ERROR in addHistoryEntry: $e");
      rethrow;
    }
  }

  /// Fetch user's history
  Stream<QuerySnapshot> getUserHistory() {
    final user = _auth.currentUser;
    if (user == null) return Stream.empty();

    return _firestore
        .collection('users')
        .doc(user.uid)
        .collection('history')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  /// Delete history entry (also removes image from storage)
  Future<void> deleteHistoryEntry(String docId, String imageUrl) async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      // Delete Firestore record
      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('history')
          .doc(docId)
          .delete();

      // Delete from Firebase Storage if image exists
      if (imageUrl.isNotEmpty) {
        await _storage.refFromURL(imageUrl).delete();
      }
    } catch (e) {
      print("🔥 ERROR deleting history: $e");
    }
  }
}
