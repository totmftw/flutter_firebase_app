import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'providers/theme_provider.dart';
import 'pages/dashboard_page.dart';
import 'pages/customer_management_page.dart';
import 'firebase_service.dart';

Future<void> initializeApp() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase and register lifecycle listener early
  await FirebaseService.initializeFirebase();
  FirebaseService.registerLifecycleListener();

  SystemChannels.lifecycle.setMessageHandler((message) {
    print('Lifecycle message received: $message');
    return Future.value(null);
  });
}

void main() async {
  await initializeApp();
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeState = ref.watch(themeProvider);

    return MaterialApp(
      title: 'Business Intelligence App',
      theme: themeState.lightTheme,
      darkTheme: themeState.darkTheme,
      themeMode: themeState.mode,
      initialRoute: '/dashboard',
      routes: {
        '/dashboard': (context) => DashboardPage(),
        '/customers': (context) => CustomerManagementPage(),
      },
    );
  }
}

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
      ),
      body: const Center(
        child: Text('Welcome to the Dashboard!'),
      ),
    );
  }
}

class CustomerManagementPage extends StatelessWidget {
  const CustomerManagementPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Customer Management'),
      ),
      body: const Center(
        child: Text('Welcome to Customer Management!'),
      ),
    );
  }
}
