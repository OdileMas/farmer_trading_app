import 'package:flutter/material.dart';
import 'package:farmer_trading_app/database_helper.dart';
import 'admin_chat_screen.dart';
import 'admin_profile_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  final int adminId;
  final String adminName;

  const AdminDashboardScreen({
    Key? key,
    required this.adminId,
    required this.adminName,
  }) : super(key: key);

  static Route route(Map<String, dynamic> args) {
    return MaterialPageRoute(
      builder: (_) => AdminDashboardScreen(
        adminId: args['adminId'],
        adminName: args['adminName'],
      ),
    );
  }

  @override
  _AdminDashboardScreenState createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  List<Map<String, dynamic>> _farmers = [];
  List<Map<String, dynamic>> _filteredFarmers = [];
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadFarmers();
    _searchController.addListener(_filterFarmers);
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterFarmers);
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadFarmers() async {
    try {
      final farmers = await DatabaseHelper.instance.getFarmers();
      if (mounted) {
        setState(() {
          _farmers = farmers;
          _filteredFarmers = farmers;
        });
      }
    } catch (e) {
      _showSnackBar('Error loading farmers: $e');
    }
  }

  void _filterFarmers() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredFarmers = _farmers.where((farmer) {
        final name = farmer['name']?.toString().toLowerCase() ?? '';
        final contact = farmer['contact']?.toString().toLowerCase() ?? '';
        return name.contains(query) || contact.contains(query);
      }).toList();
    });
  }

  Future<void> _addFarmerDialog() async {
    final _nameController = TextEditingController();
    final _contactController = TextEditingController();

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Add Farmer'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: 'Name'),
            ),
            TextField(
              controller: _contactController,
              decoration: InputDecoration(labelText: 'Contact'),
              keyboardType: TextInputType.phone,
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context), child: Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              final name = _nameController.text.trim();
              final contact = _contactController.text.trim();

              if (name.isEmpty || contact.isEmpty) {
                _showSnackBar('Please enter both name and contact');
                return;
              }

              Navigator.pop(context); // Close input dialog

              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (_) => Center(child: CircularProgressIndicator()),
              );

              try {
                await DatabaseHelper.instance
                    .addFarmer({'name': name, 'contact': contact});
                await _loadFarmers();
              } catch (e) {
                _showSnackBar('Error adding farmer: $e');
              } finally {
                if (mounted) Navigator.pop(context); // Close loading
              }
            },
            child: Text('Add'),
          ),
        ],
      ),
    );
  }

  Future<void> _editFarmerDialog(Map<String, dynamic> farmer) async {
    final _nameController = TextEditingController(text: farmer['name'] ?? '');
    final _contactController =
        TextEditingController(text: farmer['contact'] ?? '');

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Edit Farmer'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: 'Name'),
            ),
            TextField(
              controller: _contactController,
              decoration: InputDecoration(labelText: 'Contact'),
              keyboardType: TextInputType.phone,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              final name = _nameController.text.trim();
              final contact = _contactController.text.trim();

              if (name.isEmpty || contact.isEmpty) {
                _showSnackBar('Please enter both name and contact');
                return;
              }

              Navigator.pop(context); // Close dialog

              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (_) => Center(child: CircularProgressIndicator()),
              );

              try {
                await DatabaseHelper.instance
                    .updateFarmer(farmer['id'], {'name': name, 'contact': contact});
                await _loadFarmers();
              } catch (e) {
                _showSnackBar('Error updating farmer: $e');
              } finally {
                if (mounted) Navigator.pop(context); // Close loading
              }
            },
            child: Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDeleteFarmer(int id) async {
    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Confirm Delete'),
        content: Text('Are you sure you want to delete this farmer?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context); // Close dialog
              try {
                await _deleteFarmer(id);
              } catch (e) {
                _showSnackBar('Error deleting farmer: $e');
              }
            },
            child: Text('Delete'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteFarmer(int id) async {
    await DatabaseHelper.instance.deleteFarmer(id);
    await _loadFarmers();
  }

  void _openMessages(String farmerName) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AdminChatScreen(farmerName: farmerName),
      ),
    );
  }

  void _openProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AdminProfileScreen(adminId: widget.adminId),
      ),
    );
  }

  void _logout() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Logout'),
        content: Text('Are you sure you want to logout?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Logout screen
            },
            child: Text('Logout'),
          ),
        ],
      ),
    );
  }

  void _openNotifications() {
    _showSnackBar('No notifications available');
  }

  void _showSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Welcome, ${widget.adminName}'),
        actions: [
          IconButton(icon: Icon(Icons.notifications), onPressed: _openNotifications),
          IconButton(icon: Icon(Icons.person), onPressed: _openProfile),
          IconButton(icon: Icon(Icons.logout), onPressed: _logout),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(8),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Search Farmers',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _loadFarmers,
              child: _filteredFarmers.isEmpty
                  ? Center(child: Text('No farmers found'))
                  : ListView.builder(
                      itemCount: _filteredFarmers.length,
                      itemBuilder: (context, index) {
                        final farmer = _filteredFarmers[index];
                        final name = farmer['name']?.toString().trim() ?? '';
                        final firstLetter = name.isNotEmpty ? name[0].toUpperCase() : '?';

                        return ListTile(
                          leading: CircleAvatar(
                            child: Text(firstLetter),
                          ),
                          title: Text(name),
                          subtitle: Text(farmer['contact'] ?? ''),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: Icon(Icons.chat),
                                onPressed: () => _openMessages(name),
                                tooltip: 'Chat',
                              ),
                              IconButton(
                                icon: Icon(Icons.edit),
                                onPressed: () => _editFarmerDialog(farmer),
                                tooltip: 'Edit',
                              ),
                              IconButton(
                                icon: Icon(Icons.delete),
                                onPressed: () => _confirmDeleteFarmer(farmer['id']),
                                tooltip: 'Delete',
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addFarmerDialog,
        child: Icon(Icons.add),
        tooltip: 'Add Farmer',
      ),
    );
  }
}
