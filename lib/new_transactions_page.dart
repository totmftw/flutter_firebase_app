import 'package:flutter/material.dart';

class NewTransactionsPage extends StatefulWidget {
  @override
  _NewTransactionsPageState createState() => _NewTransactionsPageState();
}

class _NewTransactionsPageState extends State<NewTransactionsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Transactions'),
      ),
      body: Row(
        children: <Widget>[
          // Sidebar
          NavigationDrawer(),
          // Main content
          Expanded(
            child: TransactionsList(),
          ),
        ],
      ),
    );
  }
}

class NavigationDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            child: Text('Navigation'),
            decoration: BoxDecoration(
              color: Colors.blue,
            ),
          ),
          ListTile(
            title: Text('Home'),
            onTap: () {
              // Navigate to Home
            },
          ),
          ListTile(
            title: Text('Transactions'),
            onTap: () {
              // Stay on Transactions
            },
          ),
        ],
      ),
    );
  }
}

class TransactionsList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView(
      children: <Widget>[
        // Example transaction item
        ListTile(
          title: Text('Transaction 1'),
          subtitle: Text('Date: 05-02-2025'),
        ),
        // More transactions...
      ],
    );
  }
}

