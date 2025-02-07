import 'package:bytestodo/auth_service.dart';
import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:firebase_auth/firebase_auth.dart';
import '../../Widgets/custom_Button.dart';
import '../../Widgets/inputField.dart';
import '../../Widgets/custom_circle_button.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final AuthService _authService = AuthService(); // AuthService Instance

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          // Main background content
          Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            decoration: const BoxDecoration(
              color: Color.fromARGB(255, 0, 47, 255),
            ),
            child: SingleChildScrollView(
              child: Center(
                child: AnimatedContainer(
                  duration: Duration(milliseconds: 1000),
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height,
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: Container(
                        width: MediaQuery.of(context).size.width,
                        height: MediaQuery.of(context).size.height * 0.8,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(100),
                            topRight: Radius.circular(100),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            SizedBox(height: MediaQuery.of(context).size.height * 0.04),
                            Image.asset(
                              'lib/Screenshot 2025-02-05 223126.png',
                              width: 100,
                              height: 100,
                              fit: BoxFit.contain,
                            ),
                            SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                            Text(
                              'Welcome Back!',
                              style: TextStyle(
                                color: const Color.fromARGB(255, 55, 44, 102),
                                fontWeight: FontWeight.bold,
                                fontSize: 29,
                              ),
                            ),
                            SizedBox(height: MediaQuery.of(context).size.height * 0.01),
                            Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: Column(
                                children: [
                                  InputField(
                                    controller: _emailController,
                                    title: 'Email id',
                                    hintText: 'Enter your email',
                                  ),
                                  SizedBox(height: MediaQuery.of(context).size.height * 0.01),
                                  InputField(
                                    title: 'Password',
                                    hintText: 'Enter your password',
                                    controller: _passwordController,
                                    obscureText: true,
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                            CustomButton(
                              title: 'Login',
                              onPressed: loginHandler,
                            ),
                            SizedBox(height: MediaQuery.of(context).size.height * 0.003),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Don’t have an account?',
                                  style: TextStyle(
                                    color: const Color.fromARGB(93, 57, 13, 236),
                                    fontSize: 15,
                                  ),
                                ),
                                TextButton(
                                  onPressed: signupHandler,
                                  child: Text(
                                    'Sign up',
                                    style: TextStyle(
                                      color: const Color.fromARGB(93, 57, 13, 236),
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: MediaQuery.of(context).size.height * 0.003),
                            Text(
                              "OR",
                              style: TextStyle(
                                color: const Color.fromARGB(93, 57, 13, 236),
                                fontSize: MediaQuery.of(context).size.height * 0.02,
                                fontWeight: FontWeight.w300,
                              ),
                            ),
                            SizedBox(height: MediaQuery.of(context).size.height * 0.01),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                CustomCircleButton(
                                  onPressed: iconHandler,
                                  imagePath: 'lib/images/metaLogo.png',
                                ),
                                SizedBox(width: 30),
                                CustomCircleButton(
                                  onPressed: iconHandler,
                                  imagePath: 'lib/images/googleLogo.png',
                                ),
                                SizedBox(width: 30),
                                CustomCircleButton(
                                  onPressed: iconHandler,
                                  imagePath: 'lib/images/appleLogo.png',
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          // Skip Button Fixed at the Top-Right Corner
          Positioned(
            top: 40, // Fixed top margin
            right: 20, // Fixed right margin
            child: TextButton(
              onPressed: skipHandler,
              child: Text(
                'Skip',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: const Color.fromARGB(255, 252, 250, 255),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> loginHandler() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isNotEmpty && password.isNotEmpty) {
      try {
        User? user = await _authService.login(email, password);
        if (user != null) {
          Navigator.pushNamed(context, '/home');
        } else {
          showSnackBar('Login failed. Please check your credentials.');
        }
      } catch (e) {
        showSnackBar('An error occurred: ${e.toString()}');
      }
    } else {
      showSnackBar('Please fill in all fields.');
    }
  }

  void showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  void signupHandler() {
    Navigator.pushNamed(context, '/signup');
  }

  void iconHandler() {
    print('Icon pressed');
  }

  // Skip Handler to navigate directly to Home screen
  void skipHandler() {
    Navigator.pushNamed(context, '/home');
  }
}
