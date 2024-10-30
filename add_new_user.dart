import 'package:flutter/material.dart';

class AddUserScreen extends StatefulWidget {
  const AddUserScreen({super.key});

  @override
  State<AddUserScreen> createState() => _AddUserScreen();
}

const space = SizedBox(
  height: 16,
);

class _AddUserScreen extends State<AddUserScreen> {
  var _form = GlobalKey<FormState>();
  String fullName = '', jobTitle = '';

  void _submitForm() {
    if (_form.currentState?.validate() ?? false) {
      _form.currentState?.save();
      print(fullName);
      print(jobTitle);
    } else {
      print('Invalid form');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create a new User')),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(30),
          child: Form(
            key: _form,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: Column(children: [
              SizedBox(
                height: 16,
              ),
              Text(
                'User Information',
                style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue),
              ),
              SizedBox(
                height: 36,
              ),
              TextFormField(
                autofocus: true,
                keyboardType: TextInputType.name,
                onSaved: (v) => fullName = v ?? '',
                validator: (v) {
                  if (v?.trim().isEmpty ?? true) {
                    return 'Please enter full name';
                  } else if (v!.length < 6) {
                    return 'User name is too short';
                  }
                  return null;
                },
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.account_box),
                  border: OutlineInputBorder(),
                  hintText: 'Enter your user name',
                  label: Text('Full Name'),
                ),
              ),
              space,
              TextFormField(
                onSaved: (v) => jobTitle = v ?? '',
                validator: (v) {
                  if (v?.trim().isEmpty ?? true) {
                    return 'Please enter job title';
                  } else if (v!.length < 4) {
                    return 'Job title is too short';
                  }
                  return null;
                },
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.title),
                  border: OutlineInputBorder(),
                  hintText: 'Enter job title',
                  label: Text('Job Title'),
                ),
              ),
              space,
              ElevatedButton(
                style:
                    ElevatedButton.styleFrom(minimumSize: Size.fromHeight(50)),
                onPressed: _submitForm,
                child: Text(
                  'Register',
                  style: TextStyle(fontSize: 18),
                ),
              )
            ]),
          ),
        ),
      ),
    );
  }
}
