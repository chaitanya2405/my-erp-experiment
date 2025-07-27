import 'dart:typed_data';
import 'file_download_implementation.dart';

class FileDownloadService {
  static Future<void> downloadFile(Uint8List bytes, String filename) async {
    await downloadFilePlatform(bytes, filename);
  }
}
