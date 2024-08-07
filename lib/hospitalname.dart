import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:redcountadmin/sessionname.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({Key? key}) : super(key: key);

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  List<Map<String, dynamic>> documents = []; // To store all documents with additional info

  @override
  void initState() {
    super.initState();
    fetchDocuments(); // Fetch documents when widget initializes
  }

  Future<void> fetchDocuments() async {
    try {
      FirebaseFirestore firestore = FirebaseFirestore.instance;
      QuerySnapshot hospitalQuery = await firestore.collection('hospital').get();

      List<Map<String, dynamic>> fetchedDocuments = [];

      for (var doc in hospitalQuery.docs) {
        String documentId = doc.id;
        String name = doc['name'];
        String email = doc['email'];

        // Fetch sessions count
        QuerySnapshot sessionsQuery = await firestore.collection('hospital')
            .doc(documentId)
            .collection('sessions')
            .get();
        int sessionsCount = sessionsQuery.size;

        // Calculate total donors count
        int donorsCount = 0;
        for (var sessionDoc in sessionsQuery.docs) {
          // Retrieve donors map from each session document
          Map<String, dynamic> donorsMap = sessionDoc['donors'] ?? {};
          donorsCount += donorsMap.length;
        }

        fetchedDocuments.add({
          'name': name,
          'email': email,
          'documentId': documentId,
          'sessionsCount': sessionsCount,
          'donorsCount': donorsCount,
        });
      }

      setState(() {
        documents = fetchedDocuments; // Update the state with fetched documents
      });
    } catch (e) {
      print('Error fetching documents: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dashboard'),
        backgroundColor: Colors.redAccent, // Red accent color for AppBar
      ),
      body: Center(
        child: documents.isEmpty
            ? CircularProgressIndicator() // Show loader while fetching
            : ListView.separated(
          separatorBuilder: (context, index) => Divider(height: 1, color: Colors.grey[300]),
          itemCount: documents.length,
          itemBuilder: (context, index) {
            final document = documents[index];
            return ListTile(
              contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              tileColor: Colors.white,
              shape: RoundedRectangleBorder(
                side: BorderSide(color: Colors.grey.shade300, width: 0.5),
                borderRadius: BorderRadius.circular(8),
              ),
              title: Text(
                document['name'],
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.email, size: 20, color: Colors.redAccent),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          document['email'],
                          style: TextStyle(
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.event, size: 20, color: Colors.redAccent),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Camps: ${document['sessionsCount']}',
                          style: TextStyle(
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.people, size: 20, color: Colors.redAccent),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Donors: ${document['donorsCount']}',
                          style: TextStyle(
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              onTap: () {
                // Navigate to Sessionname page and pass documentId
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Sessionname(documentId: document['documentId']),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
