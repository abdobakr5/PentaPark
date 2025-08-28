import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

bool _isLoading = false; // Flag to handle loading state for the button

/// Builds a custom social login button with an icon and label.
/// Example: Google, Facebook, Apple sign-in buttons.
Widget buildSocialButton({
  required String text, // Button label text (e.g., "Sign in with Google")
  required String assetPath, // Path to the social platform icon image
  required VoidCallback onPressed, // Callback when the button is clicked
}) {
  return Container(
    width: double.infinity, // Make the button take full width
    height: 56, // Fixed height for consistent sizing
    margin: const EdgeInsets.symmetric(vertical: 8), // Spacing between buttons
    child: OutlinedButton(
      // Disable the button while loading to avoid multiple clicks
      onPressed: _isLoading ? null : onPressed,
      style: OutlinedButton.styleFrom(
        side: const BorderSide(color: Colors.white, width: 1.5), // White border
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12), // Rounded corners
        ),
        backgroundColor: Colors.white, // White background for the button
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Social platform icon
          Image.asset(assetPath, height: 24, width: 24),

          const SizedBox(width: 12), // Spacing between icon and text
          // Button text using Google Fonts for a modern look
          Text(
            text,
            style: GoogleFonts.poppins(
              color: Colors.black,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    ),
  );
}
