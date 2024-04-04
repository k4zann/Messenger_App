import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../services/auth/auth_service.dart';
import '../../widgets/login_button.dart';
import '../../widgets/login_textfield.dart';

class RegistrationPage extends StatefulWidget {
  const RegistrationPage({super.key, required this.onPressed});
  final void Function()? onPressed;
  @override
  State<RegistrationPage> createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    super.dispose();
  }


  void register() async {
    final authenticateService = Provider.of<AuthenticationService>(context, listen: false);

    try {
      await authenticateService.register(
        _nameController.text.trim(),
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Неверные данные"),
          ),
        );
      }
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
                  LoginTextField(
                    controller: _nameController,
                    hintText: "Имя",
                    obscureText: false,
                  ),
                  const SizedBox(height: 20),
                  LoginTextField(
                      controller: _emailController,
                      hintText: "Почта",
                      obscureText: false
                  ),
                  const SizedBox(height: 20),
                  LoginTextField(
                      controller: _passwordController,
                      hintText: "Пароль",
                      obscureText: true
                  ),
                  const SizedBox(height: 20),
                  LoginButton(
                      onTap: (){
                        register();
                      },
                      text: 'Зарегистрироваться'
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "У вас есть аккаунта?",
                        style: TextStyle(
                          fontSize: 16,
                        ),
                      ),
                      TextButton(
                        onPressed: widget.onPressed,
                        child: Text(
                          'Войти',
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