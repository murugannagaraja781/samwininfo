import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import '../../core/config/api_config.dart';

class LegalAdviceBottomSheet extends StatefulWidget {
  const LegalAdviceBottomSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const LegalAdviceBottomSheet(),
    );
  }

  @override
  State<LegalAdviceBottomSheet> createState() => _LegalAdviceBottomSheetState();
}

class _LegalAdviceBottomSheetState extends State<LegalAdviceBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController(text: '9894174944');
  final _locationController = TextEditingController(text: 'தென்காசி');
  final _notesController = TextEditingController();

  String _selectedServiceType = 'பத்திர ஆவண சரிபார்ப்பு';
  bool _isSubmitting = false;
  bool _isSubmitted = false;

  final List<Map<String, dynamic>> _serviceOptions = [
    {'id': 'பத்திர ஆவண சரிபார்ப்பு', 'label': 'பத்திர ஆவண சரிபார்ப்பு (Title Deed Verification)', 'icon': Icons.description_rounded},
    {'id': 'பட்டா & சிட்டா பெயர் மாற்றம்', 'label': 'பட்டா & சிட்டா பெயர் மாற்றம் (Patta Transfer)', 'icon': Icons.badge_rounded},
    {'id': 'வில்லங்க சான்றிதழ் ஆய்வு (EC)', 'label': 'வில்லங்க சான்றிதழ் ஆய்வு (EC Verification)', 'icon': Icons.manage_search_rounded},
    {'id': 'எல்லை அளவீடு & சர்வே', 'label': 'எல்லை அளவீடு & சர்வே (Land Survey)', 'icon': Icons.straighten_rounded},
    {'id': 'DTCP / RERA அப்ரூவல்', 'label': 'DTCP / RERA அப்ரூவல் வழிகாட்டுதல்', 'icon': Icons.verified_user_rounded},
    {'id': 'பொதுவான சட்ட ஆலோசனை', 'label': 'பொதுவான ரியல் எஸ்டேட் சட்ட ஆலோசனை', 'icon': Icons.gavel_rounded},
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _locationController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _submitRequest() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    final payload = {
      'name': _nameController.text.trim(),
      'phone': _phoneController.text.trim(),
      'location': _locationController.text.trim(),
      'serviceType': _selectedServiceType,
      'notes': _notesController.text.trim(),
    };

    try {
      final url = Uri.parse('${ApiConfig.instance.serverUrl}/legal_advice.php');
      await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(payload),
      ).timeout(const Duration(seconds: 4));
    } catch (_) {
      // Offline safe
    }

    if (mounted) {
      setState(() {
        _isSubmitting = false;
        _isSubmitted = true;
      });
    }
  }

  Future<void> _launchUrl(String urlStr) async {
    final uri = Uri.parse(urlStr);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom + MediaQuery.of(context).padding.bottom + 16;

    return SafeArea(
      top: false,
      bottom: true,
      child: Container(
        padding: EdgeInsets.only(
          bottom: bottomPadding,
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
            // Header Bar
            Container(
              padding: const EdgeInsets.fromLTRB(20, 16, 16, 16),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Center(
                      child: Icon(Icons.gavel_rounded, color: Color(0xFFFBBF24), size: 24),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '⚖️ வழக்கறிஞர் சட்ட ஆலோசனை',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'தென்காசி மாவட்ட அனுபவமிக்க வழக்கறிஞர் உதவி',
                          style: TextStyle(
                            color: Color(0xFF94A3B8),
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, color: Colors.white70),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(20),
              child: _isSubmitted ? _buildSuccessView() : _buildFormView(),
            ),
          ],
        ),
      ),
    ),
  );
}

  Widget _buildFormView() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Info banner
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: const Row(
              children: [
                Icon(Icons.shield_outlined, color: Color(0xFF0F172A), size: 20),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'பத்திர ஆவணம், வில்லங்க சான்றிதழ், பட்டா தொடர்பான உங்கள் சந்தேகங்களை இலவசமாக ஆலோசனை பெறலாம்.',
                    style: TextStyle(fontSize: 11.5, color: Color(0xFF334155), height: 1.4),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // 1. Name
          const Text('உங்கள் பெயர் (Name)*', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: Color(0xFF0F172A))),
          const SizedBox(height: 6),
          TextFormField(
            controller: _nameController,
            validator: (v) => (v == null || v.trim().isEmpty) ? 'பெயரை உள்ளிடவும்' : null,
            decoration: InputDecoration(
              hintText: 'உதா: முருகன்',
              prefixIcon: const Icon(Icons.person_outline_rounded, size: 20),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFCBD5E1))),
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            ),
          ),
          const SizedBox(height: 14),

          // 2. Phone
          const Text('செல்போன் எண் (Mobile for Call & WhatsApp)*', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: Color(0xFF0F172A))),
          const SizedBox(height: 6),
          TextFormField(
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            validator: (v) => (v == null || v.trim().length < 10) ? '10 இலக்க செல்போன் எண் உள்ளிடவும்' : null,
            decoration: InputDecoration(
              hintText: '98941 74944',
              prefixIcon: const Icon(Icons.phone_outlined, size: 20),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFCBD5E1))),
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            ),
          ),
          const SizedBox(height: 14),

          // 3. Location
          const Text('சொத்து உள்ள ஊர் / தாலுகா (Location)*', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: Color(0xFF0F172A))),
          const SizedBox(height: 6),
          TextFormField(
            controller: _locationController,
            decoration: InputDecoration(
              hintText: 'உதா: தென்காசி, பாவூர்சத்திரம், செங்கோட்டை',
              prefixIcon: const Icon(Icons.location_on_outlined, size: 20),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFCBD5E1))),
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            ),
          ),
          const SizedBox(height: 14),

          // 4. Service Type
          const Text('தேவைப்படும் சட்ட சேவை (Service Needed)*', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: Color(0xFF0F172A))),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFCBD5E1)),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedServiceType,
                isExpanded: true,
                items: _serviceOptions.map((opt) {
                  return DropdownMenuItem<String>(
                    value: opt['id'] as String,
                    child: Row(
                      children: [
                        Icon(opt['icon'] as IconData, size: 18, color: const Color(0xFF0F172A)),
                        const SizedBox(width: 8),
                        Expanded(child: Text(opt['label'] as String, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600))),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _selectedServiceType = val);
                },
              ),
            ),
          ),
          const SizedBox(height: 14),

          // 5. Notes
          const Text('கூடுதல் விவரங்கள் / குறிப்பு (Notes)', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: Color(0xFF0F172A))),
          const SizedBox(height: 6),
          TextFormField(
            controller: _notesController,
            maxLines: 2,
            decoration: InputDecoration(
              hintText: 'சொத்து விபரம் அல்லது உங்கள் சந்தேகங்களை குறிப்பிடவும்...',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFCBD5E1))),
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            ),
          ),
          const SizedBox(height: 20),

          // Submit Button
          ElevatedButton(
            onPressed: _isSubmitting ? null : _submitRequest,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0F172A),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 2,
            ),
            child: _isSubmitting
                ? const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)),
                      SizedBox(width: 10),
                      Text('பதிவு செய்யப்படுகிறது...', style: TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  )
                : const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.gavel_rounded, color: Color(0xFFFBBF24), size: 20),
                      SizedBox(width: 8),
                      Text('சட்ட ஆலோசனை கோருக (Submit)', style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.bold)),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessView() {
    return Column(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: const BoxDecoration(
            color: Color(0xFFDCFCE7),
            shape: BoxShape.circle,
          ),
          child: const Center(
            child: Icon(Icons.check_circle_rounded, color: Color(0xFF16A34A), size: 36),
          ),
        ),
        const SizedBox(height: 14),
        const Text(
          'கோரிக்கை வெற்றிகரமாக பதிவு செய்யப்பட்டது!',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Color(0xFF065F46)),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        const Text(
          'எங்கள் சட்ட ஆலோசகர் குழு மற்றும் சூப்பர் அட்மின் விரைவில் உங்களை அழைத்து ஆவண சரிபார்ப்பு வழிகாட்டுதலை வழங்குவர்.',
          style: TextStyle(fontSize: 12.5, color: Color(0xFF475569), height: 1.4),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _launchUrl('https://wa.me/919894174944?text=வணக்கம்,%20எனக்கு%20சொத்து%20சட்ட%20ஆலோசனை%20தேவைப்படுகிறது'),
                icon: const Icon(Icons.chat_bubble_rounded, size: 18),
                label: const Text('WhatsApp'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF25D366),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 11),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _launchUrl('tel:9894174944'),
                icon: const Icon(Icons.call_rounded, size: 18),
                label: const Text('நேரடி அழைப்பு'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0F172A),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 11),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('சரி, முடிந்தது (Close)'),
        ),
      ],
    );
  }
}
