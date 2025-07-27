import 'dart:html' as html;
import 'dart:typed_data';
import 'file_download_platform_interface.dart';

class WebFileDownloader implements FileDownloadPlatform {
  @override
  Future<void> downloadFile(Uint8List bytes, String filename) async {
    final blob = html.Blob([bytes]);
    final url = html.Url.createObjectUrlFromBlob(blob);
    final anchor = html.AnchorElement(href: url)
      ..setAttribute('download', filename)
      ..click();
    html.Url.revokeObjectUrl(url);
  }
}

FileDownloadPlatform createFileDownloader() => WebFileDownloader();