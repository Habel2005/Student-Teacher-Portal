import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService extends ChangeNotifier {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance; //auth instance
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance; //firestore instance

  //sign in
  Future<UserCredential> signInWithEmailPassword(
      String email, String password) async {
    try {
      //sign in
      UserCredential userCredential = await _firebaseAuth
          .signInWithEmailAndPassword(email: email, password: password);

      //after sign in create a doc for user
      _firestore.collection('users').doc(userCredential.user!.uid).set({
        'uid': userCredential.user!.uid,
        'email': email,
      }, SetOptions(merge: true));

      return userCredential;
    }
    //error
    on FirebaseAuthException catch (e) {
      throw Exception(e.code);
    }
  }

  //sign out
  Future<void> signOut() async {
    return await FirebaseAuth.instance.signOut();
  }

  // Future<User?> signUpwithEmailandPassword(
  //     String email, String password, String role) async {
  //   try {
  //     UserCredential result =
  //         await _firebaseAuth.createUserWithEmailAndPassword(
  //       email: email,
  //       password: password,
  //     );
  //     User? user = result.user;

  //     if (user != null) {
  //       // Use 'set' to create the user document with all initial fields
  //       await _firestore.collection('users').doc(user.uid).set({
  //         'uid': user.uid,
  //         'email': email,
  //         'role': role,
  //         'name': '',
  //         'age': null,
  //         'department': '',
  //       });

  //       // If the role is not 'faculty', use 'update' to add currentSemester
  //       if (role != 'faculty') {
  //         await _firestore.collection('users').doc(user.uid).update({
  //           'currentSemester': '1',
  //         });
  //       }
  //     }

  //     return user;
  //   } catch (e) {
  //     print(e.toString());
  //     throw e;
  //   }
  // }

  Future<User?> signUpwithEmailandPassword(
      String email, String password, String role) async {
    try {
      // Check if the role is "faculty"
      if (role == 'faculty') {
        throw Exception('Registration as faculty is not allowed.');
      }

      UserCredential result =
          await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      User? user = result.user;

      if (user != null) {
        // Set user details in Firestore
        await _firestore.collection('users').doc(user.uid).set({
          'uid': user.uid,
          'email': email,
          'role': role,
          'name': '',
          'age': null,
          'department': '',
        });

        // If the role is not 'faculty', add 'currentSemester'
        if (role != 'faculty') {
          await _firestore.collection('users').doc(user.uid).update({
            'currentSemester': '1',
          });
        }
      }

      return user;
    } catch (e) {
      print(e.toString());
      throw e;
    }
  }

  Future<String?> getUserRole(String userId) async {
    try {
      DocumentSnapshot doc =
          await _firestore.collection('users').doc(userId).get();
      return doc.get('role') as String?;
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  Future<void> updateSemester() async {
    String uid = FirebaseAuth.instance.currentUser!.uid;

    // Fetch the document snapshot for the current user
    DocumentSnapshot userDoc =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();

    // Cast the document data to Map<String, dynamic>
    Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;

    // Fetch the current semester (assumes it already exists)
    int currentSemester = userData['currentSemester'];

    // Increment the semester value by 1
    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .update({'currentSemester': currentSemester + 1});
  }
}
