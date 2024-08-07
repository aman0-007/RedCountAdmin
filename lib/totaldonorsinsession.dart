import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:syncfusion_flutter_xlsio/xlsio.dart' as xls; // Alias for Syncfusion's Column
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class Totaldonorsinsession extends StatefulWidget {
  final String documentId;
  final String sessionName;

  const Totaldonorsinsession({
    Key? key,
    required this.documentId,
    required this.sessionName,
  }) : super(key: key);

  @override
  State<Totaldonorsinsession> createState() => _TotaldonorsinsessionState();
}

class _TotaldonorsinsessionState extends State<Totaldonorsinsession> {
  late Future<List<Map<String, dynamic>>> _donorsFuture;

  @override
  void initState() {
    super.initState();
    _donorsFuture = _fetchDonors();
  }

  Future<List<Map<String, dynamic>>> _fetchDonors() async {
    try {
      FirebaseFirestore firestore = FirebaseFirestore.instance;
      DocumentSnapshot sessionDoc = await firestore
          .collection('hospital')
          .doc(widget.documentId)
          .collection('sessions')
          .doc(widget.sessionName)
          .get();

      Map<String, dynamic> donorsMap = sessionDoc['donors'] ?? {};
      List<Map<String, dynamic>> donorData = [];

      donorsMap.forEach((key, value) {
        donorData.add(value as Map<String, dynamic>);
      });

      return donorData;
    } catch (e) {
      print('Error fetching donors: $e');
      return [];
    }
  }

  Future<void> _exportToExcel(List<Map<String, dynamic>> donors) async {
    final xls.Workbook workbook = xls.Workbook();
    final xls.Worksheet sheet = workbook.worksheets[0];
    final List<String> headers = ['Name', 'Blood Group', 'DOB', 'Email', 'Gender', 'Phone'];

    // Add headers to the first row
    for (int i = 0; i < headers.length; i++) {
      sheet.getRangeByIndex(1, i + 1).setText(headers[i]);
    }

    // Add donor data
    for (int i = 0; i < donors.length; i++) {
      final donor = donors[i];
      sheet.getRangeByIndex(i + 2, 1).setText(donor['name'] ?? 'N/A');
      sheet.getRangeByIndex(i + 2, 2).setText(donor['bloodGroup'] ?? 'N/A');
      sheet.getRangeByIndex(i + 2, 3).setText(donor['dob'] ?? 'N/A');
      sheet.getRangeByIndex(i + 2, 4).setText(donor['email'] ?? 'N/A');
      sheet.getRangeByIndex(i + 2, 5).setText(donor['gender'] ?? 'N/A');
      sheet.getRangeByIndex(i + 2, 6).setText(donor['phone'] ?? 'N/A');
    }

    final List<int> bytes = workbook.saveAsStream();
    workbook.dispose();

    final directory = await getExternalStorageDirectory();
    final path = '${directory?.path}/Donors_${widget.sessionName}.xlsx';
    final file = File(path);
    await file.writeAsBytes(bytes, flush: true);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Excel file saved to $path')),
    );
  }

  Future<void> _handleExport() async {
    // Request storage permissions
    if (await Permission.storage.request().isGranted) {
      final donors = await _donorsFuture;
      await _exportToExcel(donors);
    } else {
      // Handle permission denied
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Storage permission denied')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Donors in ${widget.sessionName}'),
        actions: [
          IconButton(
            icon: Icon(Icons.download),
            onPressed: _handleExport,
          ),
        ],
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _donorsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No donors available.'));
          } else {
            final donors = snapshot.data!;
            return ListView.separated(
              separatorBuilder: (context, index) => Divider(height: 1, color: Colors.grey[300]),
              itemCount: donors.length,
              itemBuilder: (context, index) {
                final donor = donors[index];
                return ListTile(
                  contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  tileColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    side: BorderSide(color: Colors.grey.shade300, width: 0.5),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  title: Text(
                    donor['name'] ?? 'Unknown',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Blood Group: ${donor['bloodGroup'] ?? 'N/A'}'),
                      Text('DOB: ${donor['dob'] ?? 'N/A'}'),
                      Text('Email: ${donor['email'] ?? 'N/A'}'),
                      Text('Gender: ${donor['gender'] ?? 'N/A'}'),
                      Text('Phone: ${donor['phone'] ?? 'N/A'}'),
                    ],
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
