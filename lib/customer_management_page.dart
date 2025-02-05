import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:excel/excel.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';

class CustomerManagementPage extends StatefulWidget {
  @override
  _CustomerManagementPageState createState() => _CustomerManagementPageState();
}

class _CustomerManagementPageState extends State<CustomerManagementPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<String> customers = [];
  String newCustomerName = '';
  bool isDarkMode = false;

  void _addCustomer() async {
    try {
      await _firestore.collection('b2b_customers').add({
        'business_name': 'Sharma Electronics Pvt. Ltd.',
        'gst_number': '27AABCU9603R1Z2',
        'business_contact': '+91 9876543210',
        'billing_address': {
          'street': 'MG Road, Andheri East',
          'city': 'Mumbai',
          'state': 'Maharashtra',
          'pincode': '400001'
        },
        'payment_terms': {
          'credit_limit': 500000,
          'due_days': 30,
          'overdue_amount': 75000
        },
        'created_at': DateTime.now().toIso8601String()
      });
    } catch (e) {
      print('Error adding customer: $e');
    }
  }

  void _deleteCustomer(String id) async {
    try {
      await _firestore.collection('b2b_customers').doc(id).delete();
    } catch (e) {
      print('Error deleting customer: $e');
    }
  }

  Future<void> _uploadExcel() async {
    FilePickerResult? result = await FilePicker.platform
        .pickFiles(type: FileType.custom, allowedExtensions: ['xlsx']);
    if (result != null) {
      Uint8List bytes = result.files.single.bytes!;
      var excel = Excel.decodeBytes(bytes);
      for (var table in excel.tables.keys) {
        for (var row in excel.tables[table]!.rows.skip(1)) {
          String businessName = row[0]?.value is String ? row[0]!.value as String : '';
          String gstNumber = row[1]?.value is String ? row[1]!.value as String : '';
          String businessContact = row[2]?.value is String ? row[2]!.value as String : '';
          String street = row[3]?.value is String ? row[3]!.value as String : '';
          String city = row[4]?.value is String ? row[4]!.value as String : '';
          String state = row[5]?.value is String ? row[5]!.value as String : '';
          String pincode = row[6]?.value is String ? row[6]!.value as String : '';
          double creditLimit = row[7]?.value is num ? (row[7]!.value as num).toDouble() : 0.0;
          double dueDays = row[8]?.value is num ? (row[8]!.value as num).toDouble() : 0.0;
          double overdueAmount = row[9]?.value is num ? (row[9]!.value as num).toDouble() : 0.0;

          try {
            _firestore.collection('b2b_customers').add({
              'business_name': businessName,
              'gst_number': gstNumber,
              'business_contact': businessContact,
              'billing_address': {
                'street': street,
                'city': city,
                'state': state,
                'pincode': pincode
              },
              'payment_terms': {
                'credit_limit': creditLimit,
                'due_days': dueDays,
                'overdue_amount': overdueAmount
              },
              'created_at': DateTime.now().toIso8601String()
            });
          } catch (e) {
            print('Error uploading customer: $e');
          }
        }
      }
    }
  }

  Future<void> _downloadTemplate() async {
    var excel = Excel.createExcel();
    Sheet sheetObject = excel['Sheet1'];
    List<CellValue?> row = [
      TextCellValue('Business Name'),
      TextCellValue('GST Number'),
      TextCellValue('Business Contact'),
      TextCellValue('Street'),
      TextCellValue('City'),
      TextCellValue('State'),
      TextCellValue('Pincode'),
      IntCellValue(0),
      IntCellValue(0),
      IntCellValue(0)
    ];
    sheetObject.appendRow(row);

    Directory dir = await getApplicationDocumentsDirectory();
    String filePath = '${dir.path}/customer_template.xlsx';
    File(filePath)
      ..createSync(recursive: true)
      ..writeAsBytesSync(excel.encode()!);
  }

  void addCustomer() {
    if (newCustomerName.isNotEmpty) {
      setState(() {
        customers.add(newCustomerName);
        newCustomerName = '';
      });
    }
  }

  void deleteCustomer(int index) {
    setState(() {
      customers.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: isDarkMode ? ThemeData.dark() : ThemeData.light(),
      home: Scaffold(
        appBar: AppBar(
          title: Text('Customer Management'),
          actions: [
            IconButton(
              icon: Icon(isDarkMode ? Icons.wb_sunny : Icons.nights_stay),
              onPressed: () {
                setState(() {
                  isDarkMode = !isDarkMode;
                });
              },
            ),
          ],
        ),
        body: Row(
          children: <Widget>[
            NavigationDrawer(),
            Expanded(
              child: Column(
                children: <Widget>[
                  TextField(
                    onChanged: (value) {
                      newCustomerName = value;
                    },
                    decoration: InputDecoration(
                      labelText: 'New Customer Name',
                    ),
                  ),
                  ElevatedButton(
                    onPressed: addCustomer,
                    child: Text('Add Customer'),
                  ),
                  Expanded(
                    child: StreamBuilder(
                      stream: _firestore.collection('b2b_customers').snapshots(),
                      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                        if (!snapshot.hasData) {
                          return Center(child: CircularProgressIndicator());
                        }
                        var customers = snapshot.data!.docs;
                        return ListView.builder(
                          itemCount: customers.length,
                          itemBuilder: (context, index) {
                            return ListTile(
                              title: Text(customers[index]['business_name']),
                              subtitle: Text('GST: ${customers[index]['gst_number']}'),
                              trailing: IconButton(
                                icon: Icon(Icons.delete, color: Colors.red),
                                onPressed: () {
                                  try {
                                    _deleteCustomer(customers[index].id);
                                  } catch (e) {
                                    print('Error deleting customer: $e');
                                  }
                                },
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        floatingActionButton: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            FloatingActionButton(
              onPressed: _uploadExcel,
              child: Icon(Icons.upload_file),
            ),
            SizedBox(height: 10),
            FloatingActionButton(
              onPressed: _downloadTemplate,
              child: Icon(Icons.download),
            ),
            SizedBox(height: 10),
            FloatingActionButton(
              onPressed: _addCustomer,
              child: Icon(Icons.add),
            ),
          ],
        ),
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
              // Navigate to Transactions
            },
          ),
        ],
      ),
    );
  }
}
