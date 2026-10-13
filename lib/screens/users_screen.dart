import 'package:flutter/material.dart';
import '../services/ws_service.dart';
import '../utils/theme.dart';

class UsersScreen extends StatefulWidget {
  final WsService ws;
  const UsersScreen({super.key, required this.ws});

  @override
  State<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen> {
  List<Map<String, dynamic>> _users = [];

  @override
  void initState() {
    super.initState();
    widget.ws.listUsers();
    widget.ws.messages.listen((msg) {
      if (!mounted) return;
      if (msg['type'] == 'users') {
        _users = List<Map<String, dynamic>>.from(msg['users'] ?? []);
        setState(() {});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Users'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add),
            onPressed: _addUser,
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: _users.length,
        itemBuilder: (_, i) {
          final u = _users[i];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: u['isAdmin']
                    ? AppTheme.primary
                    : Colors.grey[800],
                child: Text(
                  (u['username'] as String).substring(0, 1).toUpperCase(),
                  style: const TextStyle(color: Colors.white),
                ),
              ),
              title: Text(u['username']),
              subtitle: Text(u['isAdmin'] ? 'Administrator' : 'User'),
              trailing: u['username'] == 'admin'
                  ? const Icon(Icons.lock, color: Colors.grey)
                  : IconButton(
                      icon: const Icon(Icons.delete, color: AppTheme.danger),
                      onPressed: () =>
                          widget.ws.deleteUser(u['username']),
                    ),
            ),
          );
        },
      ),
    );
  }

  void _addUser() {
    final u = TextEditingController();
    final p = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Add User'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
                controller: u,
                decoration: const InputDecoration(labelText: 'Username')),
            TextField(
                controller: p,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Password')),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              widget.ws.addUser({
                'user': u.text,
                'pass': p.text,
                'isAdmin': false,
                'relayPerm': [true, true, true, true, true, true],
              });
              Navigator.pop(context);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
}