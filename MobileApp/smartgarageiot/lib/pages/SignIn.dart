import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../helpers/supabase_helper.dart';
import 'RegisterPage.dart';
import '../Widgets/customtextfield.dart';
import '../Widgets/SocialButton.dart';
import 'UserLoader.dart';

class SignIn extends StatefulWidget {
  const SignIn({super.key});

  @override
  State<SignIn> createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  // SnackBar Helper → Shows success messages only
  void _showSnack(String message, {bool error = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: error ? Colors.red : Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // Dialog Helper → Used for showing login errors
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: Row(
          children: const [
            Icon(Icons.error_outline, color: Colors.red, size: 28),
            SizedBox(width: 8),
            Text("Login Failed", style: TextStyle(color: Colors.red)),
          ],
        ),
        content: Text(
          message,
          style: const TextStyle(fontSize: 16, color: Colors.black),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK", style: TextStyle(color: Colors.blue)),
          ),
        ],
      ),
    );
  }

  // Handles Email & Password Sign-In Logic
  Future<void> _signInWithEmail() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    // Validate empty fields first
    if (email.isEmpty || password.isEmpty) {
      _showErrorDialog("Please enter email & password");
      return;
    }

    try {
      setState(() => _isLoading = true);

      // Attempt to sign in using Supabase
      final response = await SupabaseHelper.client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      // Check if login succeeded
      if (response.session != null) {
        _showSnack("Login Successful ✅");

        // Navigate to user loader page after login
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const UserLoaderPage()),
        );
      } else {
        _showErrorDialog("Invalid email or password!");
      }
    } catch (e) {
      String errorMsg = "Something went wrong. Please try again.";

      // Handle common Supabase errors gracefully
      if (e.toString().contains("Invalid login credentials")) {
        errorMsg = "Wrong email or password!";
      } else if (e.toString().contains("Failed host lookup")) {
        errorMsg = "Failed to connect to the server!";
      } else if (e.toString().contains("user_not_found")) {
        errorMsg = "No account found with this email.";
      }

      _showErrorDialog(errorMsg);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Stack(
          children: [
            // Background image
            Container(
              height: MediaQuery.of(context).size.height,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/bg.jpg'),
                  fit: BoxFit.cover,
                ),
              ),
            ),

            // Semi-transparent dark overlay
            Container(
              height: MediaQuery.of(context).size.height,
              color: Colors.black.withOpacity(0.5),
            ),

            // Main content section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                children: [
                  SizedBox(height: MediaQuery.of(context).size.height * 0.1),

                  // App Title
                  Text(
                    "PENTAPARK",
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 50),

                  // Create new account button
                  TextButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const RegisterPage(),
                        ),
                      );
                    },
                    child: Text(
                      "Create new account",
                      style: GoogleFonts.poppins(
                        color: const Color(0xFFA7C5EF),
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),

                  // OR separator text
                  Text(
                    "or",
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Subtitle for login
                  Text(
                    "Log in with your email",
                    style: GoogleFonts.poppins(
                      color: const Color(0xFFA7C5EF),
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Email input field
                  customTextField(
                    controller: _emailController,
                    hint: "email@domain.com",
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 10),

                  // Password input field
                  customTextField(
                    controller: _passwordController,
                    hint: "Enter your password",
                    obscureText: true,
                  ),
                  const SizedBox(height: 20),

                  // Login button
                  SizedBox(
                    width: 150,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _signInWithEmail,
                      style: ButtonStyle(
                        shape: MaterialStateProperty.all(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        backgroundColor: MaterialStateProperty.all(
                          Colors.black,
                        ),
                      ),
                      child: _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : Text(
                              'Log in',
                              style: GoogleFonts.poppins(
                                color: const Color(0xFF87CEEB),
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // OR Divider
                  Row(
                    children: [
                      const Expanded(
                        child: Divider(color: Color(0xFFE6E6E6), thickness: 1),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Text(
                          "OR",
                          style: GoogleFonts.poppins(
                            color: Color(0xFFA7C5EF),
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const Expanded(
                        child: Divider(color: Color(0xFFE6E6E6), thickness: 1),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Google Sign In Button
                  buildSocialButton(
                    text: 'Continue with Google',
                    assetPath: 'assets/images/google.png',
                    onPressed: () {},
                  ),

                  // Apple Sign In Button
                  buildSocialButton(
                    text: 'Continue with Apple',
                    assetPath: 'assets/images/apple.png',
                    onPressed: () {},
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
