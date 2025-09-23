// ignore_for_file: file_names

import 'package:flutter/material.dart';
import '../models/constants.dart';
import 'siginPage.dart';  // Import the signin page to navigate back to it

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  bool _isPasswordObscured = true;
  bool _isConfirmPasswordObscured = true;
  bool _isLoading = false;

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
  
  // You can add your pseudo sign-up logic here later
  Future<void> _signUp() async {
    // TODO: Add sign-up validation and logic
    print('Signing up...');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 40.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // 1. App Logo and Welcome Text
                const Icon(
                  Icons.theaters,
                  size: 80,
                  color: kPrimaryColor,
                ),
                const SizedBox(height: 20),
                const Text(
                  'Create Account',
                  style: TextStyle(
                    color: kAccentColor,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Start your movie journey with us',
                  style: TextStyle(
                    color: kGreyColor,
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 50),

                // 2. Username Text Field
                TextField(
                  controller: _usernameController,
                  decoration: InputDecoration(
                    hintText: 'Username',
                    hintStyle: const TextStyle(color: kGreyColor),
                    prefixIcon: const Icon(Icons.person, color: kGreyColor),
                    filled: true,
                    fillColor: kTextFieldFill,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  style: const TextStyle(color: kAccentColor),
                ),
                const SizedBox(height: 20),
                
                // 3. Email Text Field
                TextField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    hintText: 'Email',
                    hintStyle: const TextStyle(color: kGreyColor),
                    prefixIcon: const Icon(Icons.email_rounded, color: kGreyColor),
                    filled: true,
                    fillColor: kTextFieldFill,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  style: const TextStyle(color: kAccentColor),
                ),
                const SizedBox(height: 20),

                // 4. Password Text Field
                TextField(
                  controller: _passwordController,
                  obscureText: _isPasswordObscured,
                  decoration: InputDecoration(
                    hintText: 'Password',
                    hintStyle: const TextStyle(color: kGreyColor),
                    prefixIcon: const Icon(Icons.lock_rounded, color: kGreyColor),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isPasswordObscured ? Icons.visibility_off : Icons.visibility,
                        color: kGreyColor,
                      ),
                      onPressed: () {
                        setState(() {
                          _isPasswordObscured = !_isPasswordObscured;
                        });
                      },
                    ),
                    filled: true,
                    fillColor: kTextFieldFill,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  style: const TextStyle(color: kAccentColor),
                ),
                const SizedBox(height: 20),

                // 5. Confirm Password Text Field
                TextField(
                  controller: _confirmPasswordController,
                  obscureText: _isConfirmPasswordObscured,
                  decoration: InputDecoration(
                    hintText: 'Confirm Password',
                    hintStyle: const TextStyle(color: kGreyColor),
                    prefixIcon: const Icon(Icons.lock_clock, color: kGreyColor),
                     suffixIcon: IconButton(
                      icon: Icon(
                        _isConfirmPasswordObscured ? Icons.visibility_off : Icons.visibility,
                        color: kGreyColor,
                      ),
                      onPressed: () {
                        setState(() {
                          _isConfirmPasswordObscured = !_isConfirmPasswordObscured;
                        });
                      },
                    ),
                    filled: true,
                    fillColor: kTextFieldFill,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  style: const TextStyle(color: kAccentColor),
                ),
                const SizedBox(height: 40),

                // 6. Sign Up Button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _signUp,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kPrimaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            'Sign Up',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: kAccentColor,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 40),

                // 7. Sign In Link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Already have an account? ",
                      style: TextStyle(color: kGreyColor),
                    ),
                    GestureDetector(
                      onTap: () {
                        // Navigate back to the Sign In page
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(builder: (context) => const SigninPage()),
                        );
                      },
                      child: const Text(
                        'Sign In',
                        style: TextStyle(
                          color: kPrimaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}