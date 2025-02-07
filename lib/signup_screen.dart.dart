import 'package:bytestodo/Login.dart';
import 'package:bytestodo/auth_service.dart';
import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:firebase_auth/firebase_auth.dart';

// Components
import '../../Widgets/custom_Button.dart';
import '../../Widgets/inputField.dart';
import '../../Widgets/custom_circle_button.dart';

final AuthService _authService = AuthService();

/// A stateful widget that represents the signup screen.
class Signup extends StatefulWidget {
  const Signup({super.key});

  @override
  State<Signup> createState() => _SignupState();
}

/// The state class for the Signup widget.
class _SignupState extends State<Signup> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

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
                              'Let`s get started!',
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
                              title: 'Sign up',
                              onPressed: () => createAccountHandler(context)(),
                            ),
                            
                            SizedBox(height: MediaQuery.of(context).size.height * 0.003),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Already have an account?',
                                  style: TextStyle(
                                    color: const Color.fromARGB(93, 57, 13, 236),
                                    fontSize: 15,
                                  ),
                                ),
                                TextButton(
                                  onPressed: () => loginHandler(context)(),
                                  child: Text(
                                    'Login',
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
                  fontSize: 23,
                  fontWeight: FontWeight.bold,
                  color: const Color.fromARGB(255, 249, 248, 252),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Function createAccountHandler(BuildContext context) {
  return () async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      // Show error if email or password is empty
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill in all fields.')),
      );
      return;
    }

    // Validate email format
    if (!RegExp(r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$").hasMatch(email)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter a valid email address.')),
      );
      return;
    }

    try {
      // Attempt to create a new account
      final userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      // Handle successful signup
      if (userCredential.user != null) {
        Navigator.pushNamed(context, '/home');
      }
    } on FirebaseAuthException catch (e) {
      // Handle Firebase errors
      if (e.code == 'weak-password') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('The password is too weak. Choose a stronger password.')),
        );
      } else if (e.code == 'email-already-in-use') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('An account already exists for this email.')),
        );
      } else if (e.code == 'invalid-email') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('The email address is not valid.')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Signup failed. Try again later.')),
        );
      }
    } catch (e) {
      // Handle any other errors
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An unexpected error occurred. Please try again.')),
      );
    }
  };
}

  Function loginHandler(BuildContext context) {
    return () {
      Navigator.push(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => Login(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(-1.0, 0.0);
            const end = Offset.zero;
            const curve = Curves.easeInOut;

            var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
            var offsetAnimation = animation.drive(tween);

            return SlideTransition(position: offsetAnimation, child: child);
          },
        ),
      );
    };
  }

  Function iconHandler() {
    return () {
      print('icon pressed');
    };
  }

  // Skip Handler to navigate directly to Home screen
  void skipHandler() {
    Navigator.pushNamed(context, '/home');
  }
}
