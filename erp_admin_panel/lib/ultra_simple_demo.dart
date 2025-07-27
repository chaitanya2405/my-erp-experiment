import 'package:flutter/material.dart';

/// 🎯 **Ultra Simple Business Template Demo**
/// 
/// A minimal demo showcasing professional business styling

void main() {
  runApp(const UltraSimpleDemo());
}

class UltraSimpleDemo extends StatelessWidget {
  const UltraSimpleDemo({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Business Template Demo',
      theme: _buildBusinessTheme(),
      home: const SimpleHome(),
      debugShowCheckedModeBanner: false,
    );
  }

  ThemeData _buildBusinessTheme() {
    const primaryBlue = Color(0xFF2563EB);
    const successGreen = Color(0xFF059669);
    const warningOrange = Color(0xFFF59E0B);
    const dangerRed = Color(0xFFDC2626);
    
    return ThemeData(
      primarySwatch: MaterialColor(0xFF2563EB, {
        50: primaryBlue.withOpacity(0.1),
        100: primaryBlue.withOpacity(0.2),
        200: primaryBlue.withOpacity(0.3),
        300: primaryBlue.withOpacity(0.4),
        400: primaryBlue.withOpacity(0.6),
        500: primaryBlue,
        600: const Color(0xFF1D4ED8),
        700: const Color(0xFF1E40AF),
        800: const Color(0xFF1E3A8A),
        900: const Color(0xFF1E3A8A),
      }),
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryBlue,
        brightness: Brightness.light,
      ),
      useMaterial3: true,
      fontFamily: 'Inter',
      appBarTheme: const AppBarTheme(
        backgroundColor: primaryBlue,
        foregroundColor: Colors.white,
        elevation: 2,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.all(8),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryBlue,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }
}

class SimpleHome extends StatelessWidget {
  const SimpleHome({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const primaryBlue = Color(0xFF2563EB);
    const successGreen = Color(0xFF059669);
    const warningOrange = Color(0xFFF59E0B);
    const dangerRed = Color(0xFFDC2626);
    
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Business Template Demo'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Icon(
                      Icons.business,
                      size: 64,
                      color: primaryBlue,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Business Template System',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: primaryBlue,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Enterprise-grade UI templates for your ERP system',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildStatChip('15+', 'Components', primaryBlue),
                        _buildStatChip('100+', 'Colors', successGreen),
                        _buildStatChip('All', 'Platforms', warningOrange),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Features Section
            const Text(
              'Key Features',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            Row(
              children: [
                Expanded(
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: primaryBlue.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.palette,
                              color: primaryBlue,
                              size: 32,
                            ),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Professional Design',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Carefully crafted color schemes and typography',
                            style: TextStyle(
                              color: Colors.grey[600],
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: successGreen.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.devices,
                              color: successGreen,
                              size: 32,
                            ),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Cross-Platform',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Works perfectly on Web, iOS, macOS, Android, Windows',
                            style: TextStyle(
                              color: Colors.grey[600],
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 32),
            
            // Color Palette
            const Text(
              'Professional Color Palette',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Row(
                      children: [
                        _buildColorSwatch('Primary Blue', primaryBlue),
                        const SizedBox(width: 12),
                        _buildColorSwatch('Success Green', successGreen),
                        const SizedBox(width: 12),
                        _buildColorSwatch('Warning Orange', warningOrange),
                        const SizedBox(width: 12),
                        _buildColorSwatch('Danger Red', dangerRed),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        _buildColorSwatch('Gray 100', const Color(0xFFF3F4F6)),
                        const SizedBox(width: 12),
                        _buildColorSwatch('Gray 300', const Color(0xFFD1D5DB)),
                        const SizedBox(width: 12),
                        _buildColorSwatch('Gray 500', const Color(0xFF6B7280)),
                        const SizedBox(width: 12),
                        _buildColorSwatch('Gray 900', const Color(0xFF111827)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Demo Cards
            const Text(
              'Component Examples',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: primaryBlue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.trending_up,
                        color: primaryBlue,
                        size: 32,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Business Card Component',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Professional card component with elevation, hover effects, and multiple variants',
                            style: TextStyle(
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 12),
                          ElevatedButton(
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Business template components ready to use!'),
                                ),
                              );
                            },
                            child: const Text('Try Component'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      _showInfoDialog(context, 'Integration Guide', 
                        'The business template system is located in:\n\n'
                        '📁 lib/business_template/\n\n'
                        'Key files:\n'
                        '• design_system/ - Colors, typography, spacing\n'
                        '• components/ - Business card components\n'
                        '• migration/ - Safe migration tools\n'
                        '• examples/ - Integration examples\n\n'
                        'See USAGE_GUIDE.md for detailed instructions.');
                    },
                    icon: const Icon(Icons.integration_instructions),
                    label: const Text('View Integration Guide'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      _showInfoDialog(context, 'Template Features',
                        '✅ Professional color palette (100+ colors)\n'
                        '✅ Typography hierarchy with responsive scaling\n'
                        '✅ Consistent spacing system\n'
                        '✅ Business card components\n'
                        '✅ Cross-platform optimization\n'
                        '✅ Light and dark themes\n'
                        '✅ Safe migration tools\n'
                        '✅ Zero disruption to existing code\n\n'
                        'Ready for enterprise use!');
                    },
                    icon: const Icon(Icons.checklist),
                    label: const Text('View Features'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatChip(String value, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: color,
              fontSize: 18,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: color.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildColorSwatch(String name, Color color) {
    return Expanded(
      child: Column(
        children: [
          Container(
            height: 50,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[300]!),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            name,
            style: const TextStyle(fontSize: 11),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _showInfoDialog(BuildContext context, String title, String content) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
