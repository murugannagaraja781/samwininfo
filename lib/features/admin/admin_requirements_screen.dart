import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import '../../core/config/api_config.dart';

class AdminRequirementsScreen extends StatefulWidget {
  const AdminRequirementsScreen({super.key});

  @override
  State<AdminRequirementsScreen> createState() => _AdminRequirementsScreenState();
}

class _AdminRequirementsScreenState extends State<AdminRequirementsScreen> {
  bool _isLoading = true;
  List<dynamic> _requirements = [];

  @override
  void initState() {
    super.initState();
    _loadRequirements();
  }

  Future<void> _loadRequirements() async {
    setState(() => _isLoading = true);
    try {
      final url = Uri.parse('${ApiConfig.instance.serverUrl}/requests.php');
      final res = await http.get(url);
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        setState(() {
          _requirements = data['data'] ?? data['requests'] ?? (data is List ? data : []);
          _isLoading = false;
        });
        return;
      }
    } catch (e) {
      debugPrint('Error loading requirements: $e');
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

  void _openWhatsApp(String phone, String title) async {
    final clean = phone.replaceAll(RegExp(r'[^0-9]'), '');
    final formatted = clean.startsWith('91') ? clean : '91$clean';
    final uri = Uri.parse('https://wa.me/$formatted?text=வணக்கம், உங்கள் தேவை: $title குறித்து SamWin-ல் இருந்து தொடர்பு கொள்கிறோம்.');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
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
          'மக்களின் தேவைகள் (Buyer Board)',
          style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _requirements.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.assignment_outlined, size: 48, color: Colors.grey.shade400),
                      const SizedBox(height: 12),
                      const Text('கோரிக்கைகள் எதுவும் இல்லை.', style: TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadRequirements,
                  child: ListView.separated(
                    padding: const EdgeInsets.all(14),
                    itemCount: _requirements.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final req = _requirements[index];
                      final name = req['senderName'] ?? req['name'] ?? 'பயனர்';
                      final phone = req['senderPhone'] ?? req['phone'] ?? '';
                      final title = req['propertyTitle'] ?? req['title'] ?? 'சொத்து தேவை';
                      final message = req['message'] ?? '';
                      final status = req['status'] ?? 'pending';

                      return Card(
                        elevation: 1,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        child: Padding(
                          padding: const EdgeInsets.all(14),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    title,
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF0F172A)),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: status == 'accepted' ? Colors.green.shade50 : Colors.amber.shade50,
                                      borderRadius: BorderRadius.circular(6),
                                      border: Border.all(color: status == 'accepted' ? Colors.green.shade200 : Colors.amber.shade200),
                                    ),
                                    child: Text(
                                      status.toUpperCase(),
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        color: status == 'accepted' ? Colors.green.shade800 : Colors.amber.shade900,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              if (message.isNotEmpty) ...[
                                Text(message, style: const TextStyle(fontSize: 12.5, color: Color(0xFF475569))),
                                const SizedBox(height: 8),
                              ],
                              Row(
                                children: [
                                  const Icon(Icons.person, size: 16, color: Colors.grey),
                                  const SizedBox(width: 4),
                                  Text(name, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                                  const SizedBox(width: 12),
                                  const Icon(Icons.phone, size: 16, color: Colors.grey),
                                  const SizedBox(width: 4),
                                  Text(phone, style: const TextStyle(fontSize: 12)),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  if (phone.isNotEmpty) ...[
                                    OutlinedButton.icon(
                                      icon: const Icon(Icons.phone, size: 16, color: Colors.green),
                                      label: const Text('அழைக்க', style: TextStyle(color: Colors.green, fontSize: 12)),
                                      onPressed: () => _callPhone(phone),
                                    ),
                                    const SizedBox(width: 8),
                                    ElevatedButton.icon(
                                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF25D366)),
                                      icon: const Icon(Icons.chat_bubble, size: 16, color: Colors.white),
                                      label: const Text('WhatsApp', style: TextStyle(color: Colors.white, fontSize: 12)),
                                      onPressed: () => _openWhatsApp(phone, title),
                                    ),
                                  ],
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
