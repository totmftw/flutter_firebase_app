import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:excel/excel.dart';
import 'dart:html' as html;
import 'package:flutter/foundation.dart' show kIsWeb;

class TransactionsPage extends StatelessWidget {
  const TransactionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Transactions'),
      ),
      body: DefaultTabController(
        length: 3,
        child: Column(
          children: <Widget>[
            TabBar(
              tabs: <Widget>[
                Tab(text: 'Invoices'),
                Tab(text: 'Payments'),
                Tab(text: 'Ledger'),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: <Widget>[
                  InvoicesTab(),
                  PaymentsTab(),
                  LedgerTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class InvoicesTab extends StatefulWidget {
  const InvoicesTab({super.key});

  @override
  _InvoicesTabState createState() => _InvoicesTabState();
}

class _InvoicesTabState extends State<InvoicesTab> {
  String selectedYear = '2025'; // Default year
  final List<String> years = ['2023', '2024', '2025', '2026', '2027'];
  List<Map<String, dynamic>> invoices = [];

  void downloadFile(String url, String fileName) async {
    if (kIsWeb) {
      final blob = html.Blob([url.codeUnits]);
      final url = html.Url.createObjectUrlFromBlob(blob);
      html.window.open(url, '_blank');
      html.Url.revokeObjectUrl(url);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        DropdownButton<String>(
          value: selectedYear,
          onChanged: (String? newValue) {
            setState(() {
              selectedYear = newValue!;
            });
          },
          items: years.map<DropdownMenuItem<String>>((String year) {
            return DropdownMenuItem<String>(
              value: year,
              child: Text(year),
            );
          }).toList(),
        ),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: _addSingleInvoice,
                  child: Text('Add Single Invoice'),
                ),
                ElevatedButton(
                  onPressed: _downloadTemplate,
                  child: Text('Download Template'),
                ),
                ElevatedButton(
                  onPressed: _uploadInvoices,
                  child: Text('Upload Invoices'),
                ),
              ],
            ),
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columns: [
                DataColumn(label: Text('Invoice ID')),
                DataColumn(label: Text('Customer ID')),
                DataColumn(label: Text('Amount')),
                DataColumn(label: Text('Date')),
                DataColumn(label: Text('Status')),
              ],
              rows: invoices.map((invoice) {
                return DataRow(
                  cells: [
                    DataCell(Text(invoice['invId'].toString())),
                    DataCell(Text(invoice['invCustid'].toString())),
                    DataCell(Text(invoice['amount'].toString())),
                    DataCell(Text(invoice['date'].toString())),
                    DataCell(Text(invoice['status'].toString())),
                  ],
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  void _addSingleInvoice() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final invoiceNumberController = TextEditingController();
        final dateController = TextEditingController();
        final customerIdController = TextEditingController();
        final amountController = TextEditingController();
        final statusController = TextEditingController();

        return AlertDialog(
          title: Text('Add Single Invoice'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: invoiceNumberController,
                  decoration: InputDecoration(labelText: 'Invoice ID'),
                ),
                TextField(
                  controller: customerIdController,
                  decoration: InputDecoration(labelText: 'Customer ID'),
                ),
                TextField(
                  controller: amountController,
                  decoration: InputDecoration(labelText: 'Amount'),
                ),
                TextField(
                  controller: dateController,
                  decoration: InputDecoration(labelText: 'Date'),
                ),
                TextField(
                  controller: statusController,
                  decoration: InputDecoration(labelText: 'Status'),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Submit'),
              onPressed: () async {
                // Validate and submit the invoice data
                var invoiceData = {
                  'invId': invoiceNumberController.text,
                  'invCustid': customerIdController.text,
                  'amount': amountController.text,
                  'date': dateController.text,
                  'status': statusController.text,
                };

                // Check for duplicates
                var existingInvoices = await FirebaseFirestore.instance
                    .collection('invoiceTable')
                    .get();
                bool isDuplicate = existingInvoices.docs
                    .any((doc) => doc['invId'] == invoiceData['invId']);

                if (isDuplicate) {
                  // Show error popup
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text('Error'),
                        content: Text('Duplicate invoice ID found!'),
                        actions: <Widget>[
                          TextButton(
                            child: Text('OK'),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                        ],
                      );
                    },
                  );
                } else {
                  // Add the invoice to Firestore
                  await FirebaseFirestore.instance
                      .collection('invoiceTable')
                      .add(invoiceData);
                  invoices.add(invoiceData);
                  Navigator.of(context).pop();
                  // Show success popup
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text('Success'),
                        content: Text('Invoice added successfully!'),
                        actions: <Widget>[
                          TextButton(
                            child: Text('OK'),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                        ],
                      );
                    },
                  );
                }
              },
            ),
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _downloadTemplate() {
    String url = ''; // Initialized with a default value
    final excel = Excel.createExcel();
    Sheet sheet = excel['Sheet1'];
    List<CellValue?> row = [
      TextCellValue('Invoice ID'),
      TextCellValue('Customer ID'),
      IntCellValue(0),
      DateTimeCellValue(DateTime.now()),
      TextCellValue('Status')
    ];
    sheet.appendRow(row);
    // Save the Excel file
    final bytes = excel.save();
    if (kIsWeb) {
      final blob = html.Blob([bytes]);
      final url = html.Url.createObjectUrlFromBlob(blob);
      html.window.open(url, '_blank');
      html.Url.revokeObjectUrl(url);
    }
  }

  void _uploadInvoices() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xlsx'],
    );

    if (result != null) {
      final bytes = result.files.first.bytes;
      final excel = Excel.decodeBytes(bytes!);

      // Assuming the first sheet contains the invoice data
      final sheet = excel.tables.keys.first;
      for (var row in excel.tables[sheet]!.rows) {
        String invCustid = row[0]?.value is String ? row[0]!.value as String : 'N/A';
        String invId = row[1]?.value is String ? row[1]!.value as String : 'N/A';
        double amount = row[2]?.value is num ? (row[2]!.value as num).toDouble() : 0.0;
        DateTime date = convertExcelSerialToDate(row[3]?.value is int ? row[3]!.value as int : 0) ?? DateTime.now();
        String status = row[4]?.value is String ? row[4]!.value as String : 'N/A';

        var invoiceData = {
          'invCustid': invCustid,
          'invId': invId,
          'amount': amount,
          'date': date,
          'status': status,
        };

        // Check for duplicates
        var existingInvoices =
            await FirebaseFirestore.instance.collection('invoiceTable').get();
        bool isDuplicate = existingInvoices.docs
            .any((doc) => doc['invId'] == invoiceData['invId']);

        if (isDuplicate) {
          // Show duplicate notification
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text('Duplicate Found'),
                content: Text('Duplicate invoice ID: ${invoiceData['invId']}'),
                actions: <Widget>[
                  TextButton(
                    child: Text('OK'),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              );
            },
          );
        } else {
          await FirebaseFirestore.instance
              .collection('invoiceTable')
              .add(invoiceData);
          setState(() {
            invoices.add(invoiceData);
          });
        }
      }
      // Show success message after upload
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Upload Successful'),
            content: Text('Invoices uploaded successfully!'),
            actions: <Widget>[
              TextButton(
                child: Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }
  }

  DateTime? convertExcelSerialToDate(int serial) {
    final startDate = DateTime(1899, 12, 30);
    return startDate.add(Duration(days: serial));
  }
}

class PaymentsTab extends StatefulWidget {
  const PaymentsTab({super.key});

  @override
  _PaymentsTabState createState() => _PaymentsTabState();
}

class _PaymentsTabState extends State<PaymentsTab> {
  String selectedYear = '2025'; // Default year
  final List<String> years = ['2023', '2024', '2025', '2026', '2027'];
  List<Map<String, dynamic>> payments = [];

  void downloadFile(String url, String fileName) async {
    if (kIsWeb) {
      final blob = html.Blob([url.codeUnits]);
      final url = html.Url.createObjectUrlFromBlob(blob);
      html.window.open(url, '_blank');
      html.Url.revokeObjectUrl(url);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        DropdownButton<String>(
          value: selectedYear,
          onChanged: (String? newValue) {
            setState(() {
              selectedYear = newValue!;
            });
          },
          items: years.map<DropdownMenuItem<String>>((String year) {
            return DropdownMenuItem<String>(
              value: year,
              child: Text(year),
            );
          }).toList(),
        ),
        ElevatedButton(
          onPressed: _addPayment,
          child: Text('Add Payment'),
        ),
        ElevatedButton(
          onPressed: _downloadPaymentTemplate,
          child: Text('Download Payment Template'),
        ),
        ElevatedButton(
          onPressed: _uploadPayments,
          child: Text('Upload Payments'),
        ),
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columns: [
                DataColumn(label: Text('Payment ID')),
                DataColumn(label: Text('Invoice Number')),
                DataColumn(label: Text('Date')),
                DataColumn(label: Text('Amount')),
                DataColumn(label: Text('Status')),
              ],
              rows: payments.map((payment) {
                return DataRow(
                  cells: [
                    DataCell(Text(payment['payment_id'].toString())),
                    DataCell(Text(payment['invoice_number'].toString())),
                    DataCell(Text(payment['date'].toString())),
                    DataCell(Text(payment['amount'].toString())),
                    DataCell(Text(payment['status'].toString())),
                  ],
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  void _addPayment() {
    // Logic to add a single payment
    // This could open a dialog or navigate to another page
  }

  void _downloadPaymentTemplate() {
    String url = ''; // Initialize with a default value
    final excel = Excel.createExcel();
    Sheet sheet = excel['Sheet1'];
    List<CellValue?> row = [
      TextCellValue('Payment ID'),
      TextCellValue('Invoice Number'),
      DateTimeCellValue(DateTime.now()),
      IntCellValue(0),
      TextCellValue('Status')
    ];
    sheet.appendRow(row);
    // Save the Excel file
    final bytes = excel.save();
    if (kIsWeb) {
      final blob = html.Blob([bytes]);
      final url = html.Url.createObjectUrlFromBlob(blob);
      html.window.open(url, '_blank');
      html.Url.revokeObjectUrl(url);
    }
  }

  void _uploadPayments() async {
    // Logic to upload payments from an Excel file
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xlsx'],
    );

    if (result != null) {
      final bytes = result.files.first.bytes;
      final excel = Excel.decodeBytes(bytes!);
      // Assuming the first sheet contains the payment data
      final sheet = excel.tables.keys.first;
      for (var row in excel.tables[sheet]!.rows) {
        // Extract data from each row and save to Firestore
        String paymentId = row[0]?.value is String ? row[0]!.value as String : 'N/A';
        String invoiceNumber = row[1]?.value is String ? row[1]!.value as String : 'N/A';
        DateTime date = convertExcelSerialToDate(row[2]?.value is int ? row[2]!.value as int : 0) ?? DateTime.now();
        double amount = row[3]?.value is num ? (row[3]!.value as num).toDouble() : 0.0;
        String status = row[4]?.value is String ? row[4]!.value as String : 'N/A';

        var paymentData = {
          'payment_id': paymentId,
          'invoice_number': invoiceNumber,
          'date': date,
          'amount': amount,
          'status': status,
        };

        // Check for duplicates
        var existingPayments =
            await FirebaseFirestore.instance.collection('payments').get();
        bool isDuplicate = existingPayments.docs
            .any((doc) => doc['payment_id'] == paymentData['payment_id']);

        if (isDuplicate) {
          // Show duplicate notification
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text('Duplicate Found'),
                content:
                    Text('Duplicate payment ID: ${paymentData['payment_id']}'),
                actions: <Widget>[
                  TextButton(
                    child: Text('OK'),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              );
            },
          );
        } else {
          await FirebaseFirestore.instance
              .collection('payments')
              .add(paymentData);
          payments.add(paymentData);
        }
      }
      // Show success message after upload
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Upload Successful'),
            content: Text('Payments uploaded successfully!'),
            actions: <Widget>[
              TextButton(
                child: Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }
  }

  DateTime? convertExcelSerialToDate(int serial) {
    final startDate = DateTime(1899, 12, 30);
    return startDate.add(Duration(days: serial));
  }
}

class LedgerTab extends StatelessWidget {
  const LedgerTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('Ledger functionality goes here'),
    );
  }
}
