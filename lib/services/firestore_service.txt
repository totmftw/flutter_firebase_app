import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Add a new document
  Future<void> addDocument(String collection, Map<String, dynamic> data) async {
    await _firestore.collection(collection).add(data);
  }

  // Get documents from a collection
  Stream<List<DocumentSnapshot>> getDocuments(String collection) {
    return _firestore.collection(collection).snapshots().map((snapshot) => snapshot.docs);
  }
}
