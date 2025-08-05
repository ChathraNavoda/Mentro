import 'package:flutter/material.dart';
import 'package:keyboard_safe/keyboard_safe.dart';
import 'package:mentro/core/services/auth_service.dart';
import 'package:mentro/core/services/google_service.dart';
import 'package:mentro/presentation/common/button_widget.dart';
import 'package:mentro/presentation/common/snackbar_widget.dart';
import 'package:mentro/presentation/common/text_field_widget.dart';
import 'package:mentro/presentation/screens/auth/forgot_pw_screen.dart';
import 'package:mentro/presentation/screens/auth/signup_screen.dart';
import 'package:mentro/presentation/screens/home/custom_bottom_navbar.dart';

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
    setState(() {
      isLoading = true;
    });

    Map<String, String> res = await AuthService().loginUser(
      email: emailController.text.trim(),
      password: passwordController.text.trim(),
    );

    setState(() {
      isLoading = false;
    });

    if (res['status'] == 'success') {
      showSnackBar(
          context, 'Welcome to Mentro! You have logged in successfully.');

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => CustomBottomNavbar()),
      );
    } else if (res['status'] == 'not_verified') {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Email Not Verified'),
          content: Text(
            '${res['message']}\n\nPlease check your spam folder if you don’t see the email.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('OK'),
            ),
          ],
        ),
      );
    } else {
      showSnackBar(context, res['message'] ?? 'An error occurred.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: KeyboardSafe(
        scroll: true,
        autoScrollToFocused: true,
        dismissOnTapOutside: true,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height / 3.7,
              width: double.infinity,
              child: Image.asset('assets/images/logo3.png'),
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
              text: isLoading ? 'Loading...' : 'Signin',
            ),
            ForgotPassword(),
            const SizedBox(height: 20),
            Row(
              children: [
                const Expanded(
                  child: Divider(color: Color.fromARGB(111, 0, 0, 0)),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8.0),
                  child: Text('Or'),
                ),
                const Expanded(
                  child: Divider(color: Color.fromARGB(111, 0, 0, 0)),
                ),
              ],
            ),
            InkWell(
              onTap: () async {
                setState(() => isLoading = true);
                String res = await GoogleService().signInWithGoogle();
                if (!mounted) return;
                setState(() => isLoading = false);

                if (res == 'success') {
                  showSnackBar(context,
                      'Welcome to Mentro! You have logged in successfully.');
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const CustomBottomNavbar()));
                } else {
                  showSnackBar(context, res);
                }
              },
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Container(
                  alignment: Alignment.center,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: ShapeDecoration(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                      side:
                          const BorderSide(color: Color.fromARGB(122, 0, 0, 0)),
                    ),
                    color: Colors.white,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      const Text(
                        'Continue with Google',
                        style: TextStyle(
                          color: Color.fromARGB(125, 0, 0, 0),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Image.network(
                        'https://static.vecteezy.com/system/resources/previews/022/613/027/non_2x/google-icon-logo-symbol-free-png.png',
                        height: 24,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Don\'t have an account? ',
                  style: TextStyle(
                      fontSize: 16, color: Color.fromARGB(128, 0, 0, 0)),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => SignupScreen()),
                    );
                  },
                  child: const Text(
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
    );
  }
}
