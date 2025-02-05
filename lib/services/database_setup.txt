import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseInitializer {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static Future<void> initializeCollections() async {
    await _createCollectionIfNotExists('CustomerMaster', {
      'name': 'Dummy Customer',
      'email': 'dummy@example.com',
      'phone': '+911234567890',
      'address': 'Mumbai, India',
      'createdAt': FieldValue.serverTimestamp()
    });

    await _createCollectionIfNotExists('InvoiceTable', {
      'invCustid': 'dummy_customer_id',
      'amount': 0.0,
      'date': _formatDate(DateTime.now()),
      'status': 'Pending',
      'createdAt': FieldValue.serverTimestamp()
    });

    await _createCollectionIfNotExists('PaymentLedger', {
      'custId': 'dummy_customer_id',
      'invId': 'dummy_invoice_id',
      'amount': 0.0,
      'date': _formatDate(DateTime.now()),
      'createdAt': FieldValue.serverTimestamp()
    });

    await _createCollectionIfNotExists('PaymentTransactions', {
      'invId': 'dummy_invoice_id',
      'amount': 0.0,
      'date': _formatDate(DateTime.now()),
      'createdAt': FieldValue.serverTimestamp()
    });

    await _createCollectionIfNotExists('FeaturePermissions', {
      'parent_id': null,
      'feature_name': 'root',
      'createdAt': FieldValue.serverTimestamp()
    });

    await _createCollectionIfNotExists('UserProfiles', {
      'name': 'Admin User',
      'email': 'admin@example.com',
      'reports_to': null,
      'createdAt': FieldValue.serverTimestamp()
    });
  }

  static Future<void> _createCollectionIfNotExists(
      String collectionName, Map<String, dynamic> dummyData) async {
    try {
      final docRef = _firestore.collection(collectionName).doc('dummy_doc');
      await docRef.set(dummyData);
      await docRef.delete(); // Remove dummy document after creation
    } catch (e) {
      print('Error initializing $collectionName: $e');
    }
  }

  static String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2,'0')}-'
        '${date.month.toString().padLeft(2,'0')}-'
        '${date.year.toString().substring(2)}';
  }
}
