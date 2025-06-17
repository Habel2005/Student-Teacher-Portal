import 'package:flutter/material.dart';
import 'package:new_project4/pages/authpages/login.dart';
import 'package:new_project4/pages/authpages/Register.dart';
class LogorReg extends StatefulWidget {
  const LogorReg({super.key});

  @override
  State<LogorReg> createState() => _LogorRegState();
}

class _LogorRegState extends State<LogorReg> {
  bool isLogin=true;

  void toggle()
  {
    setState(() {
      isLogin = !isLogin;
    });
  }
  @override
  Widget build(BuildContext context) {
    if(isLogin)
    {
      return LoginPage(onTap: toggle);
    }
    else
    {
      return RegisterPage(onTap: toggle);
    }
  }
}