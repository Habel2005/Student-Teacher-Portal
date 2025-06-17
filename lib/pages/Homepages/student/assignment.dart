import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:new_project4/auth/studentdata.dart';

class AssignmentPage extends StatefulWidget {
  const AssignmentPage({super.key});

  @override
  _AssignmentPageState createState() => _AssignmentPageState();
}

class _AssignmentPageState extends State<AssignmentPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late Future<List<Assignment>> _assignmentsFuture;

  final _formKey = GlobalKey<FormState>();
  String? selectedSemester;
  String? selectedSubject;
  final questionController = TextEditingController();
  final answerController = TextEditingController();

  List<String> subjects = [];
  List<String> semesters = ['1', '2', '3', '4', '5', '6', '7', '8'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _assignmentsFuture = _fetchStudentAssignments();
    _loadCurrentSemester();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<List<Assignment>> _fetchStudentAssignments() async {
    final userId = FirebaseAuth.instance.currentUser!.uid;
    final assignmentsSnapshot = await FirebaseFirestore.instance
        .collection('assignments')
        .where('userId', isEqualTo: userId)
        .get();

    return assignmentsSnapshot.docs
        .map((doc) => Assignment.fromFirestore(doc))
        .toList();
  }

  Future<void> _loadCurrentSemester() async {
    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get();
    
    setState(() {
      selectedSemester = userDoc.data()?['currentSemester'] ?? '1';
      _loadSubjectsForSemester(selectedSemester!);
    });
  }

  Future<void> _loadSubjectsForSemester(String semester) async {
    final subjectsSnapshot = await FirebaseFirestore.instance
        .collection('subjects')
        .where('semester', isEqualTo: semester)
        .get();

    setState(() {
      subjects = subjectsSnapshot.docs
          .map((doc) => doc.data()['name'] as String)
          .toList();
      selectedSubject = null;
    });
  }

  Future<void> saveAssignment() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      try {
        Assignment assignment = Assignment();
        await assignment.addAssignment(
          selectedSemester!,
          selectedSubject!,
          questionController.text,
          answerController.text,
        );

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Assignment saved successfully')),
        );

        questionController.clear();
        answerController.clear();
        setState(() {
          selectedSubject = null;
          _assignmentsFuture = _fetchStudentAssignments();
        });
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving assignment: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Assignments'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Submit Assignment'),
            Tab(text: 'My Assignments'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildSubmissionForm(),
          _buildAssignmentsList(),
        ],
      ),
    );
  }

  Widget _buildSubmissionForm() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
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
                    _loadSubjectsForSemester(newValue!);
                  });
                },
                validator: (value) => value == null ? 'Please select a semester' : null,
              ),
              const SizedBox(height: 10),
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
                },
                validator: (value) => value == null ? 'Please select a subject' : null,
              ),
              const SizedBox(height: 10),
              TextField(
                controller: questionController,
                decoration: const InputDecoration(labelText: 'Assignment Question'),
                maxLines: 3,
              ),
              const SizedBox(height: 20),
              TextField(
                controller: answerController,
                decoration: const InputDecoration(labelText: 'Assignment Answer'),
                maxLines: 5,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: saveAssignment,
                child: const Text('Submit Assignment'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAssignmentsList() {
    return FutureBuilder<List<Assignment>>(
      future: _assignmentsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No assignments found.'));
        } else {
          List<Assignment> assignments = snapshot.data!;
          return ListView.builder(
            itemCount: assignments.length,
            itemBuilder: (context, index) {
              Assignment assignment = assignments[index];
              return Card(
                margin: const EdgeInsets.all(8.0),
                child: ListTile(
                  title: Text('Subject: ${assignment.subject ?? 'No Subject'}'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Question: ${assignment.question ?? 'No Question'}'),
                      Text('Status: ${assignment.submitted ? 'Submitted' : 'Pending'}'),
                    ],
                  ),
                  onTap: () {
                    _showAssignmentDetails(assignment);
                  },
                ),
              );
            },
          );
        }
      },
    );
  }

  void _showAssignmentDetails(Assignment assignment) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Assignment Details'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Subject: ${assignment.subject ?? 'No Subject'}'),
                const SizedBox(height: 10),
                Text('Question: ${assignment.question ?? 'No Question'}'),
                const SizedBox(height: 10),
                Text('Answer: ${assignment.answer ?? 'No Answer'}'),
                const SizedBox(height: 10),
                Text('Status: ${assignment.submitted ? 'Submitted' : 'Pending'}'),
                const SizedBox(height: 10),
                Text('Due Date: ${assignment.dueDate ?? 'No Due Date'}'),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: const Text('Close'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }
}