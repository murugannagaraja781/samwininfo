import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import '../../core/config/api_config.dart';

class AdminLegalRequestsScreen extends StatefulWidget {
  const AdminLegalRequestsScreen({super.key});

  @override
  State<AdminLegalRequestsScreen> createState() => _AdminLegalRequestsScreenState();
}

class _AdminLegalRequestsScreenState extends State<AdminLegalRequestsScreen> {
  bool _isLoading = true;
  List<dynamic> _requests = [];

  @override
  void initState() {
    super.initState();
    _loadLegalRequests();
  }

  Future<void> _loadLegalRequests() async {
    setState(() => _isLoading = true);
    try {
      final url = Uri.parse('${ApiConfig.instance.serverUrl}/activities.php?action_type=legal_advice');
      final res = await http.get(url);
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        setState(() {
          _requests = data['activities'] ?? [];
          _isLoading = false;
        });
        return;
      }
    } catch (e) {
      debugPrint('Error loading legal requests: $e');
    }
    setState(() => _isLoading = false);
  }

  void _callPhone(String phone) async {
    final clean = phone.replaceAll(RegExp(r'[^0-9+]'), '');
    final uri = Uri.parse('tel:$clean');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F3D6E),
        elevation: 2,
        title: const Text(
          'சட்ட ஆலோசனை கோரிக்கைகள் (Legal Advice)',
          style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _requests.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.gavel_rounded, size: 48, color: Colors.grey.shade400),
                      const SizedBox(height: 12),
                      const Text('சட்ட ஆலோசனை கோரிக்கைகள் எதுவும் இல்லை.', style: TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadLegalRequests,
                  child: ListView.separated(
                    padding: const EdgeInsets.all(14),
                    itemCount: _requests.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final item = _requests[index];
                      final name = item['user_name'] ?? 'பயனர்';
                      final phone = item['user_phone'] ?? '';
                      final details = item['details'] ?? item['notes'] ?? 'சட்ட ஆலோசனை தேவை';
                      final time = item['created_at'] ?? '';

                      return Card(
                        elevation: 1,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        child: ListTile(
                          leading: const CircleAvatar(
                            backgroundColor: Color(0xFF0F3D6E),
                            child: Icon(Icons.gavel_rounded, color: Colors.amber),
                          ),
                          title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                          subtitle: Text('$details\nபோன்: $phone • $time', style: const TextStyle(fontSize: 12)),
                          isThreeLine: true,
                          trailing: phone.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.phone, color: Colors.green),
                                  onPressed: () => _callPhone(phone),
                                )
                              : null,
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
