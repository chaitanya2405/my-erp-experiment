import 'package:flutter/material.dart';

class RoleMatrixScreen extends StatelessWidget {
  final bool showAppBar;
  
  const RoleMatrixScreen({Key? key, this.showAppBar = true}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: showAppBar ? AppBar(
        title: const Text('Role Matrix'),
      ) : null,
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.security, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Role Matrix Management',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'Manage user roles and permissions',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
