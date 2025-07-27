import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

class PoDocumentUpload extends StatefulWidget {
  final String poId; // Pass the PO ID to organize uploads
  final Function(List<String> urls)? onUploadComplete;

  const PoDocumentUpload({Key? key, required this.poId, this.onUploadComplete}) : super(key: key);

  @override
  State<PoDocumentUpload> createState() => _PoDocumentUploadState();
}

class _PoDocumentUploadState extends State<PoDocumentUpload> {
  List<PlatformFile> _files = [];
  List<String> _uploadedUrls = [];
  bool _uploading = false;

  Future<void> _pickFiles() async {
    final result = await FilePicker.platform.pickFiles(allowMultiple: true);
    if (result != null) {
      setState(() {
        _files.addAll(result.files.where((f) => !_files.any((e) => e.name == f.name)));
      });
    }
  }

  Future<void> _uploadFiles() async {
    setState(() => _uploading = true);
    List<String> urls = [];
    for (final file in _files) {
      final ref = FirebaseStorage.instance
          .ref('purchase_orders/${widget.poId}/${file.name}');
      final uploadTask = await ref.putData(file.bytes!);
      final url = await uploadTask.ref.getDownloadURL();
      urls.add(url);
    }
    setState(() {
      _uploadedUrls = urls;
      _uploading = false;
    });
    widget.onUploadComplete?.call(urls);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Documents uploaded!')),
    );
  }

  void _removeFile(PlatformFile file) {
    setState(() {
      _files.remove(file);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ElevatedButton.icon(
          onPressed: _pickFiles,
          icon: const Icon(Icons.attach_file),
          label: const Text('Attach Documents'),
        ),
        const SizedBox(height: 12),
        if (_files.isNotEmpty)
          ..._files.map((file) => ListTile(
                leading: const Icon(Icons.insert_drive_file),
                title: Text(file.name),
                subtitle: Text('${(file.size / 1024).toStringAsFixed(1)} KB'),
                trailing: IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () => _removeFile(file),
                ),
              )),
        if (_files.isEmpty)
          const Text('No documents attached.'),
        const SizedBox(height: 12),
        if (_files.isNotEmpty)
          ElevatedButton.icon(
            onPressed: _uploading ? null : _uploadFiles,
            icon: const Icon(Icons.cloud_upload),
            label: Text(_uploading ? 'Uploading...' : 'Upload Documents'),
          ),
        if (_uploadedUrls.isNotEmpty)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),
              const Text('Uploaded Documents:', style: TextStyle(fontWeight: FontWeight.bold)),
              ..._uploadedUrls.map((url) => InkWell(
                    child: Text(url, style: const TextStyle(color: Colors.blue, decoration: TextDecoration.underline)),
                    onTap: () {
                      // Optionally open the URL
                    },
                  )),
            ],
          ),
      ],
    );
  }
}
