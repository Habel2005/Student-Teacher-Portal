import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FacultySubjectPlanner extends StatefulWidget {
  @override
  _FacultySubjectPlannerState createState() => _FacultySubjectPlannerState();
}

class _FacultySubjectPlannerState extends State<FacultySubjectPlanner> {
  final _formKey = GlobalKey<FormState>();
  String selectedSemester = '1';
  List<String> semesters = ['1', '2', '3', '4', '5', '6', '7', '8'];
  TextEditingController _subjectController = TextEditingController();
  TextEditingController _teacherController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Faculty Subject Planner', style: TextStyle(color: Colors.white)),
      backgroundColor: const Color.fromARGB(255, 45, 28, 57),),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: DropdownButtonFormField<String>(
              value: selectedSemester,
              items: semesters.map((String semester) {
                return DropdownMenuItem<String>(
                  value: semester,
                  child: Text('Semester $semester'),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  selectedSemester = newValue!;
                });
              },
              decoration: const InputDecoration(labelText: 'Select Semester'),
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('subjects')
                  .where('semester', isEqualTo: selectedSemester)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('No subjects found for this semester'));
                }

                return ListView(
                  children: snapshot.data!.docs.map((doc) {
                    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
                    return ListTile(
                      title: Text(data['name'] ?? 'Unknown Subject'),
                      subtitle: Text('Teacher: ${data['teacher'] ?? 'Not assigned'}'),
                      trailing: IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () => _editSubject(context, doc.id, data),
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () => _addSubject(context),
      ),
    );
  }

  void _addSubject(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add Subject'),
          content: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _subjectController,
                  decoration: const InputDecoration(labelText: 'Subject Name'),
                  validator: (value) => value!.isEmpty ? 'Please enter a subject name' : null,
                ),
                const SizedBox(height: 10,),
                TextFormField(
                  controller: _teacherController,
                  decoration: const InputDecoration(labelText: 'Teacher Name'),
                  validator: (value) => value!.isEmpty ? 'Please enter a teacher name' : null,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text('Add'),
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  FirebaseFirestore.instance.collection('subjects').add({
                    'name': _subjectController.text,
                    'teacher': _teacherController.text,
                    'semester': selectedSemester,
                  });
                  Navigator.of(context).pop();
                  _subjectController.clear();
                  _teacherController.clear();
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _editSubject(BuildContext context, String docId, Map<String, dynamic> data) {
    _subjectController.text = data['name'] ?? '';
    _teacherController.text = data['teacher'] ?? '';
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Edit Subject'),
          content: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _subjectController,
                  decoration: const InputDecoration(labelText: 'Subject Name'),
                  validator: (value) => value!.isEmpty ? 'Please enter a subject name' : null,
                ),
                const SizedBox(height: 10,),
                TextFormField(
                  controller: _teacherController,
                  decoration: const InputDecoration(labelText: 'Teacher Name'),
                  validator: (value) => value!.isEmpty ? 'Please enter a teacher name' : null,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text('Update'),
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  FirebaseFirestore.instance.collection('subjects').doc(docId).update({
                    'name': _subjectController.text,
                    'teacher': _teacherController.text,
                  });
                  Navigator.of(context).pop();
                  _subjectController.clear();
                  _teacherController.clear();
                }
              },
            ),
            TextButton(
              child: const Text('Delete'),
              onPressed: () {
                FirebaseFirestore.instance.collection('subjects').doc(docId).delete();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}