import 'package:flutter/material.dart';
import 'package:farmer_trading_app/database_helper.dart';
import 'package:farmer_trading_app/screens/home_screen.dart';

class SignUpScreen extends StatefulWidget {  // Change to StatefulWidget
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();  // createState method is fine now
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  String name = '';
  String email = '';
  String password = '';

  void _signUp() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      // Insert user data into the database
      await DatabaseHelper.instance.insertUser({
        'name': name,
        'email': email,
        'password': password,
      });

      // Navigate to the home screen after successful sign-up
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomeScreen(userName: name)), // Pass name as userName
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('User Sign Up')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: 'Full Name'),
                onSaved: (value) => name = value!,
                validator: (value) =>
                    value!.isEmpty ? 'Enter your name' : null,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Email'),
                onSaved: (value) => email = value!,
                validator: (value) =>
                    value!.isEmpty ? 'Enter your email' : null,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Password'),
                obscureText: true,
                onSaved: (value) => password = value!,
                validator: (value) =>
                    value!.isEmpty ? 'Enter your password' : null,
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
