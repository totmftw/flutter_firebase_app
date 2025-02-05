library firebase_interop;

import 'package:flutter/material.dart';
import 'customer_management_page.dart';
import 'services/database_setup.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DatabaseInitializer.initializeCollections();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Business Intelligence App',
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      home: MainPage(),
      routes: {
        '/customers': (context) => CustomerManagementPage(),
      },
    );
  }
}

class MainPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Business Intelligence App')), 
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: 0,
            onDestinationSelected: (int index) {
              if (index == 0) {
                Navigator.pushNamed(context, '/'); // Home
              } else if (index == 1) {
                Navigator.pushNamed(context, '/customers'); // Customer Management
              }
              // Add more navigation options as needed
            },
            destinations: [
              NavigationRailDestination(
                icon: Icon(Icons.home),
                label: Text('Home'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.people),
                label: Text('Customers'),
              ),
              // Add more destinations here
            ],
          ),
          Expanded(child: Container()), // Main content area
        ],
      ),
    );
  }
}
