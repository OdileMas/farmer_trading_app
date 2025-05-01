import 'package:flutter/material.dart';

class ProfilePage extends StatelessWidget {
  final Map<String, dynamic> user = {
    "name": "Odile Masengesho",
    "email": "odile@example.com",
    "phone": "+250 123 456 789",
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          CircleAvatar(
            radius: 50,
            backgroundColor: Colors.blue,
            child: Text(
              user['name'][0],
              style: const TextStyle(fontSize: 40, color: Colors.white),
            ),
          ),
          const SizedBox(height: 16),
          Center(child: Text(user['name'], style: Theme.of(context).textTheme.titleLarge)),  // Updated here
          const SizedBox(height: 8),
          Center(child: Text(user['email'], style: TextStyle(color: Colors.grey[700]))),
          const SizedBox(height: 8),
          Center(child: Text(user['phone'], style: TextStyle(color: Colors.grey[700]))),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {},
            child: const Text("Edit Profile"),
          ),
          TextButton(
            onPressed: () {},
            child: const Text("Logout", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
