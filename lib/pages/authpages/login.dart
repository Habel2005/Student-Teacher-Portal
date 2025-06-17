import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:new_project4/auth/auth_page.dart';
import 'package:new_project4/main.dart';

class LoginPage extends StatefulWidget {
  final void Function()? onTap;
  const LoginPage({super.key, required this.onTap});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  String _userType = 'student';
  final TextEditingController emailcontrol = TextEditingController();
  final TextEditingController passcontrol = TextEditingController();
  bool _isObscure1 = true;

  //sign in'
  void signIn() async {
    if (emailcontrol.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text(
          "Email can't be empty",
        ),
      ));
      return;
    } else if (passcontrol.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text(
          "Password can't be empty",
        ),
      ));
      return;
    }

// Show loading spinner
    showDialog(
      context: context,
      barrierDismissible: false, // Prevent the dialog from being dismissed
      builder: (context) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );

    Future<String?> getUserRole(String email) async {
      try {
        CollectionReference users =
            FirebaseFirestore.instance.collection('users');
        QuerySnapshot querySnapshot =
            await users.where('email', isEqualTo: email).get();

        if (querySnapshot.docs.isNotEmpty) {
          var userData =
              querySnapshot.docs.first.data() as Map<String, dynamic>;
          return userData['role'] as String?;
        } else {
          print('User not found');
          return null;
        }
      } catch (e) {
        print('Error retrieving user role: $e');
        return null;
      }
    }

    final authService = AuthService();

    try {
      await authService.signInWithEmailPassword(
          emailcontrol.text, passcontrol.text);
      print("User signed in successfully");

      String? userRole = await getUserRole(emailcontrol.text);
      print("Fetched user role: $userRole");

      if (userRole != _userType) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Incorrect user type selected.'),
          ));
        }
        authGateKey.currentState?.unsetauth();
        setState(() {});
      } else {
        print("User role matches, setting authorization");
        authGateKey.currentState?.setauth();
        setState(() {});
      }
    } catch (e) {
      print("Error during sign-in: $e");
      authGateKey.currentState?.unsetauth();
      setState(() {});
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
            e.toString(),
            style: const TextStyle(color: Colors.white),
          ),
        ));
      }
    } finally {
      if (mounted) {
        Navigator.pop(context); 
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.black,
        body: SafeArea(
          minimum: const EdgeInsets.symmetric(horizontal: 25, vertical: 50),
          child: Center(
            child: Column(
              children: [
                const SizedBox(
                  height: 40,
                ),

                //login icon
                const Icon(
                  Icons.account_circle_rounded,
                  color: Color.fromARGB(255, 240, 220, 255),
                  size: 80,
                ),

                const SizedBox(
                  height: 80,
                ),

                //login text
                const Text(
                  'Welcome! Please sign in to continue!',
                  style: TextStyle(
                    color: Color.fromARGB(255, 214, 205, 255),
                    fontSize: 15,
                  ),
                ),

                const SizedBox(
                  height: 20,
                ),

                //text fields
                TextField(
                  style: const TextStyle(color: Colors.black),
                  controller: emailcontrol,
                  decoration: const InputDecoration(
                      enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                        color: Colors.white,
                        width: 1,
                      )),
                      focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                        color: Colors.white60,
                      )),
                      fillColor: Color.fromARGB(255, 223, 223, 223),
                      filled: true,
                      hintText: 'Email',
                      hintStyle: TextStyle(
                        color: Color.fromARGB(255, 59, 57, 63),
                      )),
                ),

                const SizedBox(
                  height: 10,
                ),

                TextField(
                  style: const TextStyle(color: Colors.black),
                  controller: passcontrol,
                  obscureText: _isObscure1,
                  decoration: InputDecoration(
                    enabledBorder: const OutlineInputBorder(
                        borderSide: BorderSide(
                      color: Colors.white,
                      width: 1,
                    )),
                    focusedBorder: const OutlineInputBorder(
                        borderSide: BorderSide(
                      color: Colors.white60,
                    )),
                    fillColor: const Color.fromARGB(255, 223, 223, 223),
                    filled: true,
                    hintText: 'Password',
                    hintStyle: const TextStyle(
                      color: Color.fromARGB(255, 59, 57, 63),
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isObscure1 ? Icons.visibility : Icons.visibility_off,
                        color: Colors.black,
                      ),
                      onPressed: () {
                        setState(() {
                          _isObscure1 =
                              !_isObscure1; // Toggle password visibility
                        });
                      },
                    ),
                  ),
                ),

                const SizedBox(
                  height: 20,
                ),

                //user role
                DropdownButton<String>(
                  value: _userType,
                  items: <String>['student', 'faculty'].map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value.toUpperCase()),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _userType = newValue!;
                    });
                  },
                ),

                const SizedBox(
                  height: 20,
                ),

                //Button
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(
                        255, 51, 40, 70), // Background color
                    foregroundColor: Colors.white, // Text color
                    padding: const EdgeInsets.symmetric(
                        vertical: 16), // Padding for height
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5), // Rounded corners
                    ),
                  ),
                  onPressed: signIn,
                  child: const SizedBox(
                    width: double.infinity,
                    child: Center(
                      child: Text(
                        'Log In',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(
                  height: 30,
                ),

                //text for register
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Don't have an account?",
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 4),
                    GestureDetector(
                      onTap: widget.onTap,
                      child: const Text(
                        'Register now',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color.fromARGB(255, 132, 104, 194),
                        ),
                      ),
                    )
                  ],
                ),
              ],
            ),
          ),
        ));
  }
}
