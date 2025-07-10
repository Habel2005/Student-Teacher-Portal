import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:new_project4/auth/auth_gate.dart';
import 'package:new_project4/firebase_options.dart';

final GlobalKey<AuthGateState> authGateKey = GlobalKey<AuthGateState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const Home());
}

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: AuthGate(key: authGateKey),
      theme: ThemeData(

        snackBarTheme: const SnackBarThemeData(
            backgroundColor: Color.fromARGB(255, 63, 46, 75),
            contentTextStyle:
                TextStyle(color: Colors.white, fontFamily: 'Poppins')),

        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
              side: const BorderSide(
                color: Colors.white,
              ),
              foregroundColor: Colors.white),
        ),

        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: Colors.white, // This will change the text color
          ),
        ),

        useMaterial3: true,

        colorScheme: const ColorScheme(
          brightness: Brightness.dark,
          primary: Color.fromARGB(255, 71, 60, 79),
          onPrimary: Colors.white,
          secondary: Color.fromARGB(255, 51, 35, 54),
          onSecondary: Colors.white,
          surface: Color.fromARGB(255, 33, 18, 37),
          onSurface: Colors.white,
          error: Colors.redAccent,
          onError: Colors.white,
        ),

        fontFamily: 'Poppins',

        // dropdownMenuTheme: DropdownMenuThemeData(
        //   menuStyle: MenuStyle(
        //     backgroundColor: WidgetStateProperty.all(Colors.grey[900]),  // Set dropdown menu background color globally
        //     shape: WidgetStateProperty.all(
        //       RoundedRectangleBorder(
        //         borderRadius: BorderRadius.circular(8.0),  // Add border radius
        //         side: BorderSide(
        //           color: Colors.white,  // Add a light white border around the dropdown menu
        //           width: 1.0,
        //         ),
        //       ),
        //     ),
        //   ),
        //   textStyle: (TextStyle(color: Colors.white)), // Text color globally for dropdown items
        // ),
        
        // tabBarTheme: const TabBarTheme(
        //   labelColor: Color.fromARGB(255, 172, 138, 200), // Color for the selected tab text
        //   unselectedLabelColor: Colors.white, // Color for the unselected tab text
        // ),

        inputDecorationTheme: InputDecorationTheme(
          labelStyle: const TextStyle(color: Colors.white), // Label text color
          hintStyle: TextStyle(color: Colors.grey[400]), // Hint text color
          enabledBorder: OutlineInputBorder(
            borderSide: const BorderSide(
                color: Colors.white), // Border color when enabled
            borderRadius: BorderRadius.circular(8.0),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(
                color: Color.fromARGB(255, 70, 51, 87),
                width: 2.0), // Border color when focused
            borderRadius: BorderRadius.circular(8.0),
          ),
          errorBorder: OutlineInputBorder(
            borderSide: const BorderSide(
                color: Colors.redAccent), // Border color when error occurs
            borderRadius: BorderRadius.circular(8.0),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderSide: const BorderSide(
                color: Colors.redAccent,
                width: 2.0), // Border color when focused and error occurs
            borderRadius: BorderRadius.circular(8.0),
          ),
        ),
      ),
    );
  }
}
