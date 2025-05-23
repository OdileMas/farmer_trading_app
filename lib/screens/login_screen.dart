import 'package:flutter/material.dart';
import 'package:farmer_trading_app/screens/home_screen.dart';
import 'package:farmer_trading_app/screens/farmer_dashboard.dart';
import 'package:farmer_trading_app/database_helper.dart';
import 'package:farmer_trading_app/screens/admin_dashboard_screen.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  String selectedRole = 'User'; // Default is User

  void handleLogin(BuildContext context) async {
    String username = _usernameController.text.trim();
    String password = passwordController.text.trim();

    if (username.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please enter both username and password")),
      );
      return;
    }

    final db = DatabaseHelper.instance;
    Map<String, dynamic>? account;

    if (selectedRole == 'User') {
      account = await db.validateUser(username, password);
    } else if (selectedRole == 'Farmer') {
      account = await db.validateFarmer(username, password);
    }

    if (account != null && account.isNotEmpty) {
      if (selectedRole == 'User') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => HomeScreen(userName: username),
          ),
        );
      } else if (selectedRole == 'Farmer') {
        int farmerId = account['id'];
       Navigator.pushReplacement(
  context,
  MaterialPageRoute(
    builder: (context) => FarmerDashboard(farmerName: username, farmerId: farmerId),
  ),
);
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Account not found. Please sign up first.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Colors.green;
    final backgroundColor = Colors.green.shade50;

    return Scaffold(
      appBar: AppBar(
        title: Text("Login"),
        backgroundColor: primaryColor,
      ),
      backgroundColor: backgroundColor,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            DropdownButtonFormField<String>(
              value: selectedRole,
              items: ['User', 'Farmer']
                  .map((role) => DropdownMenuItem(value: role, child: Text(role)))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  selectedRole = value!;
                });
              },
              decoration: InputDecoration(
                labelText: 'Select Role',
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: primaryColor),
                ),
              ),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(
                labelText: selectedRole == 'Farmer' ? "Farmer Name" : "Username / Email",
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: primaryColor),
                ),
              ),
            ),
            SizedBox(height: 10),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: selectedRole == 'Farmer' ? "Farmer Contact" : "Password",
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: primaryColor),
                ),
              ),
            ),
            SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  padding: EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: () => handleLogin(context),
                child: Text(
                  "Login",
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
