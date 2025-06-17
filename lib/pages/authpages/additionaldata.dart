import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:new_project4/pages/authpages/StartPage.dart';

class AdditionalInfoPage extends StatefulWidget {
  final String userType;

  const AdditionalInfoPage({super.key, required this.userType});

  @override
  _AdditionalInfoPageState createState() => _AdditionalInfoPageState();
}

class _AdditionalInfoPageState extends State<AdditionalInfoPage> {
  final _formKey = GlobalKey<FormState>();

  // Controllers for each field
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _rollNoController = TextEditingController();
  final TextEditingController _admissionNoController = TextEditingController();
  final TextEditingController _facultyNoController = TextEditingController();
  final TextEditingController _departmentController = TextEditingController();

  Future<void> _submitAdditionalInfo() async {
    if (_formKey.currentState!.validate()) {
      try {
        User? user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          // Update Firestore with the new fields
          await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
            'name': _nameController.text,
            'age': int.parse(_ageController.text),
            'department': _departmentController.text,   // Store Department
          });

          // Add rollNo or facultyNo based on user type
          if (widget.userType == 'student') {
            await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
              'rollNo': _rollNoController.text,          // Store Roll No
              'admissionNo': _admissionNoController.text, // Store Admission No
            });
          } else if (widget.userType == 'faculty') {
            await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
              'facultyNo': _facultyNoController.text,    // Store Faculty No
            });
          }

          // Navigate to StartPage after successful update
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const Startpage()),
          );
        }
      } catch (e) {
        // Display error message if something goes wrong
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating information: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'User Information',
          style: TextStyle(color: Color.fromARGB(255, 214, 189, 255)),
        ),
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Name'),
                validator: (value) => value!.isEmpty ? 'Please enter your name' : null,
              ),
              const SizedBox(height: 5),
              TextFormField(
                controller: _ageController,
                decoration: const InputDecoration(labelText: 'Age'),
                keyboardType: TextInputType.number,
                validator: (value) => value!.isEmpty ? 'Please enter your age' : null,
              ),
              const SizedBox(height: 5),
              if (widget.userType == 'student') ...[
                TextFormField(
                  controller: _rollNoController,
                  decoration: const InputDecoration(labelText: 'Roll No'),
                  keyboardType: TextInputType.number,
                  validator: (value) => value!.isEmpty ? 'Please enter your roll no' : null,
                ),
                const SizedBox(height: 5),
                TextFormField(
                  controller: _admissionNoController,
                  decoration: const InputDecoration(labelText: 'Admission No'),
                  validator: (value) => value!.isEmpty ? 'Please enter your admission no' : null,
                ),
              ] else if (widget.userType == 'faculty') ...[
                TextFormField(
                  controller: _facultyNoController,
                  decoration: const InputDecoration(labelText: 'Faculty No'),
                  validator: (value) => value!.isEmpty ? 'Please enter your faculty no' : null,
                ),
              ],
              const SizedBox(height: 5),
              TextFormField(
                controller: _departmentController,
                decoration: const InputDecoration(labelText: 'Department'),
                validator: (value) => value!.isEmpty ? 'Please enter your department' : null,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitAdditionalInfo,
                child: const Text('Submit'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
