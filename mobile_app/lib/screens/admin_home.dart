import 'package:flutter/material.dart';
import 'package:mobile_app/services/api_service.dart';
import 'package:mobile_app/services/auth_storage.dart';

class AdminHome extends StatefulWidget {
  const AdminHome({super.key});
  @override
  State<AdminHome> createState() => _AdminHomeState();
}

class _AdminHomeState extends State<AdminHome> {
  int _index = 0;

  Future<void> _logout() async {
    await AuthStorage.clearToken();
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    final tabs = [
      const _StatsTab(),
      const _UsersTab(),
      const _ProductsTab(),
      const _BroadcastTab(),
    ];
    return Scaffold(
      appBar: AppBar(
        title: const Text('EduPlatform — Admin'),
        actions: [IconButton(onPressed: _logout, icon: const Icon(Icons.logout))],
      ),
      body: IndexedStack(index: _index, children: tabs),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.bar_chart_outlined), selectedIcon: Icon(Icons.bar_chart), label: 'Stats'),
          NavigationDestination(icon: Icon(Icons.people_outline), selectedIcon: Icon(Icons.people), label: 'Utilisateurs'),
          NavigationDestination(icon: Icon(Icons.shopping_bag_outlined), selectedIcon: Icon(Icons.shopping_bag), label: 'Produits'),
          NavigationDestination(icon: Icon(Icons.campaign_outlined), selectedIcon: Icon(Icons.campaign), label: 'Broadcast'),
        ],
      ),
    );
  }
}

// ── Stats Tab ────────────────────────────────────────────────────────────────

class _StatsTab extends StatefulWidget {
  const _StatsTab();
  @override
  State<_StatsTab> createState() => _StatsTabState();
}

class _StatsTabState extends State<_StatsTab> {
  bool _loading = true;
  String? _error;
  Map<String, dynamic>? _stats;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      final token = await AuthStorage.getToken();
      final result = await ApiService.fetchStats(token!);
      setState(() { _stats = result; });
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
    final s = _stats!;
    return RefreshIndicator(
      onRefresh: _load,
      child: GridView.count(
        crossAxisCount: 2,
        padding: const EdgeInsets.all(16),
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        children: [
          _StatCard('Utilisateurs', s['total_users'].toString(), Icons.people, Colors.indigo),
          _StatCard('Enseignants', s['total_teachers'].toString(), Icons.school, Colors.teal),
          _StatCard('Étudiants', s['total_students'].toString(), Icons.person, Colors.blue),
          _StatCard('Documents', s['total_documents'].toString(), Icons.folder, Colors.orange),
          _StatCard('Messages', s['total_messages'].toString(), Icons.message, Colors.purple),
          _StatCard('Produits', s['total_products'].toString(), Icons.shopping_bag, Colors.green),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title, value;
  final IconData icon;
  final Color color;
  const _StatCard(this.title, this.value, this.icon, this.color);

  @override
  Widget build(BuildContext context) => Card(
    elevation: 2,
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(icon, size: 36, color: color),
        const SizedBox(height: 8),
        Text(value, style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: color)),
        const SizedBox(height: 4),
        Text(title, style: const TextStyle(color: Colors.grey, fontSize: 13)),
      ]),
    ),
  );
}

// ── Users Tab ────────────────────────────────────────────────────────────────

class _UsersTab extends StatefulWidget {
  const _UsersTab();
  @override
  State<_UsersTab> createState() => _UsersTabState();
}

class _UsersTabState extends State<_UsersTab> {
  bool _loading = true;
  String? _error;
  List<dynamic> _users = [];
  int? _myId;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      final token = await AuthStorage.getToken();
      final user = await AuthStorage.getUser();
      _myId = int.tryParse(user?['uid']?.toString() ?? '0');
      final result = await ApiService.fetchUsers(token!);
      setState(() { _users = (result['users'] as List<dynamic>?) ?? []; });
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
        title: const Text('Supprimer cet utilisateur ?'),
        content: const Text('Cette action est irréversible.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Annuler')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Supprimer', style: TextStyle(color: Colors.red))),
        ],
      ),
    );
    if (confirm != true) return;
    try {
      final token = await AuthStorage.getToken();
      await ApiService.deleteUser(token!, id);
      _load();
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  Color _roleColor(String? role) {
    switch (role) {
      case 'admin':   return Colors.red;
      case 'teacher': return Colors.teal;
      default:        return Colors.blue;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_error != null) return _ErrorView(_error!, _load);
    return RefreshIndicator(
      onRefresh: _load,
      child: ListView.separated(
        padding: const EdgeInsets.all(12),
        itemCount: _users.length,
        separatorBuilder: (_, _) => const Divider(height: 1),
        itemBuilder: (_, i) {
          final u = _users[i] as Map<String, dynamic>;
          final uid = int.tryParse(u['id'].toString()) ?? 0;
          return ListTile(
            leading: CircleAvatar(
              backgroundColor: _roleColor(u['role']?.toString()),
              child: Text((u['full_name']?.toString() ?? '?')[0].toUpperCase(), style: const TextStyle(color: Colors.white)),
            ),
            title: Text(u['full_name']?.toString() ?? ''),
            subtitle: Text(u['email']?.toString() ?? '', style: const TextStyle(fontSize: 12)),
            trailing: Row(mainAxisSize: MainAxisSize.min, children: [
              Chip(label: Text(u['role']?.toString() ?? ''), padding: EdgeInsets.zero, labelStyle: const TextStyle(fontSize: 11)),
              if (uid != _myId) IconButton(icon: const Icon(Icons.delete_outline, color: Colors.red), onPressed: () => _delete(uid)),
            ]),
          );
        },
      ),
    );
  }
}

