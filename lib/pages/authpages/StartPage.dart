import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:new_project4/auth/auth_page.dart';
import 'package:new_project4/pages/Roles/faculty.dart';
import 'package:new_project4/pages/Roles/student.dart';
import 'package:new_project4/pages/authpages/logorreg.dart';

class Startpage extends StatelessWidget {
  const Startpage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const LogorReg(); // Redirect to login if not authenticated
    }

    return FutureBuilder<String?>(
      future: AuthService().getUserRole(user.uid), // Fetch user role
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator()); // Show loading indicator
        } else if (snapshot.hasError) {
          return const Center(child: Text('Error fetching user role'));
        } else if (snapshot.hasData) {
          final role = snapshot.data;
          if (role == 'student') {
            print('Going to student home');
            return  const StudentHome(); // Navigate to StudentHome
          } else {
            print('Going to faculty home');
            return  const FacultyHome(); // Navigate to FacultyHome
          }
        } else {
          return const Center(child: Text('No role found')); // Handle unexpected case
        }
      },
    );
  }
}
