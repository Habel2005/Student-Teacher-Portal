import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:new_project4/pages/authpages/logorreg.dart';
import 'package:new_project4/pages/authpages/StartPage.dart';

class AuthGate extends StatefulWidget {
   AuthGate({super.key});

  @override
  AuthGateState createState() => AuthGateState();
}

class AuthGateState extends State<AuthGate> {
  bool _authorized = false;


  void setauth() {
    setState(() {
      _authorized = true;
      print("allowed: $_authorized");
    });
  }

  void unsetauth() {
    setState(() {
      _authorized = false;
      print("allowed: $_authorized");
    });
  }

@override
@override
  Widget build(BuildContext context) {
    print('AuthGate triggered');
    return Scaffold(
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.active) {
            if (snapshot.hasData && _authorized) {
              print("User authorized, navigating to Startpage");
              return const Startpage();
            } else {
              print("User signed in but not authorized, showing LogorReg");
              return const LogorReg();
            }
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }

}
