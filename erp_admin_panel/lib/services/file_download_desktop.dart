import 'dart:io';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';
import 'file_download_platform_interface.dart';

class DesktopFileDownloader implements FileDownloadPlatform {
  @override
  Future<void> downloadFile(Uint8List bytes, String filename) async {
    try {
      // Get the downloads directory
      Directory? downloadsDir;
      
      if (Platform.isMacOS || Platform.isLinux || Platform.isWindows) {
        // For desktop platforms, use the downloads directory
        downloadsDir = await getDownloadsDirectory();
        
        // If getDownloadsDirectory() doesn't work, fall back to documents directory
        if (downloadsDir == null) {
          downloadsDir = await getApplicationDocumentsDirectory();
        }
      } else {
        // For other platforms, use documents directory
        downloadsDir = await getApplicationDocumentsDirectory();
      }
      
      final file = File('${downloadsDir.path}/$filename');
      await file.writeAsBytes(bytes);
      
      print('File saved to: ${file.path}');
    } catch (e) {
      print('Error saving file: $e');
      rethrow;
    }
  }
}

FileDownloadPlatform createFileDownloader() => DesktopFileDownloader();