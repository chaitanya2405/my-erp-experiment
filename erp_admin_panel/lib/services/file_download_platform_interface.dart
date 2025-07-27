import 'dart:typed_data';

abstract class FileDownloadPlatform {
  Future<void> downloadFile(Uint8List bytes, String filename);
}
