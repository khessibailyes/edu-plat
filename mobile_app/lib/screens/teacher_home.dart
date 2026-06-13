import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:mobile_app/services/api_service.dart';
import 'package:mobile_app/services/auth_storage.dart';

class TeacherHome extends StatefulWidget {
  const TeacherHome({super.key});
  @override
  State<TeacherHome> createState() => _TeacherHomeState();
}

class _TeacherHomeState extends State<TeacherHome> {
  int _index = 0;

  Future<void> _logout() async {
    await AuthStorage.clearToken();
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    final tabs = [
      const _MyDocumentsTab(),
      const _UploadTab(),
      const _QATab(),
    ];
    return Scaffold(
      appBar: AppBar(
        title: const Text('EduPlatform'),
        actions: [IconButton(onPressed: _logout, icon: const Icon(Icons.logout))],
      ),
      body: IndexedStack(index: _index, children: tabs),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.folder_outlined), selectedIcon: Icon(Icons.folder), label: 'Documents'),
          NavigationDestination(icon: Icon(Icons.upload_file_outlined), selectedIcon: Icon(Icons.upload_file), label: 'Upload'),
          NavigationDestination(icon: Icon(Icons.forum_outlined), selectedIcon: Icon(Icons.forum), label: 'Q&A'),
        ],
      ),
    );
  }
}

// ── My Documents Tab ─────────────────────────────────────────────────────────

class _MyDocumentsTab extends StatefulWidget {
  const _MyDocumentsTab();
  @override
  State<_MyDocumentsTab> createState() => _MyDocumentsTabState();
}

class _MyDocumentsTabState extends State<_MyDocumentsTab> {
  bool _loading = true;
  String? _error;
  List<dynamic> _docs = [];

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      final token = await AuthStorage.getToken();
      final result = await ApiService.fetchDocuments(token!);
      setState(() { _docs = (result['documents'] as List<dynamic>?) ?? []; });
    } catch (e) {
      setState(() { _error = e.toString(); });
    } finally {
      setState(() { _loading = false; });
    }
  }

  Future<void> _delete(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Supprimer'),
        content: const Text('Supprimer ce document ?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Annuler')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Supprimer', style: TextStyle(color: Colors.red))),
        ],
      ),
    );
    if (confirm != true) return;
    try {
      final token = await AuthStorage.getToken();
      await ApiService.deleteDocument(token!, id);
      _load();
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_error != null) return _ErrorView(_error!, _load);
    if (_docs.isEmpty) return const Center(child: Text('Vous n\'avez pas encore uploadé de document.'));
    return RefreshIndicator(
      onRefresh: _load,
      child: ListView.separated(
        padding: const EdgeInsets.all(12),
        itemCount: _docs.length,
        separatorBuilder: (_, _) => const Divider(height: 1),
        itemBuilder: (_, i) {
          final doc = _docs[i] as Map<String, dynamic>;
          return ListTile(
            leading: const Icon(Icons.file_present, color: Colors.indigo),
            title: Text(doc['description']?.toString() ?? 'Sans description'),
            subtitle: Text(doc['upload_date']?.toString() ?? '', style: const TextStyle(fontSize: 12)),
            trailing: IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              onPressed: () => _delete(int.tryParse(doc['id'].toString()) ?? 0),
            ),
          );
        },
      ),
    );
  }
}

// ── Upload Tab ───────────────────────────────────────────────────────────────

class _UploadTab extends StatefulWidget {
  const _UploadTab();
  @override
  State<_UploadTab> createState() => _UploadTabState();
}

class _UploadTabState extends State<_UploadTab> {
  final _descCtrl = TextEditingController();
  String? _filePath;
  String? _fileName;
  bool _uploading = false;
  String? _error;

  @override
  void dispose() { _descCtrl.dispose(); super.dispose(); }

