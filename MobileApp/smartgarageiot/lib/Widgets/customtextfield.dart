import 'package:flutter/material.dart';

Widget customTextField({
  required TextEditingController controller,
  required String hint,
  bool obscureText = false, // Hide text for password fields
  TextInputType keyboardType = TextInputType.text, // Default keyboard type
}) {
  return SizedBox(
    width: 400,
    height: 70,
    child: TextFormField(
      controller: controller, // Controller to manage the text input
      obscureText: obscureText, // Hide input text if it's a password
      keyboardType: keyboardType, // Set keyboard type based on field
      style: const TextStyle(color: Colors.black),
      autovalidateMode: AutovalidateMode.onUserInteraction, // Validate when user types
      decoration: InputDecoration(
        hintText: hint, // Placeholder text
        hintStyle: const TextStyle(color: Color(0xFF4C4343)),
        filled: true,
        fillColor: Colors.white,
        errorMaxLines: 1,
        errorStyle: const TextStyle(
          color: Colors.red,
          fontSize: 14,
          height: 0.6,
          fontWeight: FontWeight.bold,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12), // Rounded corners
          borderSide: const BorderSide(
            color: Color(0xFFA7C5EF),
            width: 5.0,
          ),
        ),
      ),
      // Field validation logic
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return "This field is required"; // Show error if empty
        }

        // Email validation using regex
        if (keyboardType == TextInputType.emailAddress) {
          final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
          if (!emailRegex.hasMatch(value.trim())) {
            return "Please enter a valid email";
          }
        }

        return null; // Valid input
      },
    ),
  );
}
