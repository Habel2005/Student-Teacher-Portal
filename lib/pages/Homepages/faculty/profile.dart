import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  Future<Map<String, dynamic>> getUserProfile() async {
    User? currentUser = FirebaseAuth.instance.currentUser;
    DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser!.uid)
        .get();

    return userSnapshot.data() as Map<String, dynamic>;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Profile',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color.fromARGB(255, 45, 28, 57), // AppBar color
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: getUserProfile(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No profile found.'));
          } else {
            Map<String, dynamic> userData = snapshot.data!;

            return SingleChildScrollView(
              child: Center(
                child: Column(
                  children: [
                    // Profile Picture Section
                    const SizedBox(height: 30),
                    const CircleAvatar(
                      radius: 60,
                      backgroundImage: NetworkImage(
                 'https://static.vecteezy.com/system/resources/thumbnails/005/544/718/small_2x/profile-icon-design-free-vector.jpg',
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Card with Profile Information
                    Card(
                      elevation: 8,
                      margin: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            const Center(
                              child: Text(
                                'Faculty Profile',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Color.fromARGB(255, 128, 90, 157),
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            const Divider(),
                            const SizedBox(height: 10),

                            // Profile Details with Icons
                            _buildProfileDetail(Icons.person, 'Name', userData['name']),
                            _buildProfileDetail(Icons.cake, 'Age', userData['age'].toString()),
                            _buildProfileDetail(
                                Icons.badge, 'Faculty No', userData['facultyNo']),
                            _buildProfileDetail(Icons.email, 'Email', userData['email']),
                            _buildProfileDetail(
                                Icons.school, 'Department', userData['department']),

                            const SizedBox(height: 20),
                          ],
                        ),
                      ),
                    ),

                    // Log Out Button
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: ElevatedButton.icon(
                        onPressed: () {
                          FirebaseAuth.instance.signOut();
                          
                        },
                        icon: const Icon(Icons.logout,color: Colors.white,),
                        label: const Text("Log Out"),
                        style: ElevatedButton.styleFrom(
                          foregroundColor: const Color.fromARGB(255, 190, 133, 233), // Button color
                          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }
        },
      ),
    );
  }

  // Helper method to build profile details with icons
  Widget _buildProfileDetail(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: const Color.fromARGB(255, 128, 90, 157)),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              '$label: $value',
              style: const TextStyle(fontSize: 18, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
