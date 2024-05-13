import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../Components/button.dart';
import '../Components/textfield.dart';
import '../service/auth/auth_service.dart';

class RegisterPage extends StatelessWidget {
  final void Function()? onTap;

  RegisterPage({required this.onTap});

  TextEditingController email = TextEditingController();

  TextEditingController pass = TextEditingController();

  TextEditingController conrpass = TextEditingController();

  void register(BuildContext context) {
    final _auth = AuthService();
    if (pass.text == conrpass.text) {
      try {
        _auth.signUpWithEmailPassword(email.text, pass.text);
      } catch (e) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(
              e.toString(),
            ),
          ),
        );
      }
    } else {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(
            'Password dont match!',
          ),
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
              Text('Lets\'s create an account for you'),
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
              SizedBox(height: 10),
              TextFieldCustom(
                hintText: 'Confirm Password',
                obscureText: true,
                controller: conrpass,
              ),
              SizedBox(height: 25),
              Button(
                text: 'Register',
                onTap: () => register(context),
              ),
              SizedBox(height: 25),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Already have an account? '),
                  GestureDetector(onTap: onTap, child: Text('Login now', style: TextStyle(fontWeight: FontWeight.bold),)),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
