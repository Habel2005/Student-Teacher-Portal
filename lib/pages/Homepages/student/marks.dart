import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MyPerformancePage extends StatefulWidget {
  const MyPerformancePage({super.key});

  @override
  _MyPerformancePageState createState() => _MyPerformancePageState();
}

class _MyPerformancePageState extends State<MyPerformancePage> {
  String? currentSemester;
  bool _isLoading = true;
  List<Map<String, dynamic>> _performanceData = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await _loadCurrentSemester();
      await _fetchPerformance();
    } catch (e) {
      print('Error loading data: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Error loading performance data. Please try again.')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadCurrentSemester() async {
    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get();

    currentSemester = userDoc.data()?['currentSemester'] ?? '1';
  }

  Future<void> _fetchPerformance() async {
    final userId = FirebaseAuth.instance.currentUser!.uid;

    // Fetch marks
    final marksSnapshot = await FirebaseFirestore.instance
        .collection('marks')
        .where('studentId', isEqualTo: userId)
        .where('semester', isEqualTo: currentSemester)
        .get();

    // Fetch subjects for the current semester
    final subjectsSnapshot = await FirebaseFirestore.instance
        .collection('subjects')
        .where('semester', isEqualTo: currentSemester)
        .get();

    // Create a map of subject IDs to subject names
    final subjectMap = Map.fromEntries(subjectsSnapshot.docs
        .map((doc) => MapEntry(doc.id, doc.data()['name'] as String)));

    // Aggregate marks by subject
    final performanceMap = <String, Map<String, dynamic>>{};
    for (var doc in marksSnapshot.docs) {
      final data = doc.data();
      final subjectId = data['subjectId'] as String;
      final subjectName = subjectMap[subjectId] ?? 'Unknown Subject';

      if (!performanceMap.containsKey(subjectId)) {
        performanceMap[subjectId] = {
          'subjectName': subjectName,
          'totalMarks': 0,
          'maxMarks': 0,
          'assignmentCount': 0,
        };
      }

      performanceMap[subjectId]!['totalMarks'] += data['marks'] as num;
      performanceMap[subjectId]!['maxMarks'] += data['maxMarks'] as num;
      performanceMap[subjectId]!['assignmentCount']++;
    }

    setState(() {
      _performanceData = performanceMap.values.toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Performance'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _performanceData.isEmpty
              ? const Center(child: Text('No performance data available.'))
              : RefreshIndicator(
                  onRefresh: _loadData,
                  child: ListView.builder(
                    itemCount: _performanceData.length,
                    itemBuilder: (context, index) {
                      final performance = _performanceData[index];
                      final percentage = (performance['totalMarks'] /
                              performance['maxMarks'] *
                              100)
                          .toStringAsFixed(2);

                      return Card(
                        margin: const EdgeInsets.all(8.0),
                        child: ListTile(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                          tileColor: const Color.fromARGB(255, 52, 34, 66),
                          title: Text(performance['subjectName']),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                  'Total Marks: ${performance['totalMarks']} / ${performance['maxMarks']}'),
                              Text('Percentage: $percentage%'),
                              Text(
                                  'Assignments: ${performance['assignmentCount']}'),
                            ],
                          ),
                          trailing: Tooltip(
                            message: _getPerformanceMessage(percentage),
                            child: CircularProgressIndicator(
                              value: double.tryParse(percentage),
                              backgroundColor: Colors.grey[200],
                              valueColor: AlwaysStoppedAnimation(
                                double.tryParse(percentage)! >= 25
                                    ? Colors.green
                                    : Colors.red,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}

String _getPerformanceMessage(String percentage) {
  double percentValue = double.tryParse(percentage) ?? 0.0;
  if (percentValue >= 90) {
    return 'Excellent performance!';
  } else if (percentValue >= 75) {
    return 'Good job, keep going!';
  } else if (percentValue >= 50) {
    return 'Fair, but can do better!';
  } else if (percentValue >= 25) {
    return 'Needs improvement, try harder!';
  } else {
    return 'Very poor, try better next time!';
  }
}
