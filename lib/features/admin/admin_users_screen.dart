import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import '../../core/config/api_config.dart';

class AdminUsersScreen extends StatefulWidget {
  const AdminUsersScreen({super.key});

  @override
  State<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends State<AdminUsersScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = true;
  List<dynamic> _users = [];
  List<dynamic> _activities = [];
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final baseUrl = ApiConfig.instance.serverUrl;
      final usersRes = await http.get(Uri.parse('$baseUrl/users.php?action=list_live'));
      final actRes = await http.get(Uri.parse('$baseUrl/activities.php'));

      if (usersRes.statusCode == 200) {
        final data = jsonDecode(usersRes.body);
        _users = data['users'] ?? [];
      }
      if (actRes.statusCode == 200) {
        final data = jsonDecode(actRes.body);
        _activities = data['activities'] ?? [];
      }
    } catch (e) {
      debugPrint('Error loading admin users/activities: $e');
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

  void _openWhatsApp(String phone) async {
    final clean = phone.replaceAll(RegExp(r'[^0-9]'), '');
    final formatted = clean.startsWith('91') ? clean : '91$clean';
    final uri = Uri.parse('https://wa.me/$formatted?text=வணக்கம், SamWin Super Admin-ல் இருந்து தொடர்பு கொள்கிறோம்.');
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
          'பயனர்கள் & தொடர்புகள் (Users & Leads)',
          style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.amber,
          tabs: const [
            Tab(text: 'அனைத்து பயனர்கள்'),
            Tab(text: 'விற்பனையாளர்கள் (Posters)'),
            Tab(text: 'பார்த்தவர்கள் (Viewers/Leads)'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Search bar
                Container(
                  padding: const EdgeInsets.all(12),
                  color: Colors.white,
                  child: TextField(
                    onChanged: (val) => setState(() => _searchQuery = val.trim().toLowerCase()),
                    decoration: InputDecoration(
                      hintText: 'பெயர் அல்லது போன் எண் தேடுக...',
                      prefixIcon: const Icon(Icons.search, color: Color(0xFF0284C7)),
                      filled: true,
                      fillColor: const Color(0xFFF1F5F9),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildUsersList(),
                      _buildPostersList(),
                      _buildViewersList(),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildUsersList() {
    final filtered = _users.where((u) {
      if (_searchQuery.isEmpty) return true;
      final name = (u['user_name'] ?? '').toString().toLowerCase();
      final phone = (u['user_phone'] ?? '').toString().toLowerCase();
      return name.contains(_searchQuery) || phone.contains(_searchQuery);
    }).toList();

    if (filtered.isEmpty) {
      return const Center(child: Text('பயனர்கள் இல்லை.'));
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView.separated(
        padding: const EdgeInsets.all(14),
        itemCount: filtered.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          final u = filtered[index];
          final isOnline = u['is_online'] == true;
          final phone = u['user_phone'] ?? '';

          return Card(
            elevation: 1,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: isOnline ? Colors.green.shade100 : Colors.blue.shade100,
                child: Icon(
                  isOnline ? Icons.person_pin_circle_rounded : Icons.person_rounded,
                  color: isOnline ? Colors.green.shade800 : const Color(0xFF0F3D6E),
                ),
              ),
              title: Text(
                u['user_name'] ?? 'Customer',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(phone.isNotEmpty ? phone : 'போன் எண் இல்லை', style: const TextStyle(fontSize: 12)),
                  Text(
                    '${u['platform'] ?? 'App'} • ${u['status'] ?? 'Active'}',
                    style: TextStyle(fontSize: 11, color: isOnline ? Colors.green : Colors.grey),
                  ),
                ],
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (phone.isNotEmpty) ...[
                    IconButton(
                      icon: const Icon(Icons.phone, color: Colors.green, size: 20),
                      onPressed: () => _callPhone(phone),
                    ),
                    IconButton(
                      icon: const Icon(Icons.chat_bubble, color: Color(0xFF25D366), size: 20),
                      onPressed: () => _openWhatsApp(phone),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPostersList() {
    // Unique sellers from activities where action_type is post_ad or similar
    final posters = _activities.where((a) {
      final act = (a['action_type'] ?? '').toString().toLowerCase();
      return act.contains('post') || (a['seller_phone'] != null && a['seller_phone'].toString().isNotEmpty);
    }).toList();

    return RefreshIndicator(
      onRefresh: _loadData,
      child: posters.isEmpty
          ? const Center(child: Text('விற்பனையாளர்கள் பட்டியல் இல்லை.'))
          : ListView.separated(
              padding: const EdgeInsets.all(14),
              itemCount: posters.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final p = posters[index];
                final phone = p['seller_phone'] ?? p['user_phone'] ?? '';
                final name = p['seller_name'] ?? p['user_name'] ?? 'விற்பனையாளர்';
                final propTitle = p['property_title'] ?? 'சொத்து விளம்பரம்';

                return Card(
                  elevation: 1,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: Color(0xFF0284C7),
                      child: Icon(Icons.real_estate_agent_rounded, color: Colors.white),
                    ),
                    title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    subtitle: Text('$propTitle\n$phone', style: const TextStyle(fontSize: 12)),
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
    );
  }

  Widget _buildViewersList() {
    // Viewers who unlocked contacts
    return RefreshIndicator(
      onRefresh: _loadData,
      child: _activities.isEmpty
          ? const Center(child: Text('பார்த்தவர்கள் பட்டியல் இல்லை.'))
          : ListView.separated(
              padding: const EdgeInsets.all(14),
              itemCount: _activities.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final a = _activities[index];
                final viewerPhone = a['user_phone'] ?? a['viewer_phone'] ?? '';
                final viewerName = a['user_name'] ?? a['viewer_name'] ?? 'பயனர்';
                final propTitle = a['property_title'] ?? 'விளம்பரம் பார்க்கப்பட்டது';
                final time = a['created_at'] ?? '';

                return Card(
                  elevation: 1,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: Color(0xFF059669),
                      child: Icon(Icons.visibility_rounded, color: Colors.white),
                    ),
                    title: Text(viewerName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    subtitle: Text('$propTitle\nபோன்: $viewerPhone • $time', style: const TextStyle(fontSize: 12)),
                    isThreeLine: true,
                    trailing: viewerPhone.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.phone, color: Colors.green),
                            onPressed: () => _callPhone(viewerPhone),
                          )
                        : null,
                  ),
                );
              },
            ),
    );
  }
}
