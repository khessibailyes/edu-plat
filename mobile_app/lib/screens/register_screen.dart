import 'package:flutter/material.dart';
import 'package:mobile_app/main.dart';
import 'package:mobile_app/services/api_service.dart';
import 'package:mobile_app/services/auth_storage.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameCtrl     = TextEditingController();
  final _emailCtrl    = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl  = TextEditingController();
  String _role = 'student';
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (_passwordCtrl.text != _confirmCtrl.text) {
      setState(() { _error = 'Les mots de passe ne correspondent pas.'; });
      return;
    }
    setState(() { _loading = true; _error = null; });
    try {
      final result = await ApiService.register(
        _nameCtrl.text.trim(), _emailCtrl.text.trim(), _passwordCtrl.text.trim(), _role,
      );
      final token = result['token'] as String;
      final user  = result['user']  as Map<String, dynamic>;
      await AuthStorage.saveToken(token);
      await AuthStorage.saveUser(user);
      if (!mounted) return;
      navigateToHome(context, user['role']?.toString());
    } catch (e) {
      setState(() { _error = e.toString(); });
    } finally {
      setState(() { _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Créer un compte')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _nameCtrl,
                decoration: const InputDecoration(labelText: 'Nom complet', border: OutlineInputBorder(), prefixIcon: Icon(Icons.person_outline)),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: _emailCtrl,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(labelText: 'Email', border: OutlineInputBorder(), prefixIcon: Icon(Icons.email_outlined)),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: _passwordCtrl,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Mot de passe (min 8 caractères)', border: OutlineInputBorder(), prefixIcon: Icon(Icons.lock_outline)),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: _confirmCtrl,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Confirmer le mot de passe', border: OutlineInputBorder(), prefixIcon: Icon(Icons.lock_outline)),
              ),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(border: Border.all(color: Colors.grey), borderRadius: BorderRadius.circular(4)),
                child: DropdownButton<String>(
                  value: _role,
                  isExpanded: true,
                  underline: const SizedBox(),
                  items: const [
                    DropdownMenuItem(value: 'student', child: Text('Étudiant')),
                    DropdownMenuItem(value: 'teacher', child: Text('Enseignant')),
                  ],
                  onChanged: (v) => setState(() => _role = v ?? 'student'),
                ),
              ),
              const SizedBox(height: 20),
              if (_error != null) ...[
                Text(_error!, style: const TextStyle(color: Colors.red), textAlign: TextAlign.center),
                const SizedBox(height: 12),
              ],
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _loading ? null : _register,
                  style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
                  child: _loading ? const CircularProgressIndicator(color: Colors.white) : const Text("S'inscrire", style: TextStyle(fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
