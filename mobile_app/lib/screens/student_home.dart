import 'package:flutter/material.dart';
import 'package:mobile_app/services/api_service.dart';
import 'package:mobile_app/services/auth_storage.dart';

class StudentHome extends StatefulWidget {
  const StudentHome({super.key});
  @override
  State<StudentHome> createState() => _StudentHomeState();
}

class _StudentHomeState extends State<StudentHome> {
  int _index = 0;

  Future<void> _logout() async {
    await AuthStorage.clearToken();
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    final tabs = [
      const _DocumentsTab(),
      const _InboxTab(),
      const _AskTeacherTab(),
      const _ProfileTab(),
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
          NavigationDestination(icon: Icon(Icons.inbox_outlined), selectedIcon: Icon(Icons.inbox), label: 'Inbox'),
          NavigationDestination(icon: Icon(Icons.question_answer_outlined), selectedIcon: Icon(Icons.question_answer), label: 'Ask'),
          NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: 'Profil'),
        ],
      ),
    );
  }
}

// ── Documents Tab ────────────────────────────────────────────────────────────

class _DocumentsTab extends StatefulWidget {
  const _DocumentsTab();
  @override
  State<_DocumentsTab> createState() => _DocumentsTabState();
}

class _DocumentsTabState extends State<_DocumentsTab> {
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

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_error != null) return _ErrorView(_error!, _load);
    if (_docs.isEmpty) return const Center(child: Text('Aucun document disponible.'));
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
            subtitle: Text(
              doc['teacher_name'] != null
                  ? 'Enseignant : ${doc['teacher_name']}'
                  : 'Ajouté le ${doc['upload_date']}',
              style: const TextStyle(fontSize: 12),
            ),
          );
        },
      ),
    );
  }
}

// ── Inbox Tab ────────────────────────────────────────────────────────────────

class _InboxTab extends StatefulWidget {
  const _InboxTab();
  @override
  State<_InboxTab> createState() => _InboxTabState();
}

class _InboxTabState extends State<_InboxTab> {
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

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_error != null) return _ErrorView(_error!, _load);
    if (_msgs.isEmpty) return const Center(child: Text('Aucun message.'));
    return RefreshIndicator(
      onRefresh: _load,
      child: ListView.separated(
        padding: const EdgeInsets.all(12),
        itemCount: _msgs.length,
        separatorBuilder: (_, _) => const Divider(height: 1),
        itemBuilder: (_, i) {
          final m = _msgs[i] as Map<String, dynamic>;
          final isPublic = m['type'] == 'public';
          return ListTile(
            leading: Icon(isPublic ? Icons.campaign : Icons.mail, color: isPublic ? Colors.orange : Colors.indigo),
            title: Text(m['content']?.toString() ?? ''),
            subtitle: Text(
              'De : ${m['sender_name'] ?? '?'}  •  ${m['timestamp'] ?? ''}',
              style: const TextStyle(fontSize: 11),
            ),
          );
        },
      ),
    );
  }
}

// ── Ask Teacher Tab ──────────────────────────────────────────────────────────

class _AskTeacherTab extends StatefulWidget {
  const _AskTeacherTab();
  @override
  State<_AskTeacherTab> createState() => _AskTeacherTabState();
}

class _AskTeacherTabState extends State<_AskTeacherTab> {
  bool _loading = true;
  String? _error;
  List<dynamic> _teachers = [];
  Map<String, dynamic>? _selected;
  final _msgCtrl = TextEditingController();
  bool _sending = false;

  @override
  void initState() { super.initState(); _loadTeachers(); }

  @override
  void dispose() { _msgCtrl.dispose(); super.dispose(); }

  Future<void> _loadTeachers() async {
    setState(() { _loading = true; _error = null; });
    try {
      final token = await AuthStorage.getToken();
      final result = await ApiService.fetchTeachers(token!);
      setState(() { _teachers = (result['teachers'] as List<dynamic>?) ?? []; });
    } catch (e) {
      setState(() { _error = e.toString(); });
    } finally {
      setState(() { _loading = false; });
    }
  }

