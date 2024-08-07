import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:redcountadmin/totaldonorsinsession.dart';

class Sessionname extends StatefulWidget {
  final String documentId;

  const Sessionname({Key? key, required this.documentId}) : super(key: key);

  @override
  State<Sessionname> createState() => _SessionnameState();
}

class _SessionnameState extends State<Sessionname> {
  late Future<List<Map<String, dynamic>>> _sessionsFuture;

  @override
  void initState() {
    super.initState();
    _sessionsFuture = _fetchSessions();
  }

  Future<List<Map<String, dynamic>>> _fetchSessions() async {
    try {
      FirebaseFirestore firestore = FirebaseFirestore.instance;
      QuerySnapshot sessionsQuery = await firestore
          .collection('hospital')
          .doc(widget.documentId)
          .collection('sessions')
          .get();

      List<Map<String, dynamic>> sessionData = [];

      for (var sessionDoc in sessionsQuery.docs) {
        String sessionName = sessionDoc['name'] ?? 'Unknown';
        Map<String, dynamic> donorsMap = sessionDoc['donors'] ?? {};
        int donorsCount = donorsMap.length;

        sessionData.add({
          'sessionName': sessionName,
          'donorsCount': donorsCount,
          'sessionId': sessionDoc.id, // Add session ID
        });
      }

      return sessionData;
    } catch (e) {
      print('Error fetching sessions: $e');
      return []; // Handle error as needed
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sessions'),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _sessionsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No sessions available.'));
          } else {
            final sessions = snapshot.data!;
            return ListView.separated(
              separatorBuilder: (context, index) => Divider(height: 1, color: Colors.grey[300]),
              itemCount: sessions.length,
              itemBuilder: (context, index) {
                final session = sessions[index];
                return ListTile(
                  contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  tileColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    side: BorderSide(color: Colors.grey.shade300, width: 0.5),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  title: Text(
                    session['sessionName'],
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  subtitle: Text(
                    'Donors: ${session['donorsCount']}',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                  onTap: () {
                    // Pass the session ID and session name to the target page
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Totaldonorsinsession(
                          documentId: widget.documentId,
                          sessionName: session['sessionName'],
                        ),
                      ),
                    );
                  },
                );
              },
            );
          }
        },
      ),
    );
  }
}
