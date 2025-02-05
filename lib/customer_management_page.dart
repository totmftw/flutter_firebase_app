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

  void _addCustomer() async {
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
  }

  void _deleteCustomer(String id) async {
    await _firestore.collection('b2b_customers').doc(id).delete();
  }

  Future<void> _uploadExcel() async {
    FilePickerResult? result = await FilePicker.platform
        .pickFiles(type: FileType.custom, allowedExtensions: ['xlsx']);
    if (result != null) {
      Uint8List bytes = result.files.single.bytes!;
      var excel = Excel.decodeBytes(bytes);
      for (var table in excel.tables.keys) {
        for (var row in excel.tables[table]!.rows.skip(1)) {
          _firestore.collection('b2b_customers').add({
            'business_name': row[0]?.value,
            'gst_number': row[1]?.value,
            'business_contact': row[2]?.value,
            'billing_address': {
              'street': row[3]?.value,
              'city': row[4]?.value,
              'state': row[5]?.value,
              'pincode': row[6]?.value
            },
            'payment_terms': {
              'credit_limit': row[7]?.value,
              'due_days': row[8]?.value,
              'overdue_amount': row[9]?.value
            },
            'created_at': DateTime.now().toIso8601String()
          });
        }
      }
    }
  }

  Future<void> _downloadTemplate() async {
    var excel = Excel.createExcel();
    Sheet sheetObject = excel['Sheet1'];
    List<CellValue?> row = [
      CellValue.text('Business Name'),
      CellValue.text('GST Number'),
      CellValue.text('Business Contact'),
      CellValue.text('Street'),
      CellValue.text('City'),
      CellValue.text('State'),
      CellValue.text('Pincode'),
      CellValue.numeric(0),
      CellValue.numeric(0),
      CellValue.numeric(0)
    ];
    sheetObject.appendRow(row);

    Directory dir = await getApplicationDocumentsDirectory();
    String filePath = '${dir.path}/customer_template.xlsx';
    File(filePath)
      ..createSync(recursive: true)
      ..writeAsBytesSync(excel.encode()!);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Customer Management')),
      body: StreamBuilder(
        stream: _firestore.collection('b2b_customers').snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }
          var customers = snapshot.data!.docs;
          return ListView.builder(
            itemCount: customers.length,
            itemBuilder: (context, index) {
              var customer = customers[index];
              return ListTile(
                title: Text(customer['business_name']),
                subtitle: Text('GST: ${customer['gst_number']}'),
                trailing: IconButton(
                  icon: Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _deleteCustomer(customer.id),
                ),
              );
            },
          );
        },
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
    );
  }
}
