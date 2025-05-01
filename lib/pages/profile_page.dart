import 'package:flutter/material.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Map<String, dynamic> user = {
    "name": "Odile Masengesho",
    "email": "odile@example.com",
    "phone": "+250 123 456 789",
  };

  void _editProfileDialog() {
    TextEditingController nameController = TextEditingController(text: user['name']);
    TextEditingController emailController = TextEditingController(text: user['email']);
    TextEditingController phoneController = TextEditingController(text: user['phone']);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Edit Profile"),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: "Name"),
              ),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(labelText: "Email"),
              ),
              TextField(
                controller: phoneController,
                decoration: const InputDecoration(labelText: "Phone"),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                user['name'] = nameController.text.trim();
                user['email'] = emailController.text.trim();
                user['phone'] = phoneController.text.trim();
              });
              Navigator.pop(context);
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  void _logoutConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Confirm Logout"),
        content: const Text("Are you sure you want to logout?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("No"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Leave profile screen
              // You can also add navigation to login screen if needed
            },
            child: const Text("Yes"),
          ),
        ],
      ),
    );
  }

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
          Center(child: Text(user['name'], style: Theme.of(context).textTheme.titleLarge)),
          const SizedBox(height: 8),
          Center(child: Text(user['email'], style: TextStyle(color: Colors.grey[700]))),
          const SizedBox(height: 8),
          Center(child: Text(user['phone'], style: TextStyle(color: Colors.grey[700]))),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _editProfileDialog,
            child: const Text("Edit Profile"),
          ),
          TextButton(
            onPressed: _logoutConfirmation,
            child: const Text("Logout", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
