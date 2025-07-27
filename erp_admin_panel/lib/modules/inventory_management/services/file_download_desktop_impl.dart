import 'dart:io';
import 'dart:typed_data';

class FileDownloadDesktopImpl {
  static Future<void> downloadFile(String filename, Uint8List bytes) async {
    try {
      // For web platform, this won't be called
      // For desktop platforms, save to downloads folder
      final downloadsDir = Directory('${Platform.environment['HOME']}/Downloads');
      if (!downloadsDir.existsSync()) {
        downloadsDir.createSync(recursive: true);
      }
      
      final file = File('${downloadsDir.path}/$filename');
      await file.writeAsBytes(bytes);
      print('File downloaded to: ${file.path}');
    } catch (e) {
      print('Error downloading file: $e');
      throw Exception('Failed to download file: $e');
    }
  }
}
