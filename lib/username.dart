import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:redcountadmin/downloadUserExcel.dart';

class Username extends StatefulWidget {
  const Username({Key? key}) : super(key: key);

  @override
  State<Username> createState() => _UsernameState();
}

class _UsernameState extends State<Username> {
  late Future<QuerySnapshot> _usersFuture;

  @override
  void initState() {
    super.initState();
    _usersFuture = _fetchUsers();
  }

  Future<QuerySnapshot> _fetchUsers() async {
    try {
      QuerySnapshot usersSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .get();

      return usersSnapshot;
    } catch (e) {
      print('Error fetching users: $e');
      rethrow; // Handle error as needed
    }
  }

  DateTime parseDateString(String dateString) {
    List<String> parts = dateString.split('/');
    if (parts.length != 3) {
      throw const FormatException('Invalid date format');
    }

    int day = int.parse(parts[0]);
    int month = int.parse(parts[1]);
    int year = int.parse(parts[2]);

    // Return DateTime object
    return DateTime(year, month, day);
  }

  int calculateAge(DateTime dob, DateTime now) {
    int age = now.year - dob.year;
    if (now.month < dob.month || (now.month == dob.month && now.day < dob.day)) {
      age--;
    }
    return age;
  }

  String formatDate(Timestamp? timestamp) {
    if (timestamp == null) {
      return 'N/A'; // or any other default value or message
    }
    DateTime date = timestamp.toDate();
    return '${date.day}/${date.month}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Users List'),
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: () async {
              QuerySnapshot usersSnapshot = await _usersFuture;
              await ExcelDownloader.downloadExcel(usersSnapshot.docs, context);
            },
          ),
        ],
      ),
      body: FutureBuilder<QuerySnapshot>(
        future: _usersFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No users found', style: TextStyle(fontSize: 18, color: Colors.grey)));
          }

          // Extract user documents from snapshot
          List<DocumentSnapshot> users = snapshot.data!.docs;

          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              Map<String, dynamic> userData = users[index].data()
              as Map<String, dynamic>; // Extract data from each document

              // Parse date of birth and calculate age
              DateTime dob = parseDateString(userData['dob']);
              DateTime now = DateTime.now();
              int age = calculateAge(dob, now);

              // Format last donation date
              Timestamp? lastDonationTimestamp = userData['lastDonationDate'];
              String lastDonationDate = formatDate(lastDonationTimestamp);

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 2,
                child: ListTile(
                  contentPadding: const EdgeInsets.all(12),
                  tileColor: Colors.white,
                  title: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                        decoration: BoxDecoration(
                          color: Colors.redAccent.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.redAccent, width: 1.5),
                        ),
                        child: Text(
                          '${userData['BloodGroup']}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.redAccent,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${userData['name']}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Text('Gender: ${userData['gender']}', style: const TextStyle(fontSize: 14)),
                                const SizedBox(width: 10),
                                Text('Age: $age years', style: const TextStyle(fontSize: 14)),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text('Phone: ${userData['phone']}', style: const TextStyle(fontSize: 14)),
                            const SizedBox(height: 4),
                            Text('Last Donation: $lastDonationDate', style: const TextStyle(fontSize: 14)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  onTap: () {
                    // Navigate to detailed view or perform action on tap if needed
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
