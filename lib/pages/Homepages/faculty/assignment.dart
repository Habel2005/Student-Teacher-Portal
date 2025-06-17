import 'package:flutter/material.dart';
import 'package:new_project4/auth/studentdata.dart';

class AssignmentPage extends StatefulWidget {
  @override
  _AssignmentPageState createState() => _AssignmentPageState();
}

class _AssignmentPageState extends State<AssignmentPage> {
  late Future<List<Assignment>> _assignmentsFuture;

  @override
  void initState() {
    super.initState();
    _assignmentsFuture = Assignment.fetchAssignments(); // Fetch assignments from Firestore
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Assignments'),
      ),
      body: FutureBuilder<List<Assignment>>(
        future: _assignmentsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator()); // Show loading indicator
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}')); // Handle errors
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No assignments found.')); // No data found
          } else {
            List<Assignment> assignments = snapshot.data!;
            return ListView.builder(
              itemCount: assignments.length,
              itemBuilder: (context, index) {
                Assignment assignment = assignments[index];

                return Card(
                  margin: const EdgeInsets.all(8.0),
                  elevation: 3,
                  child: ExpansionTile(
                    title: Text(
                      'Subject: ${assignment.subject ?? 'No Subject'}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text('Submitted by: ${assignment.studentName ?? 'Unknown'}'),
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Assignment Question: ${assignment.question ?? 'No Question'}'),
                            const SizedBox(height: 10),
                            Text('Answer: ${assignment.answer ?? 'No Answer'}'),
                            const SizedBox(height: 10),
                            Text('Due Date: ${assignment.dueDate ?? 'No Due Date'}'),
                            CheckboxListTile(
                              title: const Text('Submitted'),
                              value: assignment.submitted,
                              onChanged: (bool? newValue) {
                                setState(() {
                                  assignment.submitted = newValue!;
                                  assignment.updateAssignment(assignment.id ?? '', newValue);
                                });
                              },
                            ),
                            ElevatedButton(
                              onPressed: () => _showDeleteDialog(assignment.id ?? ''),
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                              child: const Text('Delete Assignment'),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }

  // Method to show a confirmation dialog before deleting an assignment
  void _showDeleteDialog(String id) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Assignment'),
          content: const Text('Are you sure you want to delete this assignment?'),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text('Delete'),
              onPressed: () {
                Assignment().deleteAssignment(id).then((_) {
                  setState(() {
                    _assignmentsFuture = Assignment.fetchAssignments(); // Refresh the list after deletion
                  });
                  Navigator.of(context).pop();
                });
              },
            ),
          ],
        );
      },
    );
  }
}
