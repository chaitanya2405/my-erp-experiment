import 'package:flutter/material.dart';

/// 🎯 **Demo Launcher - Placeholder**
/// 
/// Business template demos have been moved to disabled_code_backup
/// This is a placeholder to prevent import errors

void main() {
  runApp(const DemoLauncherPlaceholder());
}

class DemoLauncherPlaceholder extends StatelessWidget {
  const DemoLauncherPlaceholder({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Demo Launcher - Disabled',
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Demo Launcher'),
          backgroundColor: Colors.grey,
        ),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.info_outline,
                size: 64,
                color: Colors.grey,
              ),
              SizedBox(height: 16),
              Text(
                'Demo Launcher Disabled',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Business template demos have been moved to\ndisabled_code_backup to reduce compilation errors.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
