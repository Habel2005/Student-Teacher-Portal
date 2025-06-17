import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Assignment {
  String? id;
  String? subject;
  String? question;
  String? dueDate;
  String? semester;   
  bool submitted; 
  String? answer;
  String? studentName;

  Assignment({
    this.id,
    this.subject,
    this.question,
    this.dueDate,
    this.semester,     
    this.submitted = false, 
    this.answer,
    this.studentName
  });

  factory Assignment.fromJson(Map<String, dynamic> json, String id) {
    return Assignment(
      id: id,
      subject: json['subject'],
      question: json['question'],
      dueDate: json['dueDate'],
      semester: json['semester'],  
      submitted: json['submitted'] ?? false, 
      answer: json['answer'], 
      studentName: json['studentName'],
    );
  }

  // Add fromFirestore method
  factory Assignment.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Assignment.fromJson(data, doc.id);
  }

  Future<void> addAssignment(String semester, String subject, String question, String answer) async {
    User? currentUser = FirebaseAuth.instance.currentUser;
    CollectionReference assignments = FirebaseFirestore.instance.collection('assignments');
    
    DocumentSnapshot userSnapshot = await FirebaseFirestore.instance.collection('users').doc(currentUser!.uid).get();
    String studentName = userSnapshot['name']; 

    await assignments.add({
      'userId': currentUser.uid,
      'studentName': studentName,  
      'semester': semester,
      'subject': subject,
      'question': question,
      'answer': answer,
      'timestamp': FieldValue.serverTimestamp(),
      'submitted': false, 
    });
  }

  Future<void> updateAssignment(String id, bool submitted) async {
    await FirebaseFirestore.instance.collection('assignments').doc(id).update({
      'submitted': submitted,
    });
  }

  Future<void> deleteAssignment(String id) async {
    await FirebaseFirestore.instance.collection('assignments').doc(id).delete();
  }

  static Future<List<Assignment>> fetchAssignments() async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection('assignments').get();
    return querySnapshot.docs.map((doc) => Assignment.fromFirestore(doc)).toList();
  }
}