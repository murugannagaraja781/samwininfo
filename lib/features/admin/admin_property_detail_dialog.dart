import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import '../../core/config/api_config.dart';
import '../../core/utils/currency_formatter.dart';
import '../../models/property.dart';
import 'admin_ad_alert_service.dart';

class AdminPropertyDetailDialog extends StatefulWidget {
  final Property property;
  final VoidCallback? onHandled;

  const AdminPropertyDetailDialog({
    super.key,
    required this.property,
    this.onHandled,
  });

  static Future<void> show(
    BuildContext context,
    Property property, {
    VoidCallback? onHandled,
  }) async {
    await showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) => AdminPropertyDetailDialog(
        property: property,
        onHandled: onHandled,
      ),
    );
  }

  @override
  State<AdminPropertyDetailDialog> createState() => _AdminPropertyDetailDialogState();
}

class _AdminPropertyDetailDialogState extends State<AdminPropertyDetailDialog> {
  bool _isProcessing = false;
  late Property _prop;
  int _selectedImageIndex = 0;

  @override
  void initState() {
    super.initState();
    _prop = widget.property;
  }

  Future<void> _updateStatus(String newStatus) async {
    setState(() => _isProcessing = true);
    // Mark handled immediately so alarm never sounds again
    AdminAdAlertService().markHandled(_prop.id);
    try {
      final url = Uri.parse(
        '${ApiConfig.instance.serverUrl}/properties.php?action=update_status&id=${_prop.id}&status=$newStatus',
      );
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'id': _prop.id,
          'status': newStatus,
        }),
      );

      debugPrint('Ad status update: ${response.statusCode}');
      if (mounted) {
        setState(() {
          _prop = _prop.copyWith(status: newStatus);
          _isProcessing = false;
        });
        widget.onHandled?.call();

        final msg = newStatus == 'active'
            ? '✅ விளம்பரம் ஒப்புதல் அளிக்கப்பட்டு நேரலை செய்யப்பட்டது!'
            : (newStatus == 'rejected'
                ? '❌ விளம்பரம் நிராகரிக்கப்பட்டது!'
                : '⏳ காத்திருப்பில் வைக்கப்பட்டது.');

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(msg, style: const TextStyle(fontWeight: FontWeight.bold)),
            backgroundColor: newStatus == 'active'
                ? const Color(0xFF16A34A)
                : (newStatus == 'rejected' ? Colors.red.shade700 : Colors.amber.shade800),
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      debugPrint('Error updating status: $e');
      if (mounted) {
        setState(() => _isProcessing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('பிழை: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _callPhone(String phone) async {
    final clean = phone.replaceAll(RegExp(r'[^0-9+]'), '');
    final uri = Uri.parse('tel:$clean');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _openWhatsApp(String phone, String title) async {
    final clean = phone.replaceAll(RegExp(r'[^0-9]'), '');
    final text = Uri.encodeComponent(
      'வணக்கம்! SamWin Super Admin பேசுகிறேன். உங்கள் விளம்பரம்: "$title" தொடர்பாக...',
    );
    final uri = Uri.parse('https://wa.me/$clean?text=$text');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _openMap(String? mapUrl, String location) async {
    Uri uri;
    if (mapUrl != null && mapUrl.isNotEmpty && mapUrl.startsWith('http')) {
      uri = Uri.parse(mapUrl);
    } else {
      uri = Uri.parse('https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent('$location, Tenkasi')}');
    }
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = _prop;
    final status = p.status.toLowerCase();
    final isPending = status == 'pending';
    final isRejected = status == 'rejected';
    final isActive = status == 'active' || status == 'published';

    final priceStr = CurrencyFormatter.formatIndianPrice(p.price, isRental: p.isRental);
    final phone = p.contactPhone ?? p.agent.phone;

    final allImages = <String>[];
    if (p.customImageBase64 != null && p.customImageBase64!.isNotEmpty) {
      allImages.add(p.customImageBase64!);
    }
    for (final img in p.imageUrls) {
      if (img.isNotEmpty && !allImages.contains(img)) {
        allImages.add(img);
      }
    }
    if (allImages.isEmpty && p.imageUrl != null && p.imageUrl!.isNotEmpty) {
      allImages.add(p.imageUrl!);
    }

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      clipBehavior: Clip.antiAlias,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 520, maxHeight: 720),
        child: Column(
          children: [
            // Header Bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              color: const Color(0xFF0F3D6E),
              child: Row(
                children: [
                  // Status Badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: isPending
                          ? const Color(0xFFD97706)
                          : (isRejected ? const Color(0xFFDC2626) : const Color(0xFF16A34A)),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isPending
                              ? Icons.hourglass_top_rounded
                              : (isRejected ? Icons.cancel_rounded : Icons.check_circle_rounded),
                          color: Colors.white,
                          size: 13,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          isPending ? 'Pending' : (isRejected ? 'Rejected' : 'Live / நேரலை'),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'ID: #${p.id}',
                      style: const TextStyle(color: Colors.white70, fontSize: 12),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white70, size: 20),
                    onPressed: () => Navigator.of(context).pop(),
                    tooltip: 'மூடு',
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ),

            // Scrollable Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Image Gallery
                    if (allImages.isNotEmpty) ...[
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          height: 200,
                          width: double.infinity,
                          color: Colors.grey.shade100,
                          child: _buildGalleryImage(allImages[_selectedImageIndex]),
                        ),
                      ),
                      if (allImages.length > 1) ...[
                        const SizedBox(height: 8),
                        SizedBox(
                          height: 50,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: allImages.length,
                            separatorBuilder: (_, __) => const SizedBox(width: 8),
                            itemBuilder: (context, i) {
                              final isSelected = i == _selectedImageIndex;
                              return GestureDetector(
                                onTap: () => setState(() => _selectedImageIndex = i),
                                child: Container(
                                  width: 50,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: isSelected ? const Color(0xFF0F3D6E) : Colors.grey.shade300,
                                      width: isSelected ? 2.5 : 1,
                                    ),
                                  ),
                                  clipBehavior: Clip.antiAlias,
                                  child: _buildGalleryImage(allImages[i]),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                      const SizedBox(height: 14),
                    ],

                    // Title and Price
                    Text(
                      p.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Text(
                          priceStr,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF047857),
                          ),
                        ),
                        if (p.isPriceNegotiable) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.green.shade50,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: Colors.green.shade200),
                            ),
                            child: const Text(
                              'பேசலாம்',
                              style: TextStyle(fontSize: 10, color: Color(0xFF047857), fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEFF6FF),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: const Color(0xFFBFDBFE)),
                          ),
                          child: Text(
                            p.propertyType,
                            style: const TextStyle(
                              color: Color(0xFF1D4ED8),
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // Location & Map
                    InkWell(
                      onTap: () => _openMap(p.googleMapUrl, p.location),
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.location_on_rounded, color: Color(0xFFDC2626), size: 20),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                '${p.location}, ${p.city}',
                                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF334155)),
                              ),
                            ),
                            const Icon(Icons.map_rounded, color: Color(0xFF0284C7), size: 18),
                            const SizedBox(width: 4),
                            const Text(
                              'Map',
                              style: TextStyle(fontSize: 12, color: Color(0xFF0284C7), fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Specifications Grid
                    _buildSpecGrid(p),
                    const SizedBox(height: 14),

                    // Seller Contact Box
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'விளம்பரதாரர் தொடர்பு விபரம்',
                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF64748B)),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 18,
                                backgroundColor: const Color(0xFF0F3D6E),
                                child: const Icon(Icons.person, color: Colors.white, size: 20),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      p.agent.name.isNotEmpty ? p.agent.name : (p.posterType ?? 'Direct Owner'),
                                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                      phone,
                                      style: const TextStyle(fontSize: 12, color: Color(0xFF0284C7), fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ),
                              // Call Button
                              IconButton.filled(
                                onPressed: () => _callPhone(phone),
                                icon: const Icon(Icons.call, size: 16),
                                style: IconButton.styleFrom(
                                  backgroundColor: const Color(0xFF0284C7),
                                  padding: const EdgeInsets.all(8),
                                ),
                                tooltip: 'அழைக்க',
                              ),
                              const SizedBox(width: 6),
                              // WhatsApp Button
                              IconButton.filled(
                                onPressed: () => _openWhatsApp(phone, p.title),
                                icon: const Icon(Icons.chat, size: 16),
                                style: IconButton.styleFrom(
                                  backgroundColor: const Color(0xFF16A34A),
                                  padding: const EdgeInsets.all(8),
                                ),
                                tooltip: 'WhatsApp',
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Description
                    if (p.description.isNotEmpty) ...[
                      const Text(
                        'விளக்கம்',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF475569)),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        p.description,
                        style: const TextStyle(fontSize: 12.5, color: Color(0xFF334155), height: 1.4),
                      ),
                      const SizedBox(height: 14),
                    ],

                    // Land Features / Amenities
                    if (p.landFeatures.isNotEmpty) ...[
                      const Text(
                        'அம்சங்கள்',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF475569)),
                      ),
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: p.landFeatures.map((f) {
                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFFECFDF5),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: const Color(0xFFA7F3D0)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.check, size: 12, color: Color(0xFF059669)),
                                const SizedBox(width: 4),
                                Text(f, style: const TextStyle(fontSize: 11, color: Color(0xFF065F46), fontWeight: FontWeight.w600)),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            // Bottom Action Bar
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 6,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: _isProcessing
                  ? const Center(child: Padding(padding: EdgeInsets.all(8), child: CircularProgressIndicator()))
                  : Row(
                      children: [
                        if (isPending) ...[
                          // Approve Button
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () => _updateStatus('active'),
                              icon: const Icon(Icons.check_circle_rounded, size: 18),
                              label: const Text('ஒப்புதல் (Approve)'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF16A34A),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 11),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          // Reject Button
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () => _updateStatus('rejected'),
                              icon: const Icon(Icons.cancel_rounded, size: 18),
                              label: const Text('நிராகரி (Reject)'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFDC2626),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 11),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                            ),
                          ),
                        ] else if (isActive) ...[
                          // Reject / Deactivate Button
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () => _updateStatus('rejected'),
                              icon: const Icon(Icons.block_rounded, color: Color(0xFFDC2626), size: 18),
                              label: const Text('விளம்பரத்தை முடக்கு (Reject)', style: TextStyle(color: Color(0xFFDC2626))),
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: Color(0xFFDC2626)),
                                padding: const EdgeInsets.symmetric(vertical: 11),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          OutlinedButton(
                            onPressed: () => Navigator.of(context).pop(),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            child: const Text('மூடு'),
                          ),
                        ] else ...[
                          // Re-approve Button
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () => _updateStatus('active'),
                              icon: const Icon(Icons.replay_rounded, size: 18),
                              label: const Text('மீண்டும் ஒப்புதல் (Re-Approve)'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF16A34A),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 11),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          OutlinedButton(
                            onPressed: () => Navigator.of(context).pop(),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            child: const Text('மூடு'),
                          ),
                        ],
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSpecGrid(Property p) {
    final specs = <Map<String, String>>[];

    if (p.areaSqFt > 0) {
      specs.add({'title': 'பரப்பளவு', 'value': '${p.areaSqFt} Sq.Ft'});
    }
    if (p.landUnit != null && p.landUnitValue != null) {
      specs.add({'title': 'அளவு', 'value': '${p.landUnitValue} ${p.landUnit}'});
    }
    if (p.facing.isNotEmpty) {
      specs.add({'title': 'திசை (Facing)', 'value': p.facing});
    }
    if (p.approvalType != null && p.approvalType!.isNotEmpty) {
      specs.add({'title': 'அப்ரூவல்', 'value': p.approvalType!});
    }
    if (p.posterType != null && p.posterType!.isNotEmpty) {
      specs.add({'title': 'வகை', 'value': p.posterType!});
    }
    specs.add({'title': 'வங்கி கடன்', 'value': p.isBankLoanAvailable ? 'உண்டு' : 'இல்லை'});

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: specs.map((s) {
        return Container(
          width: 130,
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(s['title']!, style: const TextStyle(fontSize: 10, color: Color(0xFF64748B))),
              const SizedBox(height: 2),
              Text(
                s['value']!,
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildGalleryImage(String url) {
    if (url.startsWith('data:image')) {
      try {
        final b64 = url.split(',').last;
        return Image.memory(base64Decode(b64), fit: BoxFit.cover);
      } catch (_) {
        return const Icon(Icons.image_not_supported_rounded, color: Colors.grey);
      }
    }
    return Image.network(
      url,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => const Icon(Icons.terrain_rounded, color: Colors.grey),
    );
  }
}
