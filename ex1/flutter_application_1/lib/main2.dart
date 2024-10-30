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
  Map<String, dynamic>? deletedUser; // Variable to hold the deleted user
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
    final userToDelete = users.firstWhere(
        (user) => user['id'] == id); // Get user data before deletion

    final response =
        await http.delete(Uri.parse('http://localhost:3000/users/$id'));

    if (response.statusCode == 200) {
      setState(() {
        users.removeWhere((user) => user['id'] == id);
        deletedUser = userToDelete; // Store the deleted user data
        deletedUserId = id; // Store the ID of the deleted user
      });
      _showUndoSnackbar(); // Show Snackbar for undo action
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
            _restoreUser(deletedUser!); // Restore the deleted user
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
      body: json.encode(user), // Use the deleted user's data
    );

    if (response.statusCode == 201) {
      setState(() {
        users.add(json.decode(response.body));
        deletedUser = null; // Clear deleted user data after restoration
        deletedUserId = null; // Clear deleted user ID after restoration
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
      await deleteUser(id); // Call delete user function
    }
  }

  Widget _userToListItem(BuildContext context, int idx) {
    Map<String, dynamic> user = users[idx];
    return ListTile(
      enabled: !user['blocked'],
      leading: CircleAvatar(
        radius: 32,
        backgroundImage: CachedNetworkImageProvider(user['img']),
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
            itemBuilder: ((context) => [
                  PopupMenuItem(
                    padding: EdgeInsets.zero,
                    child: ListTile(
                      title: Text(user['favorited']
                          ? 'Remove from favorite'
                          : 'Add to favorite'),
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
                      title: Text(user['blocked']
                          ? 'Unblock this user'
                          : 'Block this user'),
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
                      title: const Text('Delete this user'),
                      leading: const Icon(Icons.delete),
                      onTap: () {
                        Navigator.pop(context);
                        confirmDeleteUser(context, user['id']);
                      },
                    ),
                  )
                ]),
          )
        ],
      ),
      title: Text(user['fullName']),
      subtitle: Text(user['jobTitle']),
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("You've clicked on ${users[idx]['fullName']}"),
            action: SnackBarAction(
              label: 'Dismiss',
              onPressed: () => {},
              textColor: Colors.amber,
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Management App'),
        actions: [
          IconButton(onPressed: _addNewUser, icon: const Icon(Icons.add))
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.separated(
              itemBuilder: (context, index) {
                final user = users[index];
                return ListTile(
                  title: Text(user['fullName']),
                  subtitle: Text(user['jobTitle']),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () => confirmDeleteUser(context, user['id']),
                  ),
                );
              },
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemCount: users.length,
            ),
    );
  }
}
