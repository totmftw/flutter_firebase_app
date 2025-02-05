import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

class FirebaseService {
  static final Logger _logger = Logger();
  static bool _initialized = false;

  static Future<void> initializeFirebase() async {
    if (_initialized) return;

    try {
      WidgetsFlutterBinding.ensureInitialized();

      if (kIsWeb) {
        await Firebase.initializeApp(
          options: const FirebaseOptions(
              apiKey: 'YOUR_API_KEY',
              authDomain: 'YOUR_AUTH_DOMAIN',
              projectId: 'YOUR_PROJECT_ID',
              storageBucket: 'YOUR_STORAGE_BUCKET',
              messagingSenderId: 'YOUR_SENDER_ID',
              appId: 'YOUR_APP_ID'),
        );
      } else {
        await Firebase.initializeApp();
      }

      _initialized = true;
      _logger.i('Firebase initialized successfully');
    } catch (e, stackTrace) {
      _logger.e('Error initializing Firebase: $e');
      rethrow;
    }
  }

  static Future<void> handleAsyncError(
      Future<void> Function() operation) async {
    try {
      await operation();
    } catch (e, stackTrace) {
      _logger.e('Operation failed: $e');
      rethrow;
    }
  }

  static void configureErrorHandling() {
    FlutterError.onError = (FlutterErrorDetails details) {
      _logger.e('Flutter error: ${details.exception}');

      FlutterError.presentError(details);
    };

    PlatformDispatcher.instance.onError = (error, stack) {
      _logger.e('Platform error: $error');

      return true;
    };
  }
}
