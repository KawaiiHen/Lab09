import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'add_new_user.dart';

void main() {
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: MyApp(),
  ));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  List<Map<String, dynamic>> users = [];
  bool isLoading = true;
  Map<String, dynamic>? deletedUser;
  String? deletedUserId;

  Future<void> fetchUsers() async {
    try {
      final response = await http.get(Uri.parse('http://localhost:3000/users'));
      if (response.statusCode == 200) {
        setState(() {
          users = List<Map<String, dynamic>>.from(json.decode(response.body));
          isLoading = false;
        });
      } else {
        print('Failed to load users');
        setState(() => isLoading = false);
      }
    } catch (error) {
      print('Error fetching users: $error');
      setState(() => isLoading = false);
    }
  }

  @override
  void initState() {
    super.initState();
    fetchUsers();
  }

  void _addNewUser() async {
    final newUser = await Navigator.push(
      context,
      MaterialPageRoute(builder: (ctx) => const AddUserScreen()),
    );
    if (newUser != null) {
      setState(() => users.add(newUser));
    }
  }

  Future<void> deleteUser(String id) async {
    final userToDelete = users.firstWhere((user) => user['id'] == id);

    final response = await http.delete(Uri.parse('http://localhost:3000/users/$id'));

    if (response.statusCode == 200) {
      setState(() {
        users.removeWhere((user) => user['id'] == id);
        deletedUser = userToDelete;
        deletedUserId = id;
      });
      _showUndoSnackbar();
    } else {
      print('Failed to delete user with id: $id');
    }
  }

  void _showUndoSnackbar() {
    final snackBar = SnackBar(
      content: const Text('User deleted.'),
      action: SnackBarAction(
        label: 'Undo',
        onPressed: () {
          if (deletedUser != null) {
            _restoreUser(deletedUser!);
          }
        },
      ),
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  void _restoreUser(Map<String, dynamic> user) async {
    final response = await http.post(
      Uri.parse('http://localhost:3000/users'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(user),
    );

    if (response.statusCode == 201) {
      setState(() {
        users.add(json.decode(response.body));
        deletedUser = null;
        deletedUserId = null;
      });
    } else {
      print('Failed to restore user');
    }
  }

  Future<void> confirmDeleteUser(BuildContext context, String id) async {
    final bool? deleteConfirmed = await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete User?'),
        content: const Text('Are you sure you want to delete this user?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (deleteConfirmed == true) {
      await deleteUser(id);
    }
  }

  Widget _userToListItem(BuildContext context, int idx) {
    Map<String, dynamic> user = users[idx];

    return ListTile(
      enabled: !user['blocked'],
      leading: CircleAvatar(
        radius: 32,
        backgroundImage: CachedNetworkImageProvider(user['img']),
        onBackgroundImageError: (_, __) => print('Failed to load image at ${user['img']}'), // Error handler
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            user['favorited'] ? Icons.favorite : null,
            color: Colors.pink,
          ),
          PopupMenuButton(
            padding: EdgeInsets.zero,
            itemBuilder: (context) => [
              PopupMenuItem(
                padding: EdgeInsets.zero,
                child: ListTile(
                  title: Text(user['favorited'] ? 'Remove from favorites' : 'Add to favorites'),
                  leading: const Icon(Icons.favorite),
                  onTap: () {
                    Navigator.pop(context);
                    setState(() {
                      user['favorited'] = !user['favorited'];
                    });
                  },
                ),
              ),
              PopupMenuItem(
                padding: EdgeInsets.zero,
                child: ListTile(
                  title: Text(user['blocked'] ? 'Unblock user' : 'Block user'),
                  leading: const Icon(Icons.block),
                  onTap: () {
                    Navigator.pop(context);
                    setState(() {
                      user['blocked'] = !user['blocked'];
                    });
                  },
                ),
              ),
              PopupMenuItem(
                padding: EdgeInsets.zero,
                child: ListTile(
                  title: const Text('Delete User'),
                  leading: const Icon(Icons.delete),
                  onTap: () async {
                    Navigator.pop(context);
                    await confirmDeleteUser(context, user['id']);
                  },
                ),
              ),
            ],
          ),
        ],
      ),
      title: Text(user['fullName']),
      subtitle: Text(user['jobTitle']),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User List'),
        actions: [
          IconButton(
            onPressed: _addNewUser,
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: users.length,
              itemBuilder: _userToListItem,
            ),
    );
  }
}
