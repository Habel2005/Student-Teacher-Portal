import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class StudentProfile extends StatelessWidget {
  const StudentProfile({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 55, 33, 72),
        title: const Text(
          'Student Profile',
          style: TextStyle(
            color: Color.fromARGB(255, 159, 127, 183),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('Profile data not found'));
          }

          Map<String, dynamic> userData =
              snapshot.data!.data() as Map<String, dynamic>;

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Profile Picture
                  const CircleAvatar(
                    radius: 50,
                    backgroundImage: NetworkImage(
                          'https://static.vecteezy.com/system/resources/thumbnails/005/544/718/small_2x/profile-icon-design-free-vector.jpg',
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Name
                  Text(
                    userData['name'] ?? 'N/A',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(255, 191, 153, 224),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    userData['department'] ?? 'Department',
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Cards for Profile Details
                  _buildProfileDetailCard(
                    Icons.account_circle,
                    'Roll Number',
                    userData['rollNo'] ?? 'N/A',
                  ),
                  _buildProfileDetailCard(
                    Icons.school,
                    'Semester',
                    userData['currentSemester'] ?? 'N/A',
                  ),
                  _buildProfileDetailCard(
                    Icons.cake,
                    'Age',
                    userData['age'] != null
                        ? userData['age'].toString()
                        : 'N/A',
                  ),
                  _buildProfileDetailCard(
                    Icons.email,
                    'Email',
                    userData['email'] ?? 'N/A',
                  ),
                  _buildProfileDetailCard(
                    Icons.perm_identity,
                    'Admission No',
                    userData['admissionNo'] ?? 'N/A',
                  ),

                  // Action Buttons (Log out button, etc.)
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () {
                      FirebaseAuth.instance.signOut();
                    },
                    icon: const Icon(
                      Icons.logout,
                      color: Colors.white,
                    ),
                    label: const Text("Log Out"),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: const Color.fromARGB(255, 255, 255, 255),
                      padding: const EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // Helper method to build cards for profile details
  Widget _buildProfileDetailCard(IconData icon, String label, String value) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(icon, color: const Color.fromARGB(255, 162, 139, 179)),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: const TextStyle(
                      color: Color.fromARGB(255, 154, 139, 165),
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
