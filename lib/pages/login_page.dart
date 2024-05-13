import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../Components/button.dart';
import '../Components/textfield.dart';
import '../service/auth/auth_service.dart';

class LoginPage extends StatelessWidget {
  final void Function()? onTap;

  LoginPage({super.key, required this.onTap});

  TextEditingController email = TextEditingController();
  TextEditingController pass = TextEditingController(text: '123456');

  void login(BuildContext context) async {
    final authService = AuthService();
    try {
      await authService.signInWithEmailPassword(email.text, pass.text);
    } catch (e) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(e.toString()),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.message,
                size: 60,
                color: Theme.of(context).colorScheme.primary,
              ),
              SizedBox(height: 50),
              Text('Welcome back, you\'ve been missed'),
              SizedBox(height: 25),
              TextFieldCustom(
                hintText: 'Username',
                obscureText: false,
                controller: email,
              ),
              SizedBox(height: 10),
              TextFieldCustom(
                hintText: 'Password',
                obscureText: true,
                controller: pass,
              ),
              SizedBox(height: 25),
              Button(
                text: 'Login',
                onTap: () => login(context),
              ),
              SizedBox(height: 25),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Not a member? '),
                  GestureDetector(
                    onTap: onTap,
                    child: Text(
                      'Register now',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