  Future<void> _send() async {
    if (_selected == null || _msgCtrl.text.trim().isEmpty) return;
    setState(() { _sending = true; });
    try {
      final token = await AuthStorage.getToken();
      await ApiService.sendMessage(token!, _msgCtrl.text.trim(), _selected!['id'].toString(), 'private');
      _msgCtrl.clear();
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Message envoyé !')));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      setState(() { _sending = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_error != null) return _ErrorView(_error!, _loadTeachers);
    if (_teachers.isEmpty) return const Center(child: Text('Aucun enseignant disponible.'));
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Destinataire', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(border: Border.all(color: Colors.grey), borderRadius: BorderRadius.circular(4)),
            child: DropdownButton<Map<String, dynamic>>(
              value: _selected,
              isExpanded: true,
              hint: const Text('Choisir un enseignant'),
              underline: const SizedBox(),
              items: _teachers.map((t) {
                final teacher = t as Map<String, dynamic>;
                return DropdownMenuItem(value: teacher, child: Text(teacher['full_name']?.toString() ?? ''));
              }).toList(),
              onChanged: (v) => setState(() => _selected = v),
            ),
          ),
          const SizedBox(height: 16),
          const Text('Message', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          TextField(
            controller: _msgCtrl,
            maxLines: 5,
            decoration: const InputDecoration(border: OutlineInputBorder(), hintText: 'Votre question...'),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _sending ? null : _send,
              icon: _sending ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.send),
              label: const Text('Envoyer'),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Profile Tab ──────────────────────────────────────────────────────────────

class _ProfileTab extends StatefulWidget {
  const _ProfileTab();
  @override
  State<_ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<_ProfileTab> {
  final _nameCtrl  = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl  = TextEditingController();
  bool _loading = true;
  bool _saving  = false;
  String? _error;
  String? _success;
  Map<String, dynamic>? _user;

  @override
  void initState() { super.initState(); _load(); }

  @override
  void dispose() { _nameCtrl.dispose(); _emailCtrl.dispose(); _passCtrl.dispose(); super.dispose(); }

  Future<void> _load() async {
    setState(() { _loading = true; });
    _user = await AuthStorage.getUser();
    if (_user != null) {
      _nameCtrl.text  = _user!['name']?.toString() ?? '';
      _emailCtrl.text = _user!['email']?.toString() ?? '';
    }
    setState(() { _loading = false; });
  }

  Future<void> _save() async {
    setState(() { _saving = true; _error = null; _success = null; });
    try {
      final token = await AuthStorage.getToken();
      final result = await ApiService.updateProfile(
        token!, _nameCtrl.text.trim(), _emailCtrl.text.trim(),
        password: _passCtrl.text.isEmpty ? null : _passCtrl.text,
      );
      await AuthStorage.saveUser(result['user'] as Map<String, dynamic>);
      _passCtrl.clear();
      setState(() { _success = 'Profil mis à jour !'; });
    } catch (e) {
      setState(() { _error = e.toString(); });
    } finally {
      setState(() { _saving = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          CircleAvatar(radius: 36, child: Text((_nameCtrl.text.isNotEmpty ? _nameCtrl.text[0] : '?').toUpperCase(), style: const TextStyle(fontSize: 28))),
          const SizedBox(height: 8),
          Chip(label: Text(_user?['role']?.toString() ?? 'student')),
          const SizedBox(height: 24),
          TextField(controller: _nameCtrl, decoration: const InputDecoration(labelText: 'Nom complet', border: OutlineInputBorder())),
          const SizedBox(height: 12),
          TextField(controller: _emailCtrl, keyboardType: TextInputType.emailAddress, decoration: const InputDecoration(labelText: 'Email', border: OutlineInputBorder())),
          const SizedBox(height: 12),
          TextField(controller: _passCtrl, obscureText: true, decoration: const InputDecoration(labelText: 'Nouveau mot de passe (optionnel)', border: OutlineInputBorder())),
          const SizedBox(height: 20),
          if (_error != null) Padding(padding: const EdgeInsets.only(bottom: 12), child: Text(_error!, style: const TextStyle(color: Colors.red))),
          if (_success != null) Padding(padding: const EdgeInsets.only(bottom: 12), child: Text(_success!, style: const TextStyle(color: Colors.green))),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _saving ? null : _save,
              child: _saving ? const CircularProgressIndicator(color: Colors.white) : const Text('Enregistrer'),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Shared ───────────────────────────────────────────────────────────────────

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
