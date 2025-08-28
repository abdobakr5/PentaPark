import 'package:flutter/material.dart';
import 'Pages/SignIn.dart';
import 'Pages/RegisterPage.dart';
import 'helpers/supabase_helper.dart';
import 'helpers/MQTT.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Ensures Flutter is ready before running async code

  await SupabaseHelper.init(); // Initialize Supabase for authentication & database handling

  final mqttService = MQTTService(); // Create an instance of MQTT service
  await mqttService.connect(); // Connect to MQTT broker for real-time updates

  runApp(const MyApp()); // Start the Flutter app
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: '/login',
      // Default route when the app starts
      routes: {
        '/login': (context) => const SignIn(), // Login page route
        '/register': (context) => const RegisterPage(), // Register page route
      },
      debugShowCheckedModeBanner: false,
      // Hide the debug banner
      title: 'Garage Management',
      // App title
      home: const SignIn(), // Set SignIn as the default home screen
    );
  }
}
