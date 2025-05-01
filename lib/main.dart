
import 'package:flutter/material.dart';
import 'package:farmer_trading_app/screens/admin_login_screen.dart';
import 'package:farmer_trading_app/screens/login_screen.dart';  // Assuming you have a user login screen
import 'package:farmer_trading_app/screens/admin_dashboard_screen.dart';
import 'package:farmer_trading_app/screens/home_screen.dart'; 
import 'package:farmer_trading_app/screens/sign_up_screen.dart';
import 'package:flutter/widgets.dart'; // Add this if not already

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // ⬅️ This is crucial
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => const RoleSelectionScreen(),
        '/admin_login': (context) => AdminLoginScreen(),
        '/user_login': (context) => LoginScreen(),  // Add your user login screen
        '/admin_dashboard': (context) => AdminDashboardScreen(),
        '/user_home': (context) => HomeScreen(),  // Add your user home screen for placing orders
        '/user_sign_up': (context) => SignUpScreen(), // Ensure this route is defined for the SignUpScreen
      },
    );
  }
}

class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Select Role')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/admin_login');
              },
              child: const Text('Login as Admin'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/user_login');
              },
              child: const Text('Login as User'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              child: const Text('Sign Up as User'),
              onPressed: () {
                Navigator.pushNamed(context, '/user_sign_up');  // Corrected this line
              },
            ),
          ],
        ),
      ),
    );
  }
} 