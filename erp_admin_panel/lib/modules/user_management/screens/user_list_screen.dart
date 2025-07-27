import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/user_profile.dart';
import 'user_form_screen.dart';
/// User List Screen: View, search, filter, and manage users
class UserListScreen extends StatefulWidget {
  final bool showAppBar;
  const UserListScreen({Key? key, this.showAppBar = true}) : super(key: key);

  @override
  State<UserListScreen> createState() => _UserListScreenState();
}

class _UserListScreenState extends State<UserListScreen> {
  String _search = '';

  void _openUserForm({UserProfile? user}) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => UserFormScreen(
          showAppBar: true,
          user: user,
        ),
      ),
    );
    setState(() {}); // Refresh after add/edit
  }

  @override
  Widget build(BuildContext context) {
    final body = Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: TextField(
            decoration: const InputDecoration(
              hintText: 'Search users by name, email, or role...',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(),
            ),
            onChanged: (val) => setState(() => _search = val.trim().toLowerCase()),
          ),
        ),
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('users').snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Center(child: Text('No users found.'));
              }
              final users = snapshot.data!.docs
                  .map((doc) => UserProfile.fromMap(doc.data() as Map<String, dynamic>, doc.id))
                  .where((user) {
                    if (_search.isEmpty) return true;
                    return user.displayName.toLowerCase().contains(_search) ||
                        user.email.toLowerCase().contains(_search) ||
                        (user.role ?? '').toLowerCase().contains(_search);
                  })
                  .toList();
              if (users.isEmpty) {
                return const Center(child: Text('No users match your search.'));
              }
              return ListView.separated(
                itemCount: users.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, i) {
                  final user = users[i];
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundImage: user.photoUrl != null ? NetworkImage(user.photoUrl!) : null,
                      child: user.photoUrl == null ? Icon(Icons.person) : null,
                    ),
                    title: Text(user.displayName),
                    subtitle: Text('${user.email}\nRole: ${user.role ?? user.roles.join(", ")}'),
                    isThreeLine: true,
                    trailing: Icon(user.isActive ? Icons.check_circle : Icons.cancel, color: user.isActive ? Colors.green : Colors.red),
                    onTap: () {
                      _openUserForm(user: user);
                    },
                  );
                },
              );
            },
          ),
        ),
      ],
    );
    if (widget.showAppBar) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('User Management'),
          actions: [
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () {
                _openUserForm();
              },
            ),
          ],
        ),
        body: body,
      );
    } else {
      return body;
    }
  }
}
