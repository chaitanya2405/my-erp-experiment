import 'dart:typed_data';
import 'file_download_desktop_impl.dart' if (dart.library.html) 'file_download_web_impl.dart';

Future<void> downloadFilePlatform(Uint8List bytes, String filename) async {
  if (identical(0, 0.0)) {
    // Web platform - use web implementation
    throw UnimplementedError('Web implementation not yet available');
  } else {
    // Desktop platform
    await FileDownloadDesktopImpl.downloadFile(filename, bytes);
  }
}
