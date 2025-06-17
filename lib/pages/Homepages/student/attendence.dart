import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class StudentAttendance extends StatelessWidget {
  const StudentAttendance({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'My Attendance',
        ),
        backgroundColor: const Color.fromARGB(255, 55, 33, 72),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('attendance')
            .where('userId', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No attendance data found'));
          }

          Map<String, List<AttendanceRecord>> subjectAttendance = {};
          for (var doc in snapshot.data!.docs) {
            var data = doc.data() as Map<String, dynamic>;
            String subjectId = data['subjectId'];
            bool present = data['present'];
            DateTime date = parseDate(data['date']);
            if (!subjectAttendance.containsKey(subjectId)) {
              subjectAttendance[subjectId] = [];
            }
            subjectAttendance[subjectId]!.add(AttendanceRecord(date, present));
          }

          return FutureBuilder<QuerySnapshot>(
            future: FirebaseFirestore.instance.collection('subjects').get(),
            builder: (context, subjectsSnapshot) {
              if (subjectsSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (subjectsSnapshot.hasError || !subjectsSnapshot.hasData) {
                return const Center(child: Text('Error loading subjects'));
              }

              Map<String, String> subjectNames = {};
              for (var doc in subjectsSnapshot.data!.docs) {
                subjectNames[doc.id] = doc['name'];
              }

              return ListView.builder(
                itemCount: subjectAttendance.length,
                itemBuilder: (context, index) {
                  String subjectId = subjectAttendance.keys.elementAt(index);
                  List<AttendanceRecord> attendance = subjectAttendance[subjectId]!;
                  int presentCount = attendance.where((a) => a.present).length;
                  double percentage = (presentCount / attendance.length) * 100;

                  return AttendanceTile(
                    subject: subjectNames[subjectId] ?? 'Unknown Subject',
                    attendancePercentage: percentage.round(),
                    totalClasses: attendance.length,
                    attendedClasses: presentCount,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DetailedAttendanceView(
                            subject: subjectNames[subjectId] ?? 'Unknown Subject',
                            attendanceRecords: attendance,
                          ),
                        ),
                      );
                    },
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  DateTime parseDate(dynamic date) {
    if (date is Timestamp) {
      return date.toDate();
    } else if (date is String) {
      return DateTime.parse(date);
    } else {
      // Default to current date if parsing fails
      print('Warning: Unable to parse date. Using current date.');
      return DateTime.now();
    }
  }
}

class AttendanceTile extends StatelessWidget {
  final String subject;
  final int attendancePercentage;
  final int totalClasses;
  final int attendedClasses;
  final VoidCallback onTap;

  const AttendanceTile({
    super.key,
    required this.subject,
    required this.attendancePercentage,
    required this.totalClasses,
    required this.attendedClasses,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(subject),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Attendance: $attendancePercentage%'),
          Text('Classes: $attendedClasses / $totalClasses'),
        ],
      ),
      trailing: CircularProgressIndicator(
        value: attendancePercentage / 100,
        backgroundColor: Colors.grey[200],
        valueColor: AlwaysStoppedAnimation(
          attendancePercentage >= 75 ? Colors.green : Colors.red,
        ),
      ),
      onTap: onTap,
    );
  }
}

class DetailedAttendanceView extends StatelessWidget {
  final String subject;
  final List<AttendanceRecord> attendanceRecords;

  const DetailedAttendanceView({
    super.key,
    required this.subject,
    required this.attendanceRecords,
  });

  @override
  Widget build(BuildContext context) {
    attendanceRecords.sort((a, b) => b.date.compareTo(a.date));

    return Scaffold(
      appBar: AppBar(
        title: Text('$subject - Attendance'),
        backgroundColor: const Color.fromARGB(255, 55, 33, 72),
      ),
      body: ListView.builder(
        itemCount: attendanceRecords.length,
        itemBuilder: (context, index) {
          final record = attendanceRecords[index];
          return ListTile(
            title: Text(DateFormat('yyyy-MM-dd').format(record.date)),
            trailing: Icon(
              record.present ? Icons.check_circle : Icons.cancel,
              color: record.present ? Colors.green : Colors.red,
            ),
          );
        },
      ),
    );
  }
}

class AttendanceRecord {
  final DateTime date;
  final bool present;

  AttendanceRecord(this.date, this.present);
}