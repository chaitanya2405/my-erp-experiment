import 'package:flutter/material.dart';

class AdminMockDataWidget extends StatefulWidget {
  const AdminMockDataWidget({Key? key}) : super(key: key);

  @override
  State<AdminMockDataWidget> createState() => _AdminMockDataWidgetState();
}

class _AdminMockDataWidgetState extends State<AdminMockDataWidget> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Mock Data Generator'),
        backgroundColor: Colors.blue[600],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Mock Data Generator',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Generate mock data for testing purposes.',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isLoading ? null : _generateMockData,
              child: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Generate Mock Data'),
            ),
            const SizedBox(height: 16),
            if (_isLoading)
              const Text(
                'Generating mock data...',
                style: TextStyle(color: Colors.blue),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _generateMockData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Simulate mock data generation
      await Future.delayed(const Duration(seconds: 2));
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Mock data generated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error generating mock data: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}