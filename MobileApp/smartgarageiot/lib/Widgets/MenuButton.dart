import 'package:flutter/material.dart';

/// Reusable menu button widget
/// Makes a styled button with custom text & action
Widget buildMenuButton(
  BuildContext context,
  String text,
  VoidCallback onPressed,
) {
  return Center(
    child: SizedBox(
      width: 250, // Button width
      height: 70, // Button height
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
          backgroundColor: const Color(0xFFFFFFFF), // Button background color
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18), // Rounded button edges
          ),
          side: const BorderSide(
            color: Colors.blueAccent,
          ), // Button border color
        ),
        onPressed: onPressed, // Action when button is pressed
        child: Text(
          text, // Button label
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFFAF6767), // Text color
          ),
        ),
      ),
    ),
  );
}
