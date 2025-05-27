import 'package:flutter/material.dart';
import 'package:mentro/presentation/common/text_field_widget.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SizedBox(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                height: height / 3.7,
                width: double.infinity,
                child: Image.asset(
                  'assets/images/logo.png',
                  scale: 1.5,
                ),
              ),
              TextFieldInput(
                textEditingController: emailController,
                hintText: 'Email',
                icon: Icons.email,
              ),
              TextFieldInput(
                textEditingController: passwordController,
                hintText: 'Password',
                icon: Icons.lock,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 35),
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    'Forgot password?',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Color(0xFF4ECDC4),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
