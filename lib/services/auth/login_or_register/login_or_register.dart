import 'package:flutter/material.dart';
import 'package:my_flutter_project/ui/screens/registration_page/registration_page.dart';
import 'package:my_flutter_project/ui/screens/login_page/login_page.dart';


class LoginOrRegister extends StatefulWidget{
  const LoginOrRegister({super.key});

  @override
  State<LoginOrRegister> createState() => _LoginOrRegisterState();
}

class _LoginOrRegisterState extends State<LoginOrRegister> {

  bool showLoginPage = true;

  void togglePage() {
    setState(() {
      showLoginPage = !showLoginPage;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (showLoginPage) {
      return LoginPage(onPressed: togglePage,);
    } else {
      return RegistrationPage(onPressed: togglePage,);
    }
  }
}