import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../core/config/api_config.dart';

class AdminSettingsScreen extends StatefulWidget {
  const AdminSettingsScreen({super.key});

  @override
  State<AdminSettingsScreen> createState() => _AdminSettingsScreenState();
}

class _AdminSettingsScreenState extends State<AdminSettingsScreen> {
  bool _isLoading = true;
  bool _isSaving = false;

  String _loginMethod = 'google';
  int _freeContactLimit = 3;
  int _contactUnlockPrice = 30;
  bool _offerActive = false;
  int _offerUnlockPrice = 10;
  String _appName = 'SamWin';
  String _adminPhone = '+91 98941 74944';

  @override
  void initState() {
    super.initState();
    _loadConfig();
  }

  Future<void> _loadConfig() async {
    setState(() => _isLoading = true);
    try {
      final url = Uri.parse('${ApiConfig.instance.serverUrl}/app_config.php');
      final res = await http.get(url);
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final cfg = data['config'] ?? {};
        setState(() {
          _loginMethod = cfg['login_method'] ?? 'google';
          _freeContactLimit = cfg['free_contact_limit'] ?? 3;
          _contactUnlockPrice = cfg['contact_unlock_price'] ?? 30;
          _offerActive = cfg['offer_active'] == true;
          _offerUnlockPrice = cfg['offer_unlock_price'] ?? 10;
          _appName = cfg['app_name'] ?? 'SamWin';
          _adminPhone = cfg['admin_phone'] ?? '+91 98941 74944';
        });
      }
    } catch (e) {
      debugPrint('Error loading app config: $e');
    }
    setState(() => _isLoading = false);
  }

  Future<void> _saveConfig() async {
    setState(() => _isSaving = true);
    try {
      final url = Uri.parse('${ApiConfig.instance.serverUrl}/app_config.php');
      final body = jsonEncode({
        'login_method': _loginMethod,
        'free_contact_limit': _freeContactLimit,
        'contact_unlock_price': _contactUnlockPrice,
        'offer_active': _offerActive,
        'offer_unlock_price': _offerUnlockPrice,
      });

      final res = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      if (res.statusCode == 200) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ செயலி அமைப்புகள் (App Settings) வெற்றிகரமாக சேமிக்கப்பட்டன!'),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ சேமிப்பதில் பிழை: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
    setState(() => _isSaving = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F3D6E),
        elevation: 2,
        title: const Text(
          'செயலி அமைப்புகள் (App Settings)',
          style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. Login Method Section
                    _buildSectionHeader('1. லாகின் முறை கட்டுப்பாடு (Login Method)'),
                    Card(
                      elevation: 1,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          children: [
                            RadioListTile<String>(
                              value: 'google',
                              groupValue: _loginMethod,
                              activeColor: const Color(0xFF0F3D6E),
                              title: const Text('Google Sign-In மட்டும் (பரிந்துரைக்கப்படுகிறது)'),
                              subtitle: const Text('ஒரே கிளிக்கில் உடனடி லாகின், மொபைலில் விண்டோ உடனே மூடும்'),
                              onChanged: (val) => setState(() => _loginMethod = val!),
                            ),
                            const Divider(),
                            RadioListTile<String>(
                              value: 'phone',
                              groupValue: _loginMethod,
                              activeColor: const Color(0xFF0F3D6E),
                              title: const Text('Phone OTP மட்டும்'),
                              subtitle: const Text('மொபைல் எண் மற்றும் SMS OTP மூலம் லாகின்'),
                              onChanged: (val) => setState(() => _loginMethod = val!),
                            ),
                            const Divider(),
                            RadioListTile<String>(
                              value: 'both',
                              groupValue: _loginMethod,
                              activeColor: const Color(0xFF0F3D6E),
                              title: const Text('Google & Phone இரண்டுமே (Both)'),
                              subtitle: const Text('பயனர்கள் விருப்பமான முறையை தேர்வு செய்யலாம்'),
                              onChanged: (val) => setState(() => _loginMethod = val!),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),

                    // 2. Contact Unlock Limits & Pricing
                    _buildSectionHeader('2. தொடர்பு அன்லாக் & கட்டணம் (Contact Paywall)'),
                    Card(
                      elevation: 1,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                const Expanded(
                                  child: Text(
                                    'இலவச தொடர்புகள் (Free Limit):',
                                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                DropdownButton<int>(
                                  value: _freeContactLimit,
                                  items: [1, 2, 3, 5, 10]
                                      .map((e) => DropdownMenuItem(value: e, child: Text('$e தொடர்புகள்')))
                                      .toList(),
                                  onChanged: (val) => setState(() => _freeContactLimit = val!),
                                ),
                              ],
                            ),
                            const Divider(),
                            Row(
                              children: [
                                const Expanded(
                                  child: Text(
                                    'வழக்கமான கட்டணம் (Unlock Price):',
                                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                DropdownButton<int>(
                                  value: _contactUnlockPrice,
                                  items: [10, 20, 30, 49, 99]
                                      .map((e) => DropdownMenuItem(value: e, child: Text('₹$e')))
                                      .toList(),
                                  onChanged: (val) => setState(() => _contactUnlockPrice = val!),
                                ),
                              ],
                            ),
                            const Divider(),
                            SwitchListTile(
                              contentPadding: EdgeInsets.zero,
                              title: const Text('சலுகைக் கட்டணம் (Offer Mode)', style: TextStyle(fontWeight: FontWeight.bold)),
                              subtitle: const Text('விசேஷ தள்ளுபடி சலுகை செயல்படுத்தல்'),
                              value: _offerActive,
                              activeColor: Colors.green,
                              onChanged: (val) => setState(() => _offerActive = val),
                            ),
                            if (_offerActive) ...[
                              Row(
                                children: [
                                  const Expanded(
                                    child: Text(
                                      'சலுகை விலை (Offer Price):',
                                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  DropdownButton<int>(
                                    value: _offerUnlockPrice,
                                    items: [5, 10, 15, 20]
                                        .map((e) => DropdownMenuItem(value: e, child: Text('₹$e')))
                                        .toList(),
                                    onChanged: (val) => setState(() => _offerUnlockPrice = val!),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),

                    // 3. Admin Info
                    _buildSectionHeader('3. அட்மின் விவரங்கள் (Admin Contact)'),
                    Card(
                      elevation: 1,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: const Icon(Icons.phone, color: Color(0xFF0F3D6E)),
                              title: const Text('அட்மின் உதவி எண்'),
                              subtitle: Text(_adminPhone, style: const TextStyle(fontWeight: FontWeight.bold)),
                            ),
                            ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: const Icon(Icons.apps, color: Color(0xFF0F3D6E)),
                              title: const Text('செயலி பெயர்'),
                              subtitle: Text(_appName, style: const TextStyle(fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Save Button
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.save_rounded, color: Colors.white, size: 20),
                        label: _isSaving
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Text(
                                'அமைப்புகளை சேமிக்க (Save Settings)',
                                style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
                              ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0F3D6E),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: 3,
                        ),
                        onPressed: _isSaving ? null : _saveConfig,
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 4),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w800,
          color: Color(0xFF0F172A),
        ),
      ),
    );
  }
}
