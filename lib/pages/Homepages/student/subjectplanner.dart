import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class StudentSubjectPlanner extends StatelessWidget {
  const StudentSubjectPlanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Subject Planner'),
      backgroundColor: const Color.fromARGB(255, 55, 33, 72),),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .snapshots(),
        builder: (context, userSnapshot) {
          if (userSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (userSnapshot.hasError || !userSnapshot.hasData) {
            return const Center(child: Text('Error loading user data'));
          }

          String currentSemester = userSnapshot.data!['currentSemester'] ?? '1';

          return StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('subjects')
                .where('semester', isEqualTo: currentSemester)
                .snapshots(),
            builder: (context, subjectSnapshot) {
              if (subjectSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (subjectSnapshot.hasError) {
                return Center(child: Text('Error: ${subjectSnapshot.error}'));
              }

              if (!subjectSnapshot.hasData || subjectSnapshot.data!.docs.isEmpty) {
                return const Center(child: Text('No subjects found for this semester'));
              }

              return ListView(
                children: subjectSnapshot.data!.docs.map((doc) {
                  Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
                  return ListTile(
                    title: Text(data['name'] ?? 'Unknown Subject'),
                    subtitle: Text('Teacher: ${data['teacher'] ?? 'Not assigned'}'),
                  );
                }).toList(),
              );
            },
          );
        },
      ),
    );
  }
}