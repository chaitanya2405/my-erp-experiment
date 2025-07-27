// Web-specific file download implementation
import 'dart:html' as html;
import 'dart:typed_data';

Future<void> downloadFilePlatform(Uint8List bytes, String filename) async {
  // Create a blob and download it
  final blob = html.Blob([bytes]);
  final url = html.Url.createObjectUrlFromBlob(blob);
  final anchor = html.document.createElement('a') as html.AnchorElement
    ..href = url
    ..style.display = 'none'
    ..download = filename;
  html.document.body!.children.add(anchor);

  // Trigger download
  anchor.click();

  // Clean up
  html.document.body!.children.remove(anchor);
  html.Url.revokeObjectUrl(url);
}
