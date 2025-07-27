// 🌍 Viewer app for Cross-Platform Unified Design Showcase
// Run this to see how the design adapts across different platforms

import 'package:flutter/material.dart';
import 'unified_cross_platform_design.dart';

void main() {
  runApp(const CrossPlatformDesignViewer());
}

class CrossPlatformDesignViewer extends StatelessWidget {
  const CrossPlatformDesignViewer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ERP Pro - Cross-Platform Design',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2B5CE6),
        ),
      ),
      home: const UnifiedCrossPlatformDashboard(),
    );
  }
}