// ── Products Tab ─────────────────────────────────────────────────────────────

class _ProductsTab extends StatefulWidget {
  const _ProductsTab();
  @override
  State<_ProductsTab> createState() => _ProductsTabState();
}

class _ProductsTabState extends State<_ProductsTab> {
  bool _loading = true;
  String? _error;
  List<dynamic> _products = [];

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      final token = await AuthStorage.getToken();
      final result = await ApiService.fetchProducts(token!);
      setState(() { _products = (result['products'] as List<dynamic>?) ?? []; });
    } catch (e) {
      setState(() { _error = e.toString(); });
    } finally {
      setState(() { _loading = false; });
    }
  }

  void _showAddDialog() {
    final nameCtrl  = TextEditingController();
    final priceCtrl = TextEditingController();
    final qtyCtrl   = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Nouveau produit'),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Nom')),
          TextField(controller: priceCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Prix')),
          TextField(controller: qtyCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Stock')),
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Annuler')),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              final token = await AuthStorage.getToken();
              try {
                await ApiService.addProduct(token!, nameCtrl.text.trim(), double.tryParse(priceCtrl.text) ?? 0, int.tryParse(qtyCtrl.text) ?? 0);
                _load();
              } catch (e) {
                if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
              }
            },
            child: const Text('Ajouter'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_error != null) return _ErrorView(_error!, _load);
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _load,
        child: _products.isEmpty
            ? const Center(child: Text('Aucun produit.'))
            : ListView.separated(
                padding: const EdgeInsets.all(12),
                itemCount: _products.length,
                separatorBuilder: (_, _) => const Divider(height: 1),
                itemBuilder: (_, i) {
                  final p = _products[i] as Map<String, dynamic>;
                  return ListTile(
                    leading: const Icon(Icons.shopping_bag, color: Colors.green),
                    title: Text(p['product_name']?.toString() ?? ''),
                    subtitle: Text('Stock : ${p['stock_quantity']}', style: const TextStyle(fontSize: 12)),
                    trailing: Text('${p['price']} DZD', style: const TextStyle(fontWeight: FontWeight.bold)),
                  );
                },
              ),
      ),
      floatingActionButton: FloatingActionButton(onPressed: _showAddDialog, child: const Icon(Icons.add)),
    );
  }
}

// ── Broadcast Tab ─────────────────────────────────────────────────────────────

class _BroadcastTab extends StatefulWidget {
  const _BroadcastTab();
  @override
  State<_BroadcastTab> createState() => _BroadcastTabState();
}

class _BroadcastTabState extends State<_BroadcastTab> {
  final _msgCtrl = TextEditingController();
  bool _sending = false;
  String? _error;

  @override
  void dispose() { _msgCtrl.dispose(); super.dispose(); }

  Future<void> _send() async {
    if (_msgCtrl.text.trim().isEmpty) return;
    setState(() { _sending = true; _error = null; });
    try {
      final token = await AuthStorage.getToken();
      await ApiService.broadcast(token!, _msgCtrl.text.trim());
      _msgCtrl.clear();
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Annonce envoyée à tous les utilisateurs !')));
    } catch (e) {
      setState(() { _error = e.toString(); });
    } finally {
      setState(() { _sending = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.campaign, size: 48, color: Colors.orange),
          const SizedBox(height: 12),
          const Text('Envoyer une annonce', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          const Text('Ce message sera visible par tous les utilisateurs.', style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 24),
          TextField(
            controller: _msgCtrl,
            maxLines: 6,
            decoration: const InputDecoration(border: OutlineInputBorder(), hintText: 'Votre annonce...'),
          ),
          const SizedBox(height: 16),
          if (_error != null) Padding(padding: const EdgeInsets.only(bottom: 12), child: Text(_error!, style: const TextStyle(color: Colors.red))),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _sending ? null : _send,
              icon: _sending ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.send),
              label: const Text('Diffuser'),
            ),
          ),
        ],
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
