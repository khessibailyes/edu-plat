import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const _baseUrl = 'https://perfected-monsoon-unadorned.ngrok-free.dev/api';

  static const _baseHeaders = {
    'Content-Type': 'application/json',
    'ngrok-skip-browser-warning': '1',
  };

  static Map<String, String> _authHeaders(String token) => {
        'Authorization': 'Bearer $token',
        'ngrok-skip-browser-warning': '1',
      };

  // ── Auth ──────────────────────────────────────────────────────────────────

  static Future<Map<String, dynamic>> login(String email, String password) async {
    final r = await http.post(Uri.parse('$_baseUrl/login.php'),
        headers: _baseHeaders, body: jsonEncode({'email': email, 'password': password}));
    return _process(r);
  }

  static Future<Map<String, dynamic>> register(
      String fullName, String email, String password, String role) async {
    final r = await http.post(Uri.parse('$_baseUrl/register.php'),
        headers: _baseHeaders,
        body: jsonEncode({'full_name': fullName, 'email': email, 'password': password, 'role': role}));
    return _process(r);
  }

  // ── Documents ─────────────────────────────────────────────────────────────

  static Future<Map<String, dynamic>> fetchDocuments(String token) async {
    final r = await http.get(Uri.parse('$_baseUrl/documents.php'), headers: _authHeaders(token));
    return _process(r);
  }

  static Future<Map<String, dynamic>> deleteDocument(String token, int id) async {
    final r = await http.post(Uri.parse('$_baseUrl/delete_document.php'),
        headers: {..._authHeaders(token), 'Content-Type': 'application/json'},
        body: jsonEncode({'id': id}));
    return _process(r);
  }

  static Future<Map<String, dynamic>> uploadDocument(
      String token, String description, String filePath) async {
    final request = http.MultipartRequest('POST', Uri.parse('$_baseUrl/upload.php'));
    request.headers['Authorization'] = 'Bearer $token';
    request.headers['ngrok-skip-browser-warning'] = '1';
    request.fields['description'] = description;
    request.files.add(await http.MultipartFile.fromPath('document', filePath));
    final streamed = await request.send();
    final body = await streamed.stream.bytesToString();
    Map<String, dynamic> json;
    try {
      json = jsonDecode(body) as Map<String, dynamic>;
    } catch (_) {
      throw ApiException('Réponse serveur invalide.');
    }
    if (streamed.statusCode >= 200 && streamed.statusCode < 300) return json;
    throw ApiException(json['error']?.toString() ?? 'Erreur inconnue');
  }

  // ── Messages ──────────────────────────────────────────────────────────────

  static Future<Map<String, dynamic>> fetchMessages(String token) async {
    final r = await http.get(Uri.parse('$_baseUrl/messages.php'), headers: _authHeaders(token));
    return _process(r);
  }

  static Future<Map<String, dynamic>> sendMessage(
      String token, String content, String receiverId, String type) async {
    final r = await http.post(Uri.parse('$_baseUrl/send_message.php'),
        headers: {..._authHeaders(token), 'Content-Type': 'application/json'},
        body: jsonEncode({'content': content, 'receiver_id': receiverId, 'type': type}));
    return _process(r);
  }

  static Future<Map<String, dynamic>> fetchTeachers(String token) async {
    final r = await http.get(Uri.parse('$_baseUrl/teachers.php'), headers: _authHeaders(token));
    return _process(r);
  }

  // ── Profile ───────────────────────────────────────────────────────────────

  static Future<Map<String, dynamic>> updateProfile(
      String token, String fullName, String email, {String? password}) async {
    final body = <String, dynamic>{'full_name': fullName, 'email': email};
    if (password != null && password.isNotEmpty) body['password'] = password;
    final r = await http.post(Uri.parse('$_baseUrl/update_profile.php'),
        headers: {..._authHeaders(token), 'Content-Type': 'application/json'},
        body: jsonEncode(body));
    return _process(r);
  }

  // ── Admin ─────────────────────────────────────────────────────────────────

  static Future<Map<String, dynamic>> fetchStats(String token) async {
    final r = await http.get(Uri.parse('$_baseUrl/stats.php'), headers: _authHeaders(token));
    return _process(r);
  }

  static Future<Map<String, dynamic>> fetchUsers(String token) async {
    final r = await http.get(Uri.parse('$_baseUrl/users_list.php'), headers: _authHeaders(token));
    return _process(r);
  }

  static Future<Map<String, dynamic>> deleteUser(String token, int id) async {
    final r = await http.post(Uri.parse('$_baseUrl/delete_user.php'),
        headers: {..._authHeaders(token), 'Content-Type': 'application/json'},
        body: jsonEncode({'id': id}));
    return _process(r);
  }

  static Future<Map<String, dynamic>> fetchProducts(String token) async {
    final r = await http.get(Uri.parse('$_baseUrl/products.php'), headers: _authHeaders(token));
    return _process(r);
  }

  static Future<Map<String, dynamic>> addProduct(
      String token, String name, double price, int qty) async {
    final r = await http.post(Uri.parse('$_baseUrl/products.php'),
        headers: {..._authHeaders(token), 'Content-Type': 'application/json'},
        body: jsonEncode({'product_name': name, 'price': price, 'stock_quantity': qty}));
    return _process(r);
  }

  static Future<Map<String, dynamic>> broadcast(String token, String content) async {
    return sendMessage(token, content, 'all', 'public');
  }

  // ── Internal ──────────────────────────────────────────────────────────────

  static Map<String, dynamic> _process(http.Response r) {
    final ct = r.headers['content-type'] ?? '';
    if (!ct.contains('application/json')) {
      throw ApiException(
          'Serveur inaccessible (HTTP ${r.statusCode}). Vérifiez PHP et ngrok.');
    }
    Map<String, dynamic> json;
    try {
      json = jsonDecode(r.body) as Map<String, dynamic>;
    } catch (_) {
      throw ApiException('Réponse serveur invalide.');
    }
    if (r.statusCode >= 200 && r.statusCode < 300) return json;
    throw ApiException(json['error']?.toString() ?? 'Erreur inconnue');
  }
}

class ApiException implements Exception {
  final String message;
  ApiException(this.message);
  @override
  String toString() => message;
}
