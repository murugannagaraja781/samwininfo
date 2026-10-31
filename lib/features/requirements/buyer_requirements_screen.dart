import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/currency_formatter.dart';
import '../../core/utils/date_formatter.dart';
import '../../models/buyer_requirement.dart';
import '../../state/app_state_providers.dart';

class BuyerRequirementsScreen extends ConsumerStatefulWidget {
  const BuyerRequirementsScreen({super.key});

  @override
  ConsumerState<BuyerRequirementsScreen> createState() => _BuyerRequirementsScreenState();
}

class _BuyerRequirementsScreenState extends ConsumerState<BuyerRequirementsScreen> {
  String _selectedCategory = 'all';

  final List<Map<String, String>> _categories = [
    {'id': 'all', 'nameTa': 'அனைத்தும்', 'nameEn': 'All'},
    {'id': 'Land', 'nameTa': 'நிலம்', 'nameEn': 'Land'},
    {'id': 'Farmland', 'nameTa': 'தோட்டம்', 'nameEn': 'Farmland'},
    {'id': 'House', 'nameTa': 'வீடு', 'nameEn': 'House'},
    {'id': 'Shop', 'nameTa': 'கடை / அலுவலகம்', 'nameEn': 'Shop/Office'},
    {'id': 'Rental', 'nameTa': 'வாடகைக்கு', 'nameEn': 'Rental'},
  ];

