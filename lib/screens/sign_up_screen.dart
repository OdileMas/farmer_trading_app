import 'package:flutter/material.dart';
import 'package:farmer_trading_app/database_helper.dart';
import 'package:farmer_trading_app/screens/home_screen.dart';
import 'package:farmer_trading_app/screens/farmer_dashboard.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  String name = '';
  String email = '';
  String password = '';
  String selectedRole = 'User';

  void _signUp() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final db = DatabaseHelper.instance;

      if (selectedRole == 'User') {
        await db.insertUser({
          'name': name,
          'email': email,
          'password': password,
        });

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomeScreen(userName: name)),
        );
      } else {
        // Insert farmer
        await db.insertFarmer({
          'name': name,
          'contact': password, // Password field used as farmer's contact
        });

        // Retrieve the inserted farmer to get their ID
        final farmer = await db.getFarmerByNameAndContact(name, password);

        if (farmer != null) {
          int farmerId = farmer['id'];
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => FarmerDashboard(
                farmerName: name,
                farmerId: farmerId, 
              ),
            ),
          );
        } else {
          // Error fallback
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to retrieve farmer data')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sign Up')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              DropdownButtonFormField<String>(
                value: selectedRole,
                items: ['User', 'Farmer']
                    .map((role) => DropdownMenuItem(value: role, child: Text(role)))
                    .toList(),
                onChanged: (value) => setState(() => selectedRole = value!),
                decoration: const InputDecoration(labelText: 'Select Role'),
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Full Name'),
                onSaved: (value) => name = value!,
                validator: (value) => value!.isEmpty ? 'Enter your name' : null,
              ),
              if (selectedRole == 'User')
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Email'),
                  onSaved: (value) => email = value!,
                  validator: (value) => value!.isEmpty ? 'Enter your email' : null,
                ),
              TextFormField(
                decoration: InputDecoration(
                  labelText: selectedRole == 'Farmer' ? 'Contact (used as password)' : 'Password',
                ),
                obscureText: selectedRole == 'User',
                onSaved: (value) => password = value!,
                validator: (value) => value!.isEmpty
                    ? 'Enter your ${selectedRole == 'Farmer' ? 'contact' : 'password'}'
                    : null,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _signUp,
                child: const Text('Sign Up'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
