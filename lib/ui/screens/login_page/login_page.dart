import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../services/auth/auth_service.dart';
import '../../widgets/login_button.dart';
import '../../widgets/login_textfield.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key, required this.onPressed});
  final void Function() onPressed;
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  void login() {
    final authenticateService = Provider.of<AuthenticationService>(context, listen: false);

    try {
      authenticateService.login(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );
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
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: GestureDetector(
            onTap: () {
              FocusScope.of(context).unfocus();
            },
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text(
                    'Вход',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  LoginTextField(controller: _emailController, hintText: "Email", obscureText: false),
                  const SizedBox(height: 20),
                  LoginTextField(controller: _passwordController, hintText: "Password", obscureText: true),
                  const SizedBox(height: 20),
                  LoginButton(
                      onTap: (){
                        login();
                      },
                      text: 'Войти'
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "У вас нет аккаунта?",
                        style: TextStyle(
                          fontSize: 16,
                        ),
                      ),
                      TextButton(
                        onPressed: widget.onPressed,
                        child: Text(
                          'Зарегистрироваться',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  )
                ]
            ),
          ),
        )
    );
  }
}