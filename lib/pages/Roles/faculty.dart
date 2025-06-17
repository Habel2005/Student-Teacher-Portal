import 'package:flutter/material.dart';
import 'package:new_project4/auth/auth_page.dart';
import 'package:new_project4/main.dart';
import 'package:new_project4/pages/Homepages/faculty/Assignment.dart';
import 'package:new_project4/pages/Homepages/faculty/attendence.dart';
import 'package:new_project4/pages/Homepages/faculty/marks.dart';
import 'package:new_project4/pages/Homepages/faculty/profile.dart';
import 'package:new_project4/pages/Homepages/faculty/subjectplanner.dart';

class FacultyHome extends StatefulWidget {
  const FacultyHome({super.key});

  @override
  _FacultyHome createState() => _FacultyHome();
}

class _FacultyHome extends State<FacultyHome> {
  int _selectedIndex = 0;
  void Logout() {
    final _auth = AuthService();
    authGateKey.currentState?.unsetauth();
    _auth.signOut();
  }

  static final List<Widget> _pages = <Widget>[
    ProfilePage(),
    FacultyMarkEntryPage(),
    FacultyAttendancePortal(),
    AssignmentPage(),
    FacultySubjectPlanner(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      appBar: AppBar(
        title: const Text('Student Management'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () {
              Logout();
              setState(() {});
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Color.fromARGB(255, 101, 76, 120),
              ),
              child: Text(
                'Faculty Portal',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.person),
              title: const Text('Profile'),
              onTap: () {
                Navigator.of(context).pop();
                _onItemTapped(0);
              },
            ),
            ListTile(
              leading: Icon(Icons.edit_attributes_rounded),
              title: const Text('Mark Upload'),
              onTap: () {
                Navigator.of(context).pop();
                _onItemTapped(1);
              },
            ),
            ListTile(
              leading: Icon(Icons.calendar_today),
              title: const Text('Attendance Portal'),
              onTap: () {
                Navigator.of(context).pop();
                _onItemTapped(2);
              },
            ),
            ListTile(
              leading: Icon(Icons.assignment),
              title: const Text('Assignment Portal'),
              onTap: () {
                Navigator.of(context).pop();
                _onItemTapped(3);
              },
            ),
            ListTile(
              leading: Icon(Icons.book),
              title: const Text('Subject Planner'),
              onTap: () {
                Navigator.of(context).pop();
                _onItemTapped(4);
              },
            ),
          ],
        ),
      ),
      body: _pages.elementAt(_selectedIndex),
    );
  }
}
