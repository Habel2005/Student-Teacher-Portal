import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:new_project4/auth/auth_page.dart';
import 'package:new_project4/main.dart';
import 'package:new_project4/pages/Homepages/student/assignment.dart';
import 'package:new_project4/pages/Homepages/student/attendence.dart';
import 'package:new_project4/pages/Homepages/student/marks.dart';
import 'package:new_project4/pages/Homepages/student/profile.dart';
import 'package:new_project4/pages/Homepages/student/subjectplanner.dart';
import 'package:firebase_auth/firebase_auth.dart';

class StudentHome extends StatefulWidget {
  const StudentHome({super.key});

  @override
  _StudentHomeState createState() => _StudentHomeState();
}

class _StudentHomeState extends State<StudentHome> {
  String userName = 'Student Name';
  int _selectedIndex = 0;

  static final List<Widget> _pages = <Widget>[
    const StudentProfile(),
    const MyPerformancePage(),
    const StudentAttendance(),
    const AssignmentPage(),
    const StudentSubjectPlanner(),
  ];

  @override
  void initState() {
    super.initState();
    fetchUserName(); // Fetch user info on init
  }

  // Function to get the user's name from Firestore
  Future<void> fetchUserName() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      String name = await getUserName(user.uid);
      setState(() {
        userName = name; // Update the state with the fetched name
      });
    }
  }

  // Function to retrieve user name from Firestore
  Future<String> getUserName(String userId) async {
    DocumentSnapshot userDoc =
        await FirebaseFirestore.instance.collection('users').doc(userId).get();
    if (userDoc.exists) {
      return userDoc['name']; // Ensure your Firestore has a 'name' field
    }
    return 'User'; // Default name if not found
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void Logout() {
    final _auth = AuthService();
    authGateKey.currentState?.unsetauth();
    _auth.signOut();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
              icon: const Icon(Icons.menu_open_rounded,size: 33,color: Color.fromARGB(255, 245, 228, 255),), 
              onPressed: () {
                Scaffold.of(context).openDrawer(); 
              },
            );
          },
        ),
        title: const Text('Student Dashboard'),
        backgroundColor: const Color.fromARGB(255, 57, 45, 66),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Logout();
              setState(() {});
            },
            tooltip: 'Logout',
          ),
        ],
      ),
      drawer: Drawer(
        child: Column(
          children: [
            UserAccountsDrawerHeader(
              accountName: Padding(
                padding: const EdgeInsets.only(top: 32.0),
                child: Text(
                  userName,
                  style: const TextStyle(
                    fontSize: 18.0, // Adjust the size as needed
                    fontWeight: FontWeight.bold, // Make the name stand out
                    color: Colors.white,
                  ),
                ),
              ),
              accountEmail: Text(
                FirebaseAuth.instance.currentUser?.email ??
                    'student@example.com',
                style: const TextStyle(
                  fontSize: 14.0,
                  color:
                      Colors.white70, // Lighter shade to distinguish from name
                ),
              ),
              currentAccountPicture: CircleAvatar(
                radius: 35, // Adjust the size of the avatar for better balance
                backgroundColor: Colors.white,
                child: Text(
                  userName.substring(0, 1).toUpperCase(),
                  style: const TextStyle(
                    fontSize: 40.0,
                    fontWeight: FontWeight.bold, // Bold initial for emphasis
                    color: Color.fromARGB(255, 57, 45, 66), // Matches app theme
                  ),
                ),
              ),
              decoration: const BoxDecoration(
                color: Color.fromARGB(255, 57, 45, 66),
              ),
            ),
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  ListTile(
                    leading: const Icon(Icons.person),
                    title: const Text('Profile'),
                    onTap: () {
                      Navigator.of(context).pop();
                      _onItemTapped(0);
                    },
                  ),
                  const Divider(
                    thickness: 0.75,
                    color: Color.fromARGB(255, 61, 48, 71),
                  ),
                  ListTile(
                    leading: const Icon(Icons.bar_chart_rounded),
                    title: const Text('My Perfomance'),
                    onTap: () {
                      Navigator.of(context).pop();
                      _onItemTapped(1);
                    },
                  ),
                  const Divider(
                    thickness: 0.75,
                    color: Color.fromARGB(255, 61, 48, 71),
                  ),
                  ListTile(
                    leading: const Icon(Icons.calendar_today),
                    title: const Text('Attendance'),
                    onTap: () {
                      Navigator.of(context).pop();
                      _onItemTapped(2);
                    },
                  ),
                  const Divider(
                    thickness: 0.75,
                    color: Color.fromARGB(255, 61, 48, 71),
                  ),
                  ListTile(
                    leading: const Icon(Icons.assignment),
                    title: const Text('Assignments'),
                    onTap: () {
                      Navigator.of(context).pop();
                      _onItemTapped(3);
                    },
                  ),
                  const Divider(
                    thickness: 0.75,
                    color: Color.fromARGB(255, 61, 48, 71),
                  ),
                  ListTile(
                    leading: const Icon(Icons.book),
                    title: const Text('Subject Planner'),
                    onTap: () {
                      Navigator.of(context).pop();
                      _onItemTapped(4);
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: _pages.elementAt(_selectedIndex),
    );
  }
}
