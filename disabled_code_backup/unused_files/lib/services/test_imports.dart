import 'dart:typed_data';

void main() {
  print('Testing conditional imports...');
  
  // Test if dart:html is available
  try {
    // This should work on web
    final bytes = Uint8List.fromList([1, 2, 3, 4, 5]);
    print('Bytes created: ${bytes.length}');
  } catch (e) {
    print('Error: $e');
  }
}
