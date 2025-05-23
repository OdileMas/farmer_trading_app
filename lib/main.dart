import 'package:flutter/material.dart';
import 'package:farmer_trading_app/screens/admin_login_screen.dart';
import 'package:farmer_trading_app/screens/login_screen.dart';
import 'screens/admin_dashboard_screen.dart';
import 'package:farmer_trading_app/screens/home_screen.dart'; 
import 'package:farmer_trading_app/screens/sign_up_screen.dart';
import 'package:farmer_trading_app/screens/farmer_dashboard.dart';
import 'package:flutter/widgets.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); 
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

        '/farmer_dashboard': (context) {
          final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
          return FarmerDashboard(
            farmerId: args['farmerId'],
            farmerName: args['farmerName'],
          );
        },

        '/admin_dashboard': (context) {
          final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
          return AdminDashboardScreen(
            adminId: args['adminId'],
            adminName: args['adminName'],
          );
        },

        '/user_home': (context) {
          final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
          return HomeScreen(
            userName: args['userName'], 
          );
        },

        '/user_sign_up': (context) => SignUpScreen(),
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
