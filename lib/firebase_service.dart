import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:logger/logger.dart';
import 'dart:convert';

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
            apiKey: 'AIzaSyDBW6HL0ZNY4SjDr8DxcZ_W4Wct1AmG7ng',
            appId: '1:619173627914:web:4937756afac9734013f7f3',
            messagingSenderId: '619173627914',
            projectId: 'fbase-f6c37',
            storageBucket: 'fbase-f6c37.firebasestorage.app',
            authDomain: 'fbase-f6c37.firebaseapp.com',
            measurementId: 'G-DFQM4C2LL6'
          ),
        );
      } else {
        await Firebase.initializeApp();
      }

      _initialized = true;
      _logger.i('Firebase initialized successfully');
    } catch (e) {
      _logger.e('Error initializing Firebase', error: e);
      rethrow;
    }
  }

  static Future<void> handleAsyncError(
      Future<void> Function() operation) async {
    try {
      await operation();
    } catch (e) {
      _logger.e('Operation failed', error: e);
      rethrow;
    }
  }

  static void configureErrorHandling() {
    FlutterError.onError = (FlutterErrorDetails details) {
      _logger.e(
        'Flutter error: ${details.exception}',
        error: details.exception,
        stackTrace: details.stack,
      );

      FlutterError.presentError(details);
    };

    PlatformDispatcher.instance.onError = (error, stack) {
      _logger.e(
        'Platform error: $error',
        error: error,
        stackTrace: stack,
      );

      return true;
    };
  }

  static final MethodChannel _channel = MethodChannel(
    'flutter/lifecycle',
    const JSONMethodCodec(),
    ServicesBinding.instance.defaultBinaryMessenger,
  );

  static void registerLifecycleListener() {
    _channel.setMethodCallHandler((MethodCall call) async {
      // Handle lifecycle events here
    });
  }

  static Future<void> initialize() async {
    await initializeFirebase();
    registerLifecycleListener();
    configureErrorHandling();
    // Other initialization code if needed
  }

  static void parseJson(String responseBody) {
    try {
      var jsonData = jsonDecode(responseBody);
      // Ensure that jsonData is a List
      if (jsonData is List) {
        // Process data
      } else {
        throw Exception('Expected a List');
      }
    } catch (e) {
      print('Error parsing JSON: $e');
    }
  }
}
