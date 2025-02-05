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
            apiKey: 'YOUR_WEB_API_KEY',
            authDomain: 'YOUR_WEB_AUTH_DOMAIN',
            projectId: 'YOUR_PROJECT_ID',
            storageBucket: 'YOUR_STORAGE_BUCKET',
            messagingSenderId: 'YOUR_SENDER_ID',
            appId: 'YOUR_WEB_APP_ID',
            measurementId: 'YOUR_MEASUREMENT_ID', // Optional
          ),
        );
      } else {
        await Firebase.initializeApp(); // Shouldn't be called on web
      }

      _initialized = true;
      _logger.i('Firebase initialized successfully');
    } catch (e) {
      _logger.e('Error initializing Firebase: $e');
      rethrow;
    }
  }

  static Future<void> handleAsyncError(
      Future<void> Function() operation) async {
    try {
      await operation();
    } catch (e) {
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
