import 'package:flutter/material.dart';
import 'package:mobile_app/services/api_service.dart';
import 'package:mobile_app/services/auth_storage.dart';

class DocumentsScreen extends StatefulWidget {
  const DocumentsScreen({super.key});

  @override
  State<DocumentsScreen> createState() => _DocumentsScreenState();
}

class _DocumentsScreenState extends State<DocumentsScreen> {
  bool _loading = true;
  String? _error;
  List<dynamic> _documents = [];
  String? _role;

  @override
  void initState() {
    super.initState();
    _loadDocuments();
  }

  Future<void> _loadDocuments() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final token = await AuthStorage.getToken();
      _role = await AuthStorage.getUserRole();
      if (token == null) {
        _error = 'Missing token. Please login again.';
        return;
      }
      final result = await ApiService.fetchDocuments(token);
      setState(() {
        _documents = (result['documents'] as List<dynamic>?) ?? [];
      });
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

  Future<void> _logout() async {
    await AuthStorage.clearToken();
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Documents'),
        actions: [
          IconButton(onPressed: _logout, icon: const Icon(Icons.logout)),
        ],
      ),
      floatingActionButton: _role == 'teacher'
          ? FloatingActionButton(
              onPressed: () async {
                await Navigator.pushNamed(context, '/upload');
                _loadDocuments();
              },
              child: const Icon(Icons.upload_file),
            )
          : null,
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
            ? Center(
                child: Text(_error!, style: const TextStyle(color: Colors.red)),
              )
            : _documents.isEmpty
            ? const Center(child: Text('No documents yet.'))
            : ListView.separated(
                itemCount: _documents.length,
                separatorBuilder: (context, index) => const Divider(),
                itemBuilder: (context, index) {
                  final doc = _documents[index] as Map<String, dynamic>;
                  return ListTile(
                    title: Text(
                      doc['description']?.toString() ?? 'No description',
                    ),
                    subtitle: Text(
                      doc['teacher_name'] != null
                          ? 'Teacher: ${doc['teacher_name']}'
                          : 'Uploaded: ${doc['upload_date']}',
                    ),
                    trailing: const Icon(Icons.file_present),
                  );
                },
              ),
      ),
    );
  }
}
