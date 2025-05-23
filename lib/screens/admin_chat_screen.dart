import 'dart:async';
import 'package:flutter/material.dart';
import 'package:farmer_trading_app/database_helper.dart';
import 'package:farmer_trading_app/models/farmer_model.dart';
import 'package:farmer_trading_app/models/message.dart';
import 'package:intl/intl.dart'; // For formatting time

class AdminChatScreen extends StatefulWidget {
  final String farmerName;

  const AdminChatScreen({Key? key, required this.farmerName}) : super(key: key);

  @override
  State<AdminChatScreen> createState() => _AdminChatScreenState();
}

class _AdminChatScreenState extends State<AdminChatScreen> {
  List<Farmer> _allUsers = [];
  List<Farmer> _filteredUsers = [];
  String? _selectedUser;
  List<Message> _messages = [];

  final TextEditingController _messageController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  // To avoid setState after widget is disposed
  bool _isMounted = true;

  @override
  void initState() {
    super.initState();
    _loadFarmers();
  }

  @override
  void dispose() {
    _isMounted = false;
    _messageController.dispose();
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadFarmers() async {
    try {
      final data = await DatabaseHelper.instance.getAllFarmers();
      if (!_isMounted) return;

      setState(() {
        _allUsers = data.map((user) => Farmer.fromMap(user as Map<String, dynamic>)).toList();
        _filteredUsers = _allUsers;
      });
    } catch (e) {
      // Handle error gracefully (show Snackbar or log)
      if (_isMounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load farmers: $e')),
        );
      }
    }
  }

  Future<void> _loadMessages() async {
    if (_selectedUser == null) return;

    try {
      // Fetch messages between admin and selected user
      final data = await DatabaseHelper.instance.getMessages('admin', _selectedUser!);

      // Mark unseen received messages as seen
      for (var msgMap in data) {
        final msg = Message.fromMap(msgMap);
        if (msg.receiverId == 'admin' && msg.seen == 0 && msg.id != null) {
          await DatabaseHelper.instance.updateMessageSeen(msg.id!, 1);
        }
      }

      // Reload messages after update
      final refreshedData = await DatabaseHelper.instance.getMessages('admin', _selectedUser!);
      if (!_isMounted) return;

      setState(() {
        _messages = refreshedData.map((m) => Message.fromMap(m)).toList();
      });

      // Scroll to bottom to show latest message
      _scrollToBottom();
    } catch (e) {
      if (_isMounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load messages: $e')),
        );
      }
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  void _filterUsers(String query) {
    final filtered = _allUsers.where((user) {
     return  user.name?.toLowerCase().contains(query.toLowerCase()) ?? false;
    }).toList();

    if (_isMounted) {
      setState(() {
        _filteredUsers = filtered;
      });
    }
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty || _selectedUser == null) {
      return;
    }

    final message = Message(
      senderId: 'admin',
      receiverId: _selectedUser!,
      content: _messageController.text.trim(),
      timestamp: DateTime.now(),
      seen: 0,
    );

    try {
      await DatabaseHelper.instance.insertMessage(message.toMap());
      _messageController.clear();
      await _loadMessages();
    } catch (e) {
      if (_isMounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to send message: $e')),
        );
      }
    }
  }

  Widget _buildUserList() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: TextField(
            controller: _searchController,
            onChanged: _filterUsers,
            decoration: const InputDecoration(
              hintText: 'Search farmers',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(),
            ),
          ),
        ),
        Expanded(
          child: _filteredUsers.isEmpty
              ? const Center(child: Text('No farmers found'))
              : ListView.builder(
                  itemCount: _filteredUsers.length,
                  itemBuilder: (context, index) {
                    final user = _filteredUsers[index];
                    final isSelected = _selectedUser == user.name;

                    return ListTile(
                      title: Text(user.name ?? 'Unknown'),
                      selected: isSelected,
                      selectedTileColor: Colors.blue.shade100,
                      onTap: () async {
                        setState(() {
                          _selectedUser = user.name;
                          _messages = [];
                        });
                        await _loadMessages();
                      },
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildMessageList() {
    if (_selectedUser == null) {
      return const Center(child: Text('Select a farmer to chat'));
    }

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          color: Colors.blueGrey.shade50,
          width: double.infinity,
          child: Text(
            'Chat with $_selectedUser',
            textAlign: TextAlign.center,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ),
        Expanded(
          child: ListView.builder(
            controller: _scrollController,
            itemCount: _messages.length,
            itemBuilder: (context, index) {
              final message = _messages[index];
              final isSentByAdmin = message.senderId == 'admin';

              return Align(
                alignment: isSentByAdmin ? Alignment.centerRight : Alignment.centerLeft,
                child: Container(
                  constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.7),
                  margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                  decoration: BoxDecoration(
                    color: isSentByAdmin ? Colors.blueAccent : Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        message.content,
                        style: TextStyle(color: isSentByAdmin ? Colors.white : Colors.black),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        DateFormat('hh:mm a').format(message.timestamp),
                        style: TextStyle(
                          fontSize: 10,
                          color: isSentByAdmin ? Colors.white70 : Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          color: Colors.grey.shade200,
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _messageController,
                  decoration: const InputDecoration(
                    hintText: 'Type your message...',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.send, color: Colors.blue),
                onPressed: _sendMessage,
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Admin Chat - Logged in as ${widget.farmerName}'),
      ),
      body: Row(
        children: [
          SizedBox(
            width: 250,
            child: _buildUserList(),
          ),
          const VerticalDivider(width: 1),
          Expanded(
            child: _buildMessageList(),
          ),
        ],
      ),
    );
  }
}
