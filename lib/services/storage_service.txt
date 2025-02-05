import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:logger/logger.dart';

class StorageService {
  final Logger logger = Logger();
  final firebase_storage.FirebaseStorage _storage = firebase_storage.FirebaseStorage.instance;

  // Upload a file
  Future<String?> uploadFile(String path, String fileName) async {
    try {
      File file = File(path);
      firebase_storage.TaskSnapshot snapshot = await _storage.ref('uploads/$fileName').putFile(file);
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      logger.e(e);
      return null;
    }
  }
}
