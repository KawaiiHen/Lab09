import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AddUserScreen extends StatefulWidget {
  const AddUserScreen({super.key});

  @override
  State<AddUserScreen> createState() => _AddUserScreen();
}

const space = SizedBox(height: 16);

class _AddUserScreen extends State<AddUserScreen> {
  final _form = GlobalKey<FormState>();
  String fullName = '', jobTitle = '';

  Future<void> addUser() async {
    // Generate a unique integer ID based on the current timestamp.
    final uniqueId = DateTime.now().millisecondsSinceEpoch.toString();

    // Generate a random number for the image (this will give varied images from randomuser.me).
    final randomImgId = (DateTime.now().millisecondsSinceEpoch % 100).toString();

    // Set up the user data, including default values for 'favorited' and 'blocked'.
    final newUser = {
      'id': uniqueId,
      'fullName': fullName,
      'jobTitle': jobTitle,
      'img': 'https://randomuser.me/api/portraits/men/$randomImgId.jpg', // Random image
      'favorited': false,
      'blocked': false,
    };

    print("User image URL: ${newUser['img']}"); // Log image URL for verification

    // Send the data to the server.
    final response = await http.post(
      Uri.parse('http://localhost:3000/users'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(newUser),
    );

    if (response.statusCode == 201) {
      Navigator.pop(context, json.decode(response.body));
    } else {
      print('Failed to add user');
    }
  }

  void _submitForm() {
    if (_form.currentState?.validate() ?? false) {
      _form.currentState?.save();
      addUser();
    } else {
      print('Invalid form');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create a New User')),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(30),
          child: Form(
            key: _form,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: Column(
              children: [
                const SizedBox(height: 16),
                const Text(
                  'User Information',
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.blue),
                ),
                const SizedBox(height: 36),
                TextFormField(
                  autofocus: true,
                  keyboardType: TextInputType.name,
                  onSaved: (v) => fullName = v ?? '',
                  validator: (v) {
                    if (v?.trim().isEmpty ?? true) return 'Please enter full name';
                    if (v!.length < 6) return 'User name is too short';
                    return null;
                  },
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.account_box),
                    border: OutlineInputBorder(),
                    hintText: 'Enter your user name',
                    labelText: 'Full Name',
                  ),
                ),
                space,
                TextFormField(
                  onSaved: (v) => jobTitle = v ?? '',
                  validator: (v) {
                    if (v?.trim().isEmpty ?? true) return 'Please enter job title';
                    if (v!.length < 4) return 'Job title is too short';
                    return null;
                  },
                  keyboardType: TextInputType.text,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.title),
                    border: OutlineInputBorder(),
                    hintText: 'Enter job title',
                    labelText: 'Job Title',
                  ),
                ),
                space,
                ElevatedButton(
                  style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(50)),
                  onPressed: _submitForm,
                  child: const Text('Register', style: TextStyle(fontSize: 18)),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