  Future<void> _pickFile() async {
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx', 'ppt', 'pptx', 'txt', 'zip'],
    );
    if (result != null && result.files.single.path != null) {
      setState(() {
        _filePath = result.files.single.path;
        _fileName = result.files.single.name;
      });
    }
  }

  Future<void> _upload() async {
    if (_filePath == null) { setState(() { _error = 'Sélectionnez un fichier.'; }); return; }
    setState(() { _uploading = true; _error = null; });
    try {
      final token = await AuthStorage.getToken();
      await ApiService.uploadDocument(token!, _descCtrl.text.trim(), _filePath!);
      setState(() { _filePath = null; _fileName = null; });
      _descCtrl.clear();
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Document uploadé avec succès !')));
    } catch (e) {
      setState(() { _error = e.toString(); });
    } finally {
      setState(() { _uploading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Nouveau document', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          TextField(
            controller: _descCtrl,
            maxLines: 3,
            decoration: const InputDecoration(labelText: 'Description', border: OutlineInputBorder()),
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: _pickFile,
            icon: const Icon(Icons.attach_file),
            label: Text(_fileName ?? 'Choisir un fichier'),
          ),
          const SizedBox(height: 8),
          const Text('PDF, DOC, DOCX, PPT, TXT, ZIP — max 10 Mo', style: TextStyle(fontSize: 11, color: Colors.grey)),
          const SizedBox(height: 20),
          if (_error != null) Padding(padding: const EdgeInsets.only(bottom: 12), child: Text(_error!, style: const TextStyle(color: Colors.red))),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _uploading ? null : _upload,
              icon: _uploading ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.cloud_upload),
              label: const Text('Uploader'),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Q&A Tab ───────────────────────────────────────────────────────────────────

class _QATab extends StatefulWidget {
  const _QATab();
  @override
  State<_QATab> createState() => _QATabState();
}

class _QATabState extends State<_QATab> {
  bool _loading = true;
  String? _error;
  List<dynamic> _msgs = [];

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      final token = await AuthStorage.getToken();
      final result = await ApiService.fetchMessages(token!);
      setState(() { _msgs = (result['messages'] as List<dynamic>?) ?? []; });
    } catch (e) {
      setState(() { _error = e.toString(); });
    } finally {
      setState(() { _loading = false; });
    }
  }

  void _showReply(Map<String, dynamic> msg) {
    final ctrl = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => Padding(
        padding: EdgeInsets.fromLTRB(16, 16, 16, MediaQuery.of(context).viewInsets.bottom + 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Répondre à ${msg['sender_name'] ?? '?'}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 12),
            TextField(controller: ctrl, maxLines: 4, autofocus: true, decoration: const InputDecoration(border: OutlineInputBorder(), hintText: 'Votre réponse...')),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  if (ctrl.text.trim().isEmpty) return;
                  Navigator.pop(context);
                  final token = await AuthStorage.getToken();
                  try {
                    await ApiService.sendMessage(token!, ctrl.text.trim(), msg['sender_id'].toString(), 'private');
                    if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Réponse envoyée !')));
                  } catch (e) {
                    if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
                  }
                },
                child: const Text('Envoyer la réponse'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_error != null) return _ErrorView(_error!, _load);
    if (_msgs.isEmpty) return const Center(child: Text('Aucune question reçue.'));
    return RefreshIndicator(
      onRefresh: _load,
      child: ListView.separated(
        padding: const EdgeInsets.all(12),
        itemCount: _msgs.length,
        separatorBuilder: (_, _) => const Divider(height: 1),
        itemBuilder: (_, i) {
          final m = _msgs[i] as Map<String, dynamic>;
          return ListTile(
            leading: const Icon(Icons.person, color: Colors.indigo),
            title: Text(m['content']?.toString() ?? ''),
            subtitle: Text('${m['sender_name'] ?? '?'}  •  ${m['timestamp'] ?? ''}', style: const TextStyle(fontSize: 11)),
            trailing: TextButton(onPressed: () => _showReply(m), child: const Text('Répondre')),
          );
        },
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorView(this.message, this.onRetry);

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Text(message, style: const TextStyle(color: Colors.red), textAlign: TextAlign.center),
        const SizedBox(height: 12),
        ElevatedButton(onPressed: onRetry, child: const Text('Réessayer')),
      ]),
    ),
  );
}
