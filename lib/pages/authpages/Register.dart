import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:new_project4/auth/auth_page.dart';
import 'package:new_project4/pages/authpages/additionaldata.dart';

class RegisterPage extends StatefulWidget {
  final void Function()? onTap;
  const RegisterPage({super.key, required this.onTap});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  String _userType = 'student';
  final TextEditingController emailcontrol = TextEditingController();
  final TextEditingController passcontrol = TextEditingController();
  final TextEditingController confrmpasscontrol = TextEditingController();
  bool _isObscure1 = true;
  bool _isObscure2 = true;

  //sign up
  void signUp() async {
    if (emailcontrol.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Email can't be empty"),
      ));
      return;
    } else if (passcontrol.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Password can't be empty"),
      ));
      return;
    } else if (passcontrol.text != confrmpasscontrol.text) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Passwords do not match'),
      ));
      return;
    }

    //get auth service
    // final authService = Provider.of<AuthService>(context, listen: false);
    final authService = AuthService();

    try {
      User? user = await authService.signUpwithEmailandPassword(
          emailcontrol.text, passcontrol.text, _userType);
      
      if (user != null) {
        // Navigate to AdditionalInfoPage after successful registration
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => AdditionalInfoPage(userType: _userType),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
        ),
      );
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
                  "Let's create an account for you!",
                  style: TextStyle(
                      color: Color.fromARGB(255, 214, 205, 255),
                      fontSize: 15,
                      fontFamily: 'Poppins'),
                ),

                const SizedBox(
                  height: 20,
                ),

                //text fields
                TextField(
                  style: const TextStyle(
                    color: Colors.black
                  ),
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
                  style: const TextStyle(
                    color: Colors.black
                  ),
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
                        _isObscure1 ? Icons.visibility : Icons.visibility_off,color: Colors.black,
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
                  height: 10,
                ),

                //confrim passowrd
                TextField(
                  style: const TextStyle(
                    color: Colors.black
                  ),
                  controller: confrmpasscontrol,
                  obscureText: _isObscure2,
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
                    hintText: 'Confirm Password',
                    hintStyle: const TextStyle(
                      color: Color.fromARGB(255, 59, 57, 63),
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isObscure2 ? Icons.visibility : Icons.visibility_off,color: Colors.black,
                      ),
                      onPressed: () {
                        setState(() {
                          _isObscure2 =
                              !_isObscure2; // Toggle password visibility
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
                  onPressed: signUp,
                  child: const SizedBox(
                    width: double.infinity,
                    child: Center(
                      child: Text(
                        'Sign Up',
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
                      "Already have an account?",
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 4),
                    GestureDetector(
                      onTap: widget.onTap,
                      child: const Text(
                        'Login now',
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
