import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'GarageHomePage.dart';

class UserLoaderPage extends StatefulWidget {
  const UserLoaderPage({super.key});

  @override
  State<UserLoaderPage> createState() => _UserLoaderPageState();
}

class _UserLoaderPageState extends State<UserLoaderPage> {
  String? displayName;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _loadUser(); // Load user data when page starts
  }

  // Fetch user info from Supabase
  Future<void> _loadUser() async {
    try {
      final supabase = Supabase.instance.client;
      final user = supabase.auth.currentUser!;

      // Get user's first name from profiles table
      final response = await supabase
          .from('profiles')
          .select('first_name')
          .eq('id', user.id)
          .maybeSingle();

      print(
        "✅ User loaded: $response" + " for user ID: ${user.id}",
      ); // Debug log

      setState(() {
        if (response != null && response['first_name'] != null) {
          displayName = response['first_name']; // Set user's name if available
        } else {
          displayName = "Guest"; // Default name if not found
        }
        loading = false;
      });
    } catch (e) {
      print("❌ Error loading user: $e");
      setState(() {
        displayName = "Guest"; // Fallback to guest on error
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      // Show loading indicator while fetching data
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // Navigate to GarageHomePage after loading user data
    return GarageHomePage(userName: displayName ?? "Guest");
  }
}
