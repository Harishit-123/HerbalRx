import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HistoryService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Add a new history entry for the logged-in user
  Future<void> addHistoryEntry({
    required File imageFile,
    required String label,
    required double confidence,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception("User not logged in");

    try {
      // Upload image to Firebase Storage
      final imageName = DateTime.now().millisecondsSinceEpoch.toString();
      final ref = _storage.ref().child('users/${user.uid}/history/$imageName.jpg');

      // Upload file
      await ref.putFile(imageFile);

      // Get download URL
      final imageUrl = await ref.getDownloadURL();

      // Store Firestore record
      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('history')
          .add({
        'imageUrl': imageUrl,
        'label': label,
        'confidence': confidence,
        'timestamp': FieldValue.serverTimestamp(),
      });

      print("✅ History entry added successfully.");
    } catch (e) {
      print("❌ Failed to add history entry: $e");
      throw Exception("Failed to add history entry: $e");
    }
  }

  /// Fetch user's history in descending order
  Stream<QuerySnapshot> getUserHistory() {
    final user = _auth.currentUser;
    if (user == null) throw Exception("User not logged in");

    return _firestore
        .collection('users')
        .doc(user.uid)
        .collection('history')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  /// Delete a specific history entry and its image
  Future<void> deleteHistoryEntry(String docId, String imageUrl) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception("User not logged in");

    try {
      // Delete Firestore document
      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('history')
          .doc(docId)
          .delete();

      // Delete image from Storage
      await _storage.refFromURL(imageUrl).delete();

      print("🗑️ History entry deleted successfully.");
    } catch (e) {
      print("❌ Failed to delete history entry: $e");
      throw Exception("Failed to delete history: $e");
    }
  }
}
