import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FacultyMarkEntryPage extends StatefulWidget {
  const FacultyMarkEntryPage({super.key});

  @override
  _FacultyMarkEntryPageState createState() => _FacultyMarkEntryPageState();
}

class _FacultyMarkEntryPageState extends State<FacultyMarkEntryPage> {
  String? selectedSemester;
  String? selectedSubject;
  List<String> semesters = ['1', '2', '3', '4', '5', '6', '7', '8'];
  List<String> subjects = [];
  List<Map<String, dynamic>> students = [];

  @override
  void initState() {
    super.initState();
    _loadSubjects();
  }

  Future<void> _loadSubjects() async {
    if (selectedSemester == null) return;

    final subjectsSnapshot = await FirebaseFirestore.instance
        .collection('subjects')
        .where('semester', isEqualTo: selectedSemester)
        .get();

    setState(() {
      subjects = subjectsSnapshot.docs
          .map((doc) => doc.data()['name'] as String)
          .toList();
      selectedSubject = null;
    });
  }

  Future<void> _loadStudents() async {
    if (selectedSemester == null || selectedSubject == null) return;

    final usersSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('role', isEqualTo: 'student')
        .where('currentSemester', isEqualTo: selectedSemester)
        .get();

    final subjectDoc = await FirebaseFirestore.instance
        .collection('subjects')
        .where('name', isEqualTo: selectedSubject)
        .where('semester', isEqualTo: selectedSemester)
        .get();

    if (subjectDoc.docs.isEmpty) return;

    setState(() {
      students = usersSnapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          'name': data['name'],
          'marks': TextEditingController(),
          'maxMarks': TextEditingController(text: '100'), // Default max marks
        };
      }).toList();
    });
  }

  Future<void> _submitMarks() async {
  if (selectedSemester == null || selectedSubject == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Please select both semester and subject.')),
    );
    return;
  }

  bool hasError = false;
  final batch = FirebaseFirestore.instance.batch();

  final subjectDoc = await FirebaseFirestore.instance
      .collection('subjects')
      .where('name', isEqualTo: selectedSubject)
      .where('semester', isEqualTo: selectedSemester)
      .get();

  if (subjectDoc.docs.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Subject not found.')),
    );
    return;
  }

  final subjectId = subjectDoc.docs.first.id;

  for (var student in students) {
    final marks = double.tryParse(student['marks'].text);
    final maxMarks = double.tryParse(student['maxMarks'].text);

    if (marks == null || maxMarks == null) {
      // If marks or maxMarks are invalid (empty or non-numeric), show error
      hasError = true;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please enter valid marks for ${student['name']}.'),
        ),
      );
      break;
    }

    final markRef = FirebaseFirestore.instance.collection('marks').doc();
    batch.set(markRef, {
      'studentId': student['id'],
      'subjectId': subjectId,
      'semester': selectedSemester,
      'marks': marks,
      'maxMarks': maxMarks,
      'date': FieldValue.serverTimestamp(),
    });
  }

  if (!hasError) {
    await batch.commit();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Marks submitted successfully')),
    );

    // Clear the form
    setState(() {
      students.clear();
      selectedSubject = null;
    });
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Enter Student Marks'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            DropdownButtonFormField<String>(
              value: selectedSemester,
              decoration: const InputDecoration(labelText: 'Select Semester'),
              items: semesters.map((String semester) {
                return DropdownMenuItem<String>(
                  value: semester,
                  child: Text(semester),
                );
              }).toList(),
              onChanged: (newValue) {
                setState(() {
                  selectedSemester = newValue;
                  selectedSubject = null;
                  students.clear();
                });
                _loadSubjects();
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: selectedSubject,
              decoration: const InputDecoration(labelText: 'Select Subject'),
              items: subjects.map((String subject) {
                return DropdownMenuItem<String>(
                  value: subject,
                  child: Text(subject),
                );
              }).toList(),
              onChanged: (newValue) {
                setState(() {
                  selectedSubject = newValue;
                });
                _loadStudents();
              },
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: students.length,
                itemBuilder: (context, index) {
                  final student = students[index];
                  return ListTile(
                    title: Text(student['name']),
                    subtitle: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: student['marks'],
                            decoration: const InputDecoration(labelText: 'Marks'),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextField(
                            controller: student['maxMarks'],
                            decoration: const InputDecoration(labelText: 'Max Marks'),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            ElevatedButton(
              onPressed: _submitMarks,
              child: const Text('Submit Marks'),
            ),
          ],
        ),
      ),
    );
  }
}