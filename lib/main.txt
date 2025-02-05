library firebase_interop;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'customer_management_page.dart';
import 'services/database_setup.dart';
import 'services/firebase_service.dart';
import 'providers/theme_provider.dart';
import 'widgets/theme_switch_animation.dart';

void main() async {
  try {
    await FirebaseService.initializeFirebase();
    FirebaseService.configureErrorHandling();
    await DatabaseInitializer.initializeCollections();
    runApp(const ProviderScope(child: MyApp()));
  } catch (e) {
    print('Failed to initialize app: $e');
    rethrow;
  }
}

class MyApp extends ConsumerWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeState = ref.watch(themeProvider);

    return MaterialApp(
      title: 'Business Intelligence App',
      theme: themeState.theme,
      home: const MainPage(),
      routes: {
        '/customers': (context) => CustomerManagementPage(),
      },
    );
  }
}

class MainPage extends ConsumerWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeState = ref.watch(themeProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Business Intelligence App'),
        actions: [
          PopupMenuButton<int>(
            icon: const Icon(Icons.palette),
            tooltip: 'Change Theme Color',
            onSelected: (index) =>
                ref.read(themeProvider.notifier).setThemeIndex(index),
            itemBuilder: (context) => [
              const PopupMenuItem(value: 0, child: Text('Blue Theme')),
              const PopupMenuItem(value: 1, child: Text('Purple Theme')),
              const PopupMenuItem(value: 2, child: Text('Green Theme')),
              const PopupMenuItem(value: 3, child: Text('Orange Theme')),
              const PopupMenuItem(value: 4, child: Text('Indigo Theme')),
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: ThemeSwitchAnimation(
              isDark: themeState.isDark,
              onTap: () => ref.read(themeProvider.notifier).toggleDarkMode(),
            ),
          ),
        ],
      ),
      body: Row(
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              return NavigationRail(
                extended: constraints.maxWidth >= 800,
                selectedIndex: 0,
                onDestinationSelected: (int index) {
                  if (index == 0) {
                    Navigator.pushNamed(context, '/');
                  } else if (index == 1) {
                    Navigator.pushNamed(context, '/customers');
                  }
                },
                destinations: const [
                  NavigationRailDestination(
                    icon: Icon(Icons.dashboard),
                    label: Text('Dashboard'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.people),
                    label: Text('Customers'),
                  ),
                ],
              );
            },
          ),
          const VerticalDivider(thickness: 1, width: 1),
          Expanded(
            child: Center(
              child: Text(
                'Welcome to Business Intelligence',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
