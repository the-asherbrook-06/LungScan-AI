// Packages
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HistoryController {
  final _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  Future<void> saveResult({required Map<String, dynamic> result, required String imagePath}) async {
    final user = _auth.currentUser;
    if (user == null) return;

    final details = List.from(result['details']);
    details.sort((a, b) => b['confidence'].compareTo(a['confidence']));
    final top = details.first;

    await _db.collection('users').doc(user.uid).collection('history').add({
      'prediction': result['prediction'],
      'details': details,
      'imagePath': imagePath,
      'hasImage': true,
      'topDisease': top['disease'],
      'topConfidence': top['confidence'],
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  Future<void> deleteResult(String docId) async {
    final user = _auth.currentUser;
    if (user == null) return;

    await _db.collection('users').doc(user.uid).collection('history').doc(docId).delete();
  }

  Stream<QuerySnapshot> getHistory() {
    final user = _auth.currentUser;
    if (user == null) {
      return const Stream.empty();
    }

    return _db
        .collection('users')
        .doc(user.uid)
        .collection('history')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }
}
