import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:mobile_app/services/api_service.dart';
import 'package:mobile_app/services/auth_storage.dart';

class UploadScreen extends StatefulWidget {
  const UploadScreen({super.key});

  @override
  State<UploadScreen> createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {
  final _descriptionController = TextEditingController();
  String? _filePath;
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.pickFiles();
    if (result == null || result.files.isEmpty) return;
    setState(() {
      _filePath = result.files.first.path;
    });
  }

  Future<void> _upload() async {
    if (_filePath == null) {
      setState(() {
        _error = 'Please choose a file first.';
      });
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final token = await AuthStorage.getToken();
      if (token == null) throw Exception('Token missing');
      await ApiService.uploadDocument(
        token,
        _descriptionController.text.trim(),
        _filePath!,
      );
      if (!mounted) return;
      Navigator.pop(context);
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Upload Document')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: 'Description'),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _pickFile,
              icon: const Icon(Icons.attach_file),
              label: const Text('Choose File'),
            ),
            const SizedBox(height: 8),
            Text(_filePath ?? 'No file selected.'),
            const Spacer(),
            if (_error != null) ...[
              Text(_error!, style: const TextStyle(color: Colors.red)),
              const SizedBox(height: 12),
            ],
            ElevatedButton(
              onPressed: _loading ? null : _upload,
              child: _loading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Upload'),
            ),
          ],
        ),
      ),
    );
  }
}