  Future<void> _makePhoneCall(String phone) async {
    final cleanPhone = phone.replaceAll(RegExp(r'[^\d+]'), '');
    final uri = Uri.parse('tel:$cleanPhone');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _openWhatsApp(String phone, String userName, String reqType) async {
    final cleanPhone = phone.replaceAll(RegExp(r'[^\d]'), '');
    final msg = Uri.encodeComponent(
      'வணக்கம் $userName, SamWin ஆப் மூலம் உங்கள் $reqType தேவை விளம்பரத்தைப் பார்த்தேன். என்னிடம் பொருத்தமான இடம் உள்ளது.',
    );
    final uri = Uri.parse('https://wa.me/$cleanPhone?text=$msg');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  void _openPostRequirementModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _PostRequirementModal(
        onSubmit: (req) {
          ref.read(buyerRequirementsProvider.notifier).addRequirement(req);
          Navigator.pop(ctx);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('உங்கள் தேவை வெற்றிகரமாக பதிவு செய்யப்பட்டது!'),
              backgroundColor: AppColors.primary,
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final allReqs = ref.watch(buyerRequirementsProvider);
    final filtered = _selectedCategory == 'all'
        ? allReqs
        : allReqs.where((r) => r.propertyType.toLowerCase() == _selectedCategory.toLowerCase()).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'மக்களின் தேவை',
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
            ),
            Text(
              'Buyer & Tenant Requirements in Tenkasi',
              style: TextStyle(fontSize: 11, color: Colors.white.withValues(alpha: 0.85)),
            ),
          ],
        ),
        backgroundColor: AppColors.primaryDark,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Banner & Post CTA
          Container(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
            decoration: BoxDecoration(
              color: Colors.white,
              border: const Border(bottom: BorderSide(color: Color(0xFFE2E8F0))),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'உங்களுக்கு இடம் / வீடு தேவையா?',
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 13.5,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'உங்கள் பட்ஜெட் மற்றும் விருப்பங்களை பதிவு செய்க',
                        style: TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                      ),
                    ],
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () => _openPostRequirementModal(context),
                  icon: const Icon(Icons.add_rounded, size: 16),
                  label: const Text('தேவை பதிவு'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    textStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12.5),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ],
            ),
          ),

          // Category Chips Row
          Container(
            height: 48,
            color: Colors.white,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              itemCount: _categories.length,
              separatorBuilder: (context, index) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final cat = _categories[index];
                final isSelected = _selectedCategory == cat['id'];
                return ChoiceChip(
                  label: Text(cat['nameTa']!),
                  selected: isSelected,
                  selectedColor: AppColors.primaryLight,
                  backgroundColor: const Color(0xFFF1F5F9),
                  labelStyle: TextStyle(
                    color: isSelected ? AppColors.primaryDark : const Color(0xFF475569),
                    fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                    fontSize: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: BorderSide(
                      color: isSelected ? AppColors.primary : Colors.transparent,
                    ),
                  ),
                  onSelected: (_) {
                    setState(() => _selectedCategory = cat['id']!);
                  },
                );
              },
            ),
          ),

          const Divider(height: 1, color: Color(0xFFE2E8F0)),

          // Requirements List
          Expanded(
            child: RefreshIndicator(
              color: AppColors.primary,
              onRefresh: () async {
                ref.read(buyerRequirementsProvider.notifier).refresh();
              },
              child: filtered.isEmpty
                  ? ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: [
                        SizedBox(height: MediaQuery.of(context).size.height * 0.2),
                        Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.search_off_rounded, size: 48, color: AppColors.textMuted),
                              const SizedBox(height: 10),
                              const Text(
                                'இந்த பிரிவில் தேவைகள் ஏதும் இல்லை',
                                style: TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF475569)),
                              ),
                              const SizedBox(height: 12),
                              OutlinedButton(
                                onPressed: () => _openPostRequirementModal(context),
                                child: const Text('முதல் தேவையை பதிவு செய்க'),
                              ),
                            ],
                          ),
                        ),
                      ],
                    )
                  : ListView.builder(
                      physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                      padding: const EdgeInsets.all(14),
                      itemCount: filtered.length,
                      itemBuilder: (context, index) {
                        final req = filtered[index];
                        return _buildRequirementCard(req);
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRequirementCard(BuyerRequirement req) {
    final budgetStr = req.budgetMax != null
        ? req.budgetMin != null
            ? '${CurrencyFormatter.formatIndian(req.budgetMin!)} - ${CurrencyFormatter.formatIndian(req.budgetMax!)}'
            : 'பட்ஜெட்: ${CurrencyFormatter.formatIndian(req.budgetMax!)} வரை'
        : 'பட்ஜெட் பேசலாம்';

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Name & Posted Date
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: AppColors.primaryLight,
                  child: Text(
                    req.userName.isNotEmpty ? req.userName[0] : 'U',
                    style: const TextStyle(
                      color: AppColors.primaryDark,
                      fontWeight: FontWeight.w800,
                      fontSize: 14,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        req.userName,
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 13.5,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      Text(
                        DateFormatter.timeAgo(req.postedDate),
                        style: const TextStyle(fontSize: 10.5, color: AppColors.textMuted),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF3C7),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    req.propertyType,
                    style: const TextStyle(
                      color: Color(0xFFB45309),
                      fontSize: 10.5,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const Divider(height: 1, color: Color(0xFFF1F5F9)),

          // Body: Target, Budget, Size
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Location & Budget Row
                Row(
                  children: [
                    const Icon(Icons.location_on_outlined, size: 14, color: Color(0xFF0284C7)),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        req.targetLocation,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 12.5,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Budget & Size Badges
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFFECFDF5),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: const Color(0xFFA7F3D0)),
                      ),
                      child: Text(
                        budgetStr,
                        style: const TextStyle(
                          color: Color(0xFF047857),
                          fontSize: 11.5,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    if (req.preferredSize != null)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: const Color(0xFFCBD5E1)),
                        ),
                        child: Text(
                          'அளவு: ${req.preferredSize}',
                          style: const TextStyle(
                            color: Color(0xFF334155),
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    if (req.facingPreference != null)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: const Color(0xFFCBD5E1)),
                        ),
                        child: Text(
                          'திசை: ${req.facingPreference}',
                          style: const TextStyle(
                            color: Color(0xFF334155),
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 10),

                // Description
                Text(
                  req.description,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF475569),
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),

          const Divider(height: 1, color: Color(0xFFE2E8F0)),

          // Actions: Direct Call & WhatsApp
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _makePhoneCall(req.userPhone),
                    icon: const Icon(Icons.phone_rounded, size: 15, color: Color(0xFF0D47A1)),
                    label: const Text('அழைக்க (Call)'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF0D47A1),
                      side: const BorderSide(color: Color(0xFF0D47A1)),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _openWhatsApp(req.userPhone, req.userName, req.propertyType),
                    icon: const Icon(Icons.chat_rounded, size: 15),
                    label: const Text('WhatsApp'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF25D366),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      textStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PostRequirementModal extends StatefulWidget {
  final ValueChanged<BuyerRequirement> onSubmit;

  const _PostRequirementModal({required this.onSubmit});

  @override
  State<_PostRequirementModal> createState() => _PostRequirementModalState();
}

class _PostRequirementModalState extends State<_PostRequirementModal> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _locationController = TextEditingController();
  final _budgetMaxController = TextEditingController();
  final _sizeController = TextEditingController();
  final _descController = TextEditingController();
  String _propertyType = 'Land';

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _locationController.dispose();
    _budgetMaxController.dispose();
    _sizeController.dispose();
    _descController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_nameController.text.trim().isEmpty || _phoneController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('தயவுசெய்து உங்கள் பெயர் மற்றும் போன் எண்ணை உள்ளிடவும்')),
      );
      return;
    }

    final req = BuyerRequirement(
      id: 'req_${DateTime.now().millisecondsSinceEpoch}',
      userName: _nameController.text.trim(),
      userPhone: _phoneController.text.trim(),
      propertyType: _propertyType,
      targetLocation: _locationController.text.trim().isNotEmpty
          ? _locationController.text.trim()
          : 'Tenkasi, Tamil Nadu',
      budgetMax: double.tryParse(_budgetMaxController.text.trim()),
      preferredSize: _sizeController.text.trim().isNotEmpty ? _sizeController.text.trim() : null,
      description: _descController.text.trim().isNotEmpty
          ? _descController.text.trim()
          : 'உடனடி பதிவு மற்றும் நல்ல இடத்தில் உள்ள இடம் தேவை.',
      postedDate: DateTime.now(),
      isUserPosted: true,
    );

    widget.onSubmit(req);
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom + MediaQuery.of(context).padding.bottom + 16;

    return SafeArea(
      top: false,
      bottom: true,
      child: Container(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 20,
          bottom: bottomPadding,
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'உங்கள் தேவை பதிவு செய்க',
                    style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: Color(0xFF0F172A)),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'உங்கள் பெயர் (Name)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person_outline),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'மொபைல் எண் (WhatsApp Mobile)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.phone_outlined),
                ),
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                initialValue: _propertyType,
                decoration: const InputDecoration(
                  labelText: 'தேவையான சொத்து வகை (Type)',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 'Land', child: Text('நிலம் (Land / Plot)')),
                  DropdownMenuItem(value: 'Farmland', child: Text('தோட்டம் (Farmland)')),
                  DropdownMenuItem(value: 'House', child: Text('வீடு (House / Villa)')),
                  DropdownMenuItem(value: 'Shop', child: Text('கடை / அலுவலகம் (Shop/Office)')),
                  DropdownMenuItem(value: 'Rental', child: Text('வாடகைக்கு (Rental / Lease)')),
                ],
                onChanged: (val) {
                  if (val != null) setState(() => _propertyType = val);
                },
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _locationController,
                decoration: const InputDecoration(
                  labelText: 'விரும்பும் ஊர் / பகுதி (Location)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.location_on_outlined),
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _budgetMaxController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'அதிகபட்ச பட்ஜெட் (₹)',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: _sizeController,
                      decoration: const InputDecoration(
                        labelText: 'அளவு (Cent/BHK)',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _descController,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'கூடுதல் விவரங்கள் (Details)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text(
                    'தேவையை சமர்ப்பிக்க (Submit)',
                    style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
