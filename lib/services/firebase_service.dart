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
          options: FirebaseOptions(
            apiKey: const String.fromEnvironment('FIREBASE_API_KEY',
                defaultValue: 'YOUR_WEB_API_KEY'),
            authDomain: const String.fromEnvironment('FIREBASE_AUTH_DOMAIN',
                defaultValue: 'YOUR_WEB_AUTH_DOMAIN'),
            projectId: const String.fromEnvironment('FIREBASE_PROJECT_ID',
                defaultValue: 'YOUR_PROJECT_ID'),
            storageBucket: const String.fromEnvironment(
                'FIREBASE_STORAGE_BUCKET',
                defaultValue: 'YOUR_STORAGE_BUCKET'),
            messagingSenderId: const String.fromEnvironment(
                'FIREBASE_MESSAGING_SENDER_ID',
                defaultValue: 'YOUR_SENDER_ID'),
            appId: const String.fromEnvironment('FIREBASE_APP_ID',
                defaultValue: 'YOUR_WEB_APP_ID'),
          ),
        );
      } else {
        await Firebase.initializeApp();
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
    PlatformDispatcher.instance.onError = (error, stack) {
      _logger.e(
        'Platform error: $error',
        error: error,
        stackTrace: stack,
      );

      return true;
    };

    FlutterError.onError = (FlutterErrorDetails details) {
      _logger.e(
        'Unhandled Flutter Error',
        error: details.exception,
        stackTrace: details.stack,
      );
    };
  }
}
