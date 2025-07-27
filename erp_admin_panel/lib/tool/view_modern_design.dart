// 🎨 Standalone app to view the Modern UI Design Showcase
// Run this file to see the beautiful modern design sample in Chrome

import 'package:flutter/material.dart';
import 'modern_ui_design_showcase.dart';

void main() {
  runApp(const ModernDesignViewerApp());
}

class ModernDesignViewerApp extends StatelessWidget {
  const ModernDesignViewerApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Modern ERP Design Showcase',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Roboto',
        useMaterial3: true,
      ),
      home: const UltraModernDashboard(),
    );
  }
}
