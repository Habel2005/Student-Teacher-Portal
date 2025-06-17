import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class FacultyAttendancePortal extends StatefulWidget {
  const FacultyAttendancePortal({super.key});

  @override
  _FacultyAttendancePortalState createState() =>
      _FacultyAttendancePortalState();
}

class _FacultyAttendancePortalState extends State<FacultyAttendancePortal> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String? selectedSubject;
  List<Map<String, dynamic>> students = [];
  bool isLoading = false;
  DateTime selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _loadSubjects();
  }

  Future<void> _loadSubjects() async {
    final subjectsSnapshot = await _firestore.collection('subjects').get();
    if (subjectsSnapshot.docs.isNotEmpty) {
      setState(() {
        selectedSubject = subjectsSnapshot.docs.first.id;
        _loadStudentsForSubject(selectedSubject!);
      });
    }
  }

  Future<void> _loadStudentsForSubject(String subjectId) async {
    setState(() {
      isLoading = true;
    });

    final studentsSnapshot = await _firestore
        .collection('users')
        .where('role', isEqualTo: 'student')
        .get();

    final attendanceSnapshot = await _firestore
        .collection('attendance')
        .where('subjectId', isEqualTo: subjectId)
        .where('date', isEqualTo: DateFormat('yyyy-MM-dd').format(selectedDate))
        .get();

    Map<String, bool> attendanceMap = {};
    for (var doc in attendanceSnapshot.docs) {
      attendanceMap[doc['userId']] = doc['present'];
    }

    setState(() {
      students = studentsSnapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          'name': data['name'] ?? 'Unknown',
          'rollNo': data['rollNo'] ?? 'N/A',
          'present': attendanceMap[doc.id] ?? false,
        };
      }).toList();
      isLoading = false;
    });
  }

  Future<void> _saveAttendance() async {
    setState(() {
      isLoading = true;
    });

    final batch = _firestore.batch();
    final date = DateFormat('yyyy-MM-dd').format(selectedDate);

    for (var student in students) {
      final attendanceRef = _firestore.collection('attendance').doc();
      batch.set(attendanceRef, {
        'userId': student['id'],
        'subjectId': selectedSubject,
        'date': date,
        'present': student['present'],
      });
    }

    await batch.commit();

    setState(() {
      isLoading = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Attendance saved successfully')),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
        _loadStudentsForSubject(selectedSubject!);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Faculty Attendance Portal')),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      StreamBuilder<QuerySnapshot>(
                        stream: _firestore.collection('subjects').snapshots(),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData)
                            return const CircularProgressIndicator();

                          return DropdownButton<String>(
                            value: selectedSubject,
                            items: snapshot.data!.docs.map((doc) {
                              return DropdownMenuItem<String>(
                                value: doc.id,
                                child: Text(doc['name']),
                              );
                            }).toList(),
                            onChanged: (String? newValue) {
                              setState(() {
                                selectedSubject = newValue;
                                _loadStudentsForSubject(newValue!);
                              });
                            },
                          );
                        },
                      ),
                      TextButton(
                        style: ButtonStyle(
                          side: WidgetStateProperty.all(
                            const BorderSide(
                                color: Colors.white,
                                width: 1), 
                          ),
                        ),
                        onPressed: () => _selectDate(context),
                        child:
                            Text(DateFormat('yyyy-MM-dd').format(selectedDate)),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: students.length,
                    itemBuilder: (context, index) {
                      final student = students[index];
                      return CheckboxListTile(
                        title: Text(student['name']),
                        subtitle: Text('Roll No: ${student['rollNo']}'),
                        value: student['present'],
                        onChanged: (bool? value) {
                          setState(() {
                            students[index]['present'] = value;
                          });
                        },
                      );
                    },
                  ),
                ),
                ElevatedButton(
                  onPressed: _saveAttendance,
                  child: const Text('Save Attendance'),
                ),
              ],
            ),
    );
  }
}
