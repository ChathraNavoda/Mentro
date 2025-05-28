import 'package:flutter/material.dart';
import 'package:mentro/core/services/auth_service.dart';
import 'package:mentro/presentation/common/button_widget.dart';
import 'package:mentro/presentation/common/snackbar_widget.dart';
import 'package:mentro/presentation/common/text_field_widget.dart';
import 'package:mentro/presentation/screens/auth/forgot_pw_screen.dart';
import 'package:mentro/presentation/screens/auth/signup_screen.dart';
import 'package:mentro/presentation/screens/home/home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isLoading = false;

  @override
  void dispose() {
    super.dispose();
    emailController.dispose();
    passwordController.dispose();
  }

  void loginUsers() async {
    String res = await AuthService().loginUser(
      email: emailController.text,
      password: passwordController.text,
    );
    if (res == 'success') {
      setState(() {
        isLoading = true;
      });
      Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => HomeScreen()));
    } else {
      setState(() {
        isLoading = false;
      });
      showSnackBar(context, res);
    }
  }

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
                isPass: true,
              ),
              Button(
                onTap: loginUsers,
                text: 'Signin',
              ),
              ForgotPassword(),
              SizedBox(height: height / 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Don\'t have an account? ',
                    style: TextStyle(
                      fontSize: 16,
                      color: Color.fromARGB(128, 0, 0, 0),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SignupScreen(),
                        ),
                      );
                    },
                    child: Text(
                      'Signup',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Color(0xFF4ECDC4),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
