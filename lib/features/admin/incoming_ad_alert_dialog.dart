import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import '../../core/config/api_config.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/currency_formatter.dart';
import '../../models/property.dart';
import 'admin_ad_alert_service.dart';

class IncomingAdAlertDialog extends StatefulWidget {
  final Property property;
  final VoidCallback? onHandled;

  const IncomingAdAlertDialog({
    super.key,
    required this.property,
    this.onHandled,
  });

  static bool _isShowing = false;

  static Future<void> show(BuildContext context, Property property, {VoidCallback? onHandled}) async {
    if (_isShowing) return;
    _isShowing = true;
    try {
      await showDialog(
        context: context,
        barrierDismissible: false,
        barrierColor: Colors.black.withValues(alpha: 0.85),
        builder: (_) => IncomingAdAlertDialog(
          property: property,
          onHandled: onHandled,
        ),
      );
    } finally {
      _isShowing = false;
      try {
        FlutterRingtonePlayer().stop();
      } catch (_) {}
    }
  }

  @override
  State<IncomingAdAlertDialog> createState() => _IncomingAdAlertDialogState();
}

class _IncomingAdAlertDialogState extends State<IncomingAdAlertDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  bool _isProcessing = false;
  bool _isMuted = false;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Play loud single-shot alarm ringtone once (not infinite loop)
    _startAlarm();
  }

  void _startAlarm() {
    try {
      FlutterRingtonePlayer().play(
        android: AndroidSounds.alarm,
        ios: IosSounds.alarm,
        looping: false,
        volume: 1.0,
      );
    } catch (e) {
      debugPrint('Error playing alarm: $e');
    }
  }

  void _stopAlarm() {
    try {
      FlutterRingtonePlayer().stop();
    } catch (e) {
      debugPrint('Error stopping alarm: $e');
    }
  }

  @override
  void dispose() {
    _stopAlarm();
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _handleAction(String status) async {
    if (_isProcessing) return;
    _stopAlarm();
    setState(() => _isProcessing = true);

    try {
      // Mark as handled immediately so alert never sounds again
      AdminAdAlertService().markHandled(widget.property.id);

      final url = Uri.parse(
        '${ApiConfig.instance.serverUrl}/properties.php?action=update_status&id=${widget.property.id}&status=$status',
      );
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'id': widget.property.id,
          'status': status,
        }),
      );

      debugPrint('Ad status update response: ${response.statusCode} ${response.body}');
    } catch (e) {
      debugPrint('Error updating ad status: $e');
    }

    if (mounted) {
      setState(() => _isProcessing = false);
      widget.onHandled?.call();
      Navigator.of(context).pop();

      final msg = status == 'active'
          ? '✅ விளம்பரம் ஒப்புதல் அளிக்கப்பட்டு நேரலை செய்யப்பட்டது!'
          : (status == 'rejected'
              ? '❌ விளம்பரம் நிராகரிக்கப்பட்டது!'
              : '⏳ விளம்பரம் காத்திருப்புப் பட்டியலில் வைக்கப்பட்டது.');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(msg, style: const TextStyle(fontWeight: FontWeight.bold)),
          backgroundColor: status == 'active'
              ? const Color(0xFF2E7D32)
              : (status == 'rejected' ? Colors.red.shade700 : Colors.amber.shade800),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _callSeller(String phone) async {
    final clean = phone.replaceAll(RegExp(r'[^0-9]'), '');
    final uri = Uri.parse('tel:$clean');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.property;
    final priceStr = CurrencyFormatter.formatIndianPrice(p.price, isRental: p.isRental);

    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) {
          _stopAlarm();
        }
      },
      child: Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: Colors.white,
        child: Container(
          constraints: const BoxConstraints(maxWidth: 480),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Emergency Alarm Header Banner
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFFDC2626), Color(0xFFB91C1C)],
                  ),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                ),
                child: Row(
                  children: [
                    ScaleTransition(
                      scale: _pulseAnimation,
                      child: Container(
                        padding: const EdgeInsets.all(7),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.notification_important_rounded,
                          color: Color(0xFFDC2626),
                          size: 22,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '🚨 புதிய விளம்பரம் வந்துள்ளது!',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          Text(
                            'Super Admin ஒப்புதலுக்காக காத்திருக்கிறது...',
                            style: TextStyle(color: Colors.white70, fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                    // Mute Button
                    IconButton(
                      icon: Icon(
                        _isMuted ? Icons.volume_off_rounded : Icons.volume_up_rounded,
                        color: Colors.white,
                        size: 22,
                      ),
                      tooltip: _isMuted ? 'Muted' : 'சத்தத்தை நிறுத்து',
                      onPressed: () {
                        _stopAlarm();
                        setState(() => _isMuted = true);
                      },
                    ),
                    // Close Button
                    IconButton(
                      icon: const Icon(Icons.close_rounded, color: Colors.white, size: 22),
                      tooltip: 'மூடு',
                      onPressed: () {
                        _stopAlarm();
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                ),
              ),

              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Property Image preview
                      ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          height: 180,
                          width: double.infinity,
                          color: Colors.grey.shade100,
                          child: _buildPropertyImage(p),
                        ),
                      ),
                      const SizedBox(height: 14),

                      // Title & Price
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              p.title,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF0F172A),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            priceStr,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF047857),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      // Location & Details
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.location_on, size: 16, color: Color(0xFF0284C7)),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    p.location,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF334155),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            if (p.latitude != null && p.longitude != null) ...[
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(Icons.gps_fixed_rounded, size: 14, color: Color(0xFF10B981)),
                                  const SizedBox(width: 6),
                                  Text(
                                    'GPS: ${p.latitude!.toStringAsFixed(4)}° N, ${p.longitude!.toStringAsFixed(4)}° E',
                                    style: const TextStyle(
                                      fontSize: 11.5,
                                      color: Color(0xFF059669),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(Icons.category_rounded, size: 14, color: Color(0xFFD97706)),
                                const SizedBox(width: 6),
                                Text(
                                  'வகை: ${p.propertyType} • ${p.areaSqFt} Sq.Ft',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF64748B),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Poster Details with direct call
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFECFDF5),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFA7F3D0)),
                        ),
                        child: Row(
                          children: [
                            const CircleAvatar(
                              radius: 18,
                              backgroundColor: Color(0xFF10B981),
                              child: Icon(Icons.person, color: Colors.white, size: 20),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    (p.agent?.name != null && p.agent!.name.isNotEmpty)
                                        ? p.agent!.name
                                        : 'விளம்பரதாரர் (Seller)',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                      color: Color(0xFF065F46),
                                    ),
                                  ),
                                  Text(
                                    (p.contactPhone != null && p.contactPhone!.isNotEmpty)
                                        ? p.contactPhone!
                                        : (p.agent.phone.isNotEmpty ? p.agent.phone : 'எண் இல்லை'),
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Color(0xFF047857),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (p.contactPhone != null && p.contactPhone!.isNotEmpty)
                              IconButton(
                                style: IconButton.styleFrom(
                                  backgroundColor: const Color(0xFF047857),
                                ),
                                icon: const Icon(Icons.phone_rounded, color: Colors.white, size: 18),
                                onPressed: () => _callSeller(p.contactPhone!),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // 3 Critical Action Buttons (Accept, Reject, Pending)
              Container(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: const BorderRadius.vertical(bottom: Radius.circular(24)),
                  border: Border(top: BorderSide(color: Colors.grey.shade200)),
                ),
                child: _isProcessing
                    ? const Center(
                        child: Padding(
                          padding: EdgeInsets.all(12),
                          child: CircularProgressIndicator(),
                        ),
                      )
                    : Column(
                        children: [
                          // 1. Accept (Approve & Live)
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: () => _handleAction('active'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF16A34A),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                elevation: 2,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              icon: const Icon(Icons.check_circle_rounded, size: 22),
                              label: const Text(
                                '✅ ஒப்புதல் அளி (Accept & Go Live)',
                                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),

                          Row(
                            children: [
                              // 2. Reject
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: () => _handleAction('rejected'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFFDC2626),
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  icon: const Icon(Icons.cancel_rounded, size: 18),
                                  label: const Text(
                                    '❌ நிராகரி (Reject)',
                                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),

                              // 3. Keep Pending (Mute Alarm)
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: () => _handleAction('pending'),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: const Color(0xFFD97706),
                                    side: const BorderSide(color: Color(0xFFD97706), width: 1.5),
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  icon: const Icon(Icons.hourglass_top_rounded, size: 18),
                                  label: const Text(
                                    '⏳ காத்திருப்பு (Pending)',
                                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPropertyImage(Property p) {
    final imgUrl = p.imageUrl ?? (p.imageUrls.isNotEmpty ? p.imageUrls.first : null);
    if (imgUrl != null && imgUrl.isNotEmpty) {
      return Image.network(
        imgUrl,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => _buildImageFallback(),
      );
    }
    if (p.customImageBase64 != null && p.customImageBase64!.isNotEmpty) {
      try {
        final bytes = base64Decode(p.customImageBase64!);
        return Image.memory(bytes, fit: BoxFit.cover);
      } catch (_) {}
    }
    return _buildImageFallback();
  }

  Widget _buildImageFallback() {
    return Container(
      color: Colors.grey.shade200,
      child: const Center(
        child: Icon(Icons.image_not_supported_rounded, size: 48, color: Colors.grey),
      ),
    );
  }
}
