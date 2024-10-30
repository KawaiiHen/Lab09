import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
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
  List<Map<String, dynamic>> users = [
    {
      "id": 1,
      "fullName": "John Doe",
      "jobTitle": "Software Engineer",
      'img': 'https://randomuser.me/api/portraits/men/1.jpg',
      'favorited': false,
      'blocked': false
    },
    {
      "id": 2,
      "fullName": "Jane Smith",
      "jobTitle": "Product Manager",
      'img': 'https://randomuser.me/api/portraits/men/2.jpg',
      'favorited': true,
      'blocked': false
    },
    {
      "id": 3,
      "fullName": "Michael Johnson",
      "jobTitle": "UX Designer",
      'img': 'https://randomuser.me/api/portraits/men/3.jpg',
      'favorited': false,
      'blocked': true
    },
    {
      "id": 4,
      "fullName": "Sarah Lee",
      "jobTitle": "Data Scientist",
      'img': 'https://randomuser.me/api/portraits/men/4.jpg',
      'favorited': false,
      'blocked': false
    },
    {
      "id": 5,
      "fullName": "David Brown",
      "jobTitle": "DevOps Engineer",
      'img': 'https://randomuser.me/api/portraits/men/5.jpg',
      'favorited': false,
      'blocked': false
    },
    {
      "id": 6,
      "fullName": "Emily Davis",
      "jobTitle": "Quality Assurance Analyst",
      'img': 'https://randomuser.me/api/portraits/men/6.jpg',
      'favorited': true,
      'blocked': false
    },
    {
      "id": 7,
      "fullName": "William Garcia",
      "jobTitle": "Front-end Developer",
      'img': 'https://randomuser.me/api/portraits/men/7.jpg',
      'favorited': false,
      'blocked': true
    },
    {
      "id": 8,
      "fullName": "Ashley Rodriguez",
      "jobTitle": "Business Analyst",
      'img': 'https://randomuser.me/api/portraits/men/8.jpg',
      'favorited': false,
      'blocked': true
    },
    {
      "id": 9,
      "fullName": "Matthew Wilson",
      "jobTitle": "Full-stack Developer",
      'img': 'https://randomuser.me/api/portraits/men/9.jpg',
      'favorited': false,
      'blocked': false
    },
    {
      "id": 10,
      "fullName": "Olivia Taylor",
      "jobTitle": "Project Manager",
      'img': 'https://randomuser.me/api/portraits/men/10.jpg',
      'favorited': false,
      'blocked': false
    },
    {
      "id": 11,
      "fullName": "James Anderson",
      "jobTitle": "Database Administrator",
      'img': 'https://randomuser.me/api/portraits/men/11.jpg',
      'favorited': false,
      'blocked': false
    },
    {
      "id": 12,
      "fullName": "Isabella Thomas",
      "jobTitle": "Data Analyst",
      'img': 'https://randomuser.me/api/portraits/men/12.jpg',
      'favorited': false,
      'blocked': false
    },
    {
      "id": 13,
      "fullName": "Alexander Jackson",
      "jobTitle": "Mobile Developer",
      'img': 'https://randomuser.me/api/portraits/men/13.jpg',
      'favorited': false,
      'blocked': false
    },
    {
      "id": 14,
      "fullName": "Ava Miller",
      "jobTitle": "Quality Engineer",
      'img': 'https://randomuser.me/api/portraits/men/14.jpg',
      'favorited': false,
      'blocked': false
    },
    {
      "id": 15,
      "fullName": "Ethan Davis",
      "jobTitle": "Systems Administrator",
      'img': 'https://randomuser.me/api/portraits/men/15.jpg',
      'favorited': false,
      'blocked': false
    }
  ];

  Widget _userToListItem(ct, idx) {
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
                        setState(() {
                          users.removeAt(idx);
                        });
                      },
                    ),
                  )
                ]),
          )
        ],
      ),
      title: Text(user['fullName']!),
      subtitle: Text(user['jobTitle']!),
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

  void _addNewUser() {
    Navigator.push(
        context, MaterialPageRoute(builder: (ctx) => AddUserScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Consume REST API'),
        actions: [IconButton(onPressed: _addNewUser, icon: Icon(Icons.add))],
      ),
      body: ListView.separated(
          itemBuilder: _userToListItem,
          separatorBuilder: (ct, idx) => const Divider(
                height: 1,
              ),
          itemCount: users.length),
    );
  }
}
