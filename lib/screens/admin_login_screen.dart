import 'package:flutter/material.dart';
import 'package:farmer_trading_app/database_helper.dart';

class AdminLoginScreen extends StatefulWidget {
  @override
  _AdminLoginScreenState createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends State<AdminLoginScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String _error = '';

  Future<void> _loginAdmin() async {
    setState(() {
      _error = '';
    });

    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();

    if (username.isEmpty || password.isEmpty) {
      setState(() {
        _error = 'Please fill in both fields';
      });
      return;
    }

    final dbHelper = DatabaseHelper.instance;
    final admin = await dbHelper.validateAdmin(username, password);

    if (admin != null) {
      _usernameController.clear();
      _passwordController.clear();
      // Navigate to the admin dashboard and pass arguments
      Navigator.pushReplacementNamed(
        context,
        '/admin_dashboard',
        arguments: {
          'adminId': admin['id'],
          'adminName': admin['username'],
        },
      );
    } else {
      setState(() {
        _error = 'Invalid credentials';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Admin Login')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_error.isNotEmpty)
              Text(_error, style: TextStyle(color: Colors.red)),
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(labelText: 'Username'),
            ),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: InputDecoration(labelText: 'Password'),
            ),
            SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                ),
                onPressed: _loginAdmin, // ✅ fixed: now triggers login
                child: Text('Login'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
