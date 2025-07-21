import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff1D1D28),
      body: SafeArea(
        child: Stack(
          children: [
            Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 40),
                    const Text(
                      "Create an\naccount",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 40),

                    _authTextField(
                      icon: Icons.person,
                      hint: 'Username or Email',
                      controller: emailController,
                    ),
                    const SizedBox(height: 20),
                    _authTextField(
                      icon: Icons.lock,
                      hint: 'Password',
                      isPassword: true,
                      controller: passwordController,
                    ),
                    const SizedBox(height: 20),
                    _authTextField(
                      icon: Icons.lock,
                      hint: 'Confirm Password',
                      isPassword: true,
                      controller: confirmPasswordController,
                    ),
                    const SizedBox(height: 16),

                    RichText(
                      text: const TextSpan(
                        text: "By clicking the ",
                        style: TextStyle(color: Colors.grey),
                        children: [
                          TextSpan(
                            text: "Register",
                            style: TextStyle(color: Colors.red),
                          ),
                          TextSpan(
                            text: " button, you agree to the public offer",
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Register",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Container(
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: RadialGradient(
                              colors: [Colors.deepOrange, Colors.red],
                              center: Alignment.center,
                              radius: 0.8,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.redAccent,
                                blurRadius: 12,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                          child: IconButton(
                            icon: const Icon(
                              Icons.arrow_forward,
                              color: Colors.white,
                            ),
                            onPressed: _registerUser,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),

                    // const Center(
                    //   child: Text(
                    //     "sign up with",
                    //     style: TextStyle(color: Colors.white70),
                    //   ),
                    // ),
                    const SizedBox(height: 20),

                    // Row(
                    //   mainAxisAlignment: MainAxisAlignment.center,
                    //   children: [_socialIcon("images/google.webp")],
                    // ),
                    // const SizedBox(height: 30),
                    Center(
                      child: RichText(
                        text: TextSpan(
                          text: "Already have an account? ",
                          style: const TextStyle(color: Colors.grey),
                          children: [
                            TextSpan(
                              text: "Sign In",
                              style: const TextStyle(color: Colors.red),
                              recognizer:
                                  TapGestureRecognizer()
                                    ..onTap = () {
                                      Navigator.pushNamed(context, '/signin');
                                    },
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),

            Positioned(
              top: 16,
              right: 16,
              child: GestureDetector(
                onTap: () {
                  Navigator.pushReplacementNamed(context, '/');
                },
                child: const Text(
                  'Skip',
                  style: TextStyle(
                    color: Colors.grey,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _authTextField({
    required IconData icon,
    required String hint,
    bool isPassword = false,
    required TextEditingController controller,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF2C2C2E),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: TextField(
        controller: controller,
        obscureText: isPassword,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          icon: Icon(icon, color: Colors.white),
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.grey),
          border: InputBorder.none,
          suffixIcon:
              isPassword
                  ? const Icon(Icons.visibility, color: Colors.grey)
                  : null,
        ),
      ),
    );
  }

  // static Widget _socialIcon(String assetPath) {
  //   return Container(
  //     padding: const EdgeInsets.all(12),
  //     decoration: const BoxDecoration(shape: BoxShape.circle),
  //     child: Image.asset(assetPath, width: 35, height: 35, fit: BoxFit.contain),
  //   );
  // }

  Future<void> _registerUser() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();
    final confirmPassword = confirmPasswordController.text.trim();

    if (password != confirmPassword) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Passwords do not match')));
      return;
    }

    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      Navigator.pushReplacementNamed(context, '/');
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }
}
