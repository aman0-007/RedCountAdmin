import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:redcountadmin/hospitalname.dart';
import 'package:redcountadmin/username.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await Permission.storage.request();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.red, // Use red color for overall theme
        scaffoldBackgroundColor: Colors.white, // Set scaffold background color
      ),
      home: MyHomePage(title: "Document Counts"),
    );
  }
}

class MyHomePage extends StatefulWidget {
  final String title;

  const MyHomePage({Key? key, required this.title}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int usersCount = 0;
  int hospitalCount = 0;

  @override
  void initState() {
    super.initState();
    fetchDocumentCounts();
  }

  void fetchDocumentCounts() async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    try {
      QuerySnapshot usersQuery = await firestore.collection('users').get();
      setState(() {
        usersCount = usersQuery.size;
      });

      QuerySnapshot hospitalQuery = await firestore.collection('hospital').get();
      setState(() {
        hospitalCount = hospitalQuery.size;
      });
    } catch (e) {
      print('Error fetching document counts: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        centerTitle: true,
        backgroundColor: Colors.redAccent, // Red accent color for the AppBar
        elevation: 4,
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/background.jpg'), // Add your background image
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                _buildHeader(),
                SizedBox(height: 20),
                _buildCountButton(
                  context,
                  'Users',
                  usersCount,
                  Icons.person,
                  Username(),
                ),
                SizedBox(height: 20),
                _buildCountButton(
                  context,
                  'Hospital',
                  hospitalCount,
                  Icons.local_hospital,
                  Dashboard(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Text(
          'Welcome to the Dashboard!',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.redAccent,
            letterSpacing: 1.2,
          ),
        ),
        SizedBox(height: 10),
        Text(
          'View and manage document counts',
          style: TextStyle(
            fontSize: 16,
            color: Colors.redAccent.shade700,
          ),
        ),
      ],
    );
  }

  ElevatedButton _buildCountButton(
      BuildContext context,
      String label,
      int count,
      IconData icon,
      Widget destination,
      ) {
    return ElevatedButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => destination),
        );
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.redAccent, // Red accent color for button
        padding: EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 5,
        shadowColor: Colors.redAccent.shade100,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 24, color: Colors.white),
          SizedBox(width: 10),
          Text(
            '$label: $count',
            style: TextStyle(fontSize: 20, color: Colors.white),
          ),
        ],
      ),
    );
  }
}
