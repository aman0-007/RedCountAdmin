import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_xlsio/xlsio.dart' as xlsio;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:path/path.dart' as p;

class ExcelDownloader {
  static Future<void> downloadExcel(List<DocumentSnapshot> users, BuildContext context) async {
    try {
      // Create a new Excel document
      final xlsio.Workbook workbook = xlsio.Workbook();
      final xlsio.Worksheet sheet = workbook.worksheets[0];

      // Adding the header row
      sheet.getRangeByName('A1').setText('Name');
      sheet.getRangeByName('B1').setText('Blood Group');
      sheet.getRangeByName('C1').setText('Gender');
      sheet.getRangeByName('D1').setText('DOB');
      sheet.getRangeByName('E1').setText('Age');
      sheet.getRangeByName('F1').setText('Phone');
      sheet.getRangeByName('G1').setText('Last Donation');

      // Adding user data
      for (int i = 0; i < users.length; i++) {
        Map<String, dynamic> userData = users[i].data() as Map<String, dynamic>;

        DateTime dob = _parseDateString(userData['dob']);
        int age = _calculateAge(dob, DateTime.now());
        String lastDonationDate = _formatDate(userData['lastDonationDate']);

        sheet.getRangeByIndex(i + 2, 1).setText(userData['name']);
        sheet.getRangeByIndex(i + 2, 2).setText(userData['BloodGroup']);
        sheet.getRangeByIndex(i + 2, 3).setText(userData['gender']);
        sheet.getRangeByIndex(i + 2, 4).setText(userData['dob']);
        sheet.getRangeByIndex(i + 2, 5).setText(age.toString());
        sheet.getRangeByIndex(i + 2, 6).setText(userData['phone']);
        sheet.getRangeByIndex(i + 2, 7).setText(lastDonationDate);
      }

      // Requesting storage permissions (for Android devices)
      var status = await Permission.storage.request();
      if (!status.isGranted) {
        print('Storage permission is not granted');
        return;
      }

      // Saving the Excel file to the local storage
      final directory = await getExternalStorageDirectory();
      final path = directory!.path;
      final file = File(p.join(path, 'users.xlsx'));

      List<int> bytes = workbook.saveAsStream();
      workbook.dispose();
      await file.writeAsBytes(bytes, flush: true);

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Excel file downloaded successfully!'),
      ));
    } catch (e) {
      print('Error while downloading Excel: $e');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Failed to download Excel file'),
      ));
    }
  }

  static DateTime _parseDateString(String dateString) {
    List<String> parts = dateString.split('/');
    if (parts.length != 3) {
      throw FormatException('Invalid date format');
    }

    int day = int.parse(parts[0]);
    int month = int.parse(parts[1]);
    int year = int.parse(parts[2]);

    // Return DateTime object
    return DateTime(year, month, day);
  }

  static int _calculateAge(DateTime dob, DateTime now) {
    int age = now.year - dob.year;
    if (now.month < dob.month || (now.month == dob.month && now.day < dob.day)) {
      age--;
    }
    return age;
  }

  static String _formatDate(Timestamp? timestamp) {
    if (timestamp == null) {
      return 'N/A'; // or any other default value or message
    }
    DateTime date = timestamp.toDate();
    return '${date.day}/${date.month}/${date.year}';
  }
}
