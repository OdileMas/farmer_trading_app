
import 'package:flutter/material.dart';
import 'package:farmer_trading_app/database_helper.dart';

class AdminProfileScreen extends StatefulWidget {
  final int adminId;
  AdminProfileScreen({required this.adminId});

  @override
  _AdminProfileScreenState createState() => _AdminProfileScreenState();
}

class _AdminProfileScreenState extends State<AdminProfileScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _loading = true;
  String _message = '';

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final profile = await DatabaseHelper.instance.getAdminProfile(widget.adminId);
    if (profile != null) {
      _usernameController.text = profile['username'];
      _passwordController.text = profile['password'];
    }
    setState(() => _loading = false);
  }

  Future<void> _saveProfile() async {
    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();

    if (username.isEmpty || password.isEmpty) {
      setState(() => _message = 'Username and password cannot be empty');
      return;
    }

    await DatabaseHelper.instance.updateAdmin(widget.adminId, username, password);
    setState(() => _message = 'Profile updated successfully');
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return Scaffold(body: Center(child: CircularProgressIndicator()));

    return Scaffold(
      appBar: AppBar(title: Text('Admin Profile')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            if (_message.isNotEmpty) Text(_message, style: TextStyle(color: Colors.green)),
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(labelText: 'Username'),
            ),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            SizedBox(height: 20),
            ElevatedButton(onPressed: _saveProfile, child: Text('Save')),
          ],
        ),
      ),
    );
  }
}
