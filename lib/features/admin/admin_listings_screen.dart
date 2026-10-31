import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import '../../core/config/api_config.dart';
import '../../core/utils/currency_formatter.dart';
import '../../models/property.dart';
import '../../state/app_state_providers.dart';
import 'admin_ad_alert_service.dart';
import 'admin_property_detail_dialog.dart';

class AdminListingsScreen extends ConsumerStatefulWidget {
  final String initialFilter;
  final bool forceRefresh;

  const AdminListingsScreen({
    super.key,
    this.initialFilter = 'all',
    this.forceRefresh = false,
  });

  @override
  ConsumerState<AdminListingsScreen> createState() => _AdminListingsScreenState();
}

class _AdminListingsScreenState extends ConsumerState<AdminListingsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Property> _properties = [];
  bool _isLoading = true;
  DateTime? _lastFetchTime;

  @override
  void initState() {
    super.initState();
    final initialIndex = widget.initialFilter == 'pending'
        ? 1
        : (widget.initialFilter == 'published'
            ? 2
            : (widget.initialFilter == 'rejected' ? 3 : 0));

    _tabController = TabController(length: 4, vsync: this, initialIndex: initialIndex);
    _fetchProperties(force: widget.initialFilter == 'pending' || widget.forceRefresh);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _fetchProperties({bool force = false}) async {
    // 1. Instant offline-first load from Local Storage (0ms render)
    if (_properties.isEmpty) {
      final cachedProps = ref.read(localStorageServiceProvider).getProperties();
      if (cachedProps.isNotEmpty) {
        setState(() {
          _properties = cachedProps;
          _isLoading = false;
        });
      }
    }

    // 2. Prevent unwanted API calls if data was fetched within the last 3 minutes unless forced
    if (!force && _lastFetchTime != null && DateTime.now().difference(_lastFetchTime!).inMinutes < 3) {
      if (mounted) setState(() => _isLoading = false);
      return;
    }

    if (_properties.isEmpty) {
      setState(() => _isLoading = true);
    }

    try {
      final url = Uri.parse('${ApiConfig.instance.serverUrl}/properties.php?all=true');
      final res = await http.get(url).timeout(const Duration(seconds: 5));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final List<dynamic> list = data['data'] ?? data['properties'] ?? [];
        final props = list.map((m) => Property.fromMap(m as Map<String, dynamic>)).toList();

        // 3. Cache to Local Storage
        await ref.read(localStorageServiceProvider).saveProperties(props);
        _lastFetchTime = DateTime.now();

        if (mounted) {
          setState(() {
            _properties = props;
            _isLoading = false;
          });
        }
        return;
      }
    } catch (e) {
      debugPrint('Error fetching admin properties: $e');
    }
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  final Set<String> _updatingIds = {};

  Future<void> _updateStatus(String propId, String status) async {
    if (_updatingIds.contains(propId)) return;
    setState(() => _updatingIds.add(propId));

    // Mark handled in alert service so alert never sounds again
    AdminAdAlertService().markHandled(propId);

    // Optimistic UI update: immediately change status in local list
    final idx = _properties.indexWhere((p) => p.id == propId);
    if (idx != -1) {
      _properties[idx] = _properties[idx].copyWith(status: status);
    }
    setState(() {});

    try {
      final url = Uri.parse(
        '${ApiConfig.instance.serverUrl}/properties.php?action=update_status&id=$propId&status=$status',
      );
      final res = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'id': propId, 'status': status}),
      );
      if (res.statusCode == 200) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                status == 'active'
                    ? '✅ விளம்பரம் ஒப்புதல் அளிக்கப்பட்டு நேரலை செய்யப்பட்டது!'
                    : '❌ விளம்பரம் நிராகரிக்கப்பட்டது!',
              ),
              backgroundColor: status == 'active' ? Colors.green.shade700 : Colors.red.shade700,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('Error updating status: $e');
    } finally {
      if (mounted) {
        setState(() => _updatingIds.remove(propId));
      }
    }
  }

  List<Property> _getFilteredProperties(int tabIndex) {
    if (tabIndex == 1) {
      return _properties.where((p) => p.status.toLowerCase() == 'pending').toList();
    } else if (tabIndex == 2) {
      return _properties.where((p) => p.status.toLowerCase() == 'active' || p.status.toLowerCase() == 'published').toList();
    } else if (tabIndex == 3) {
      return _properties.where((p) => p.status.toLowerCase() == 'rejected').toList();
    }
    return _properties;
  }

  @override
  Widget build(BuildContext context) {
    final pendingCount = _properties.where((p) => p.status.toLowerCase() == 'pending').length;
    final liveCount = _properties.where((p) => p.status.toLowerCase() == 'active' || p.status.toLowerCase() == 'published').length;
    final rejectedCount = _properties.where((p) => p.status.toLowerCase() == 'rejected').length;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F3D6E),
        title: const Text(
          'விளம்பரங்கள் மேலாண்மை',
          style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Colors.white),
            onPressed: _fetchProperties,
            tooltip: 'புதுப்பி',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.amber,
          indicatorWeight: 3,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          isScrollable: true,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          tabs: [
            Tab(text: 'அனைத்தும் (${_properties.length})'),
            Tab(text: '⏳ Pending ($pendingCount)'),
            Tab(text: '✅ Live ($liveCount)'),
            Tab(text: '❌ Rejected ($rejectedCount)'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildListTab(0),
                _buildListTab(1),
                _buildListTab(2),
                _buildListTab(3),
              ],
            ),
    );
  }

  Widget _buildListTab(int index) {
    final filtered = _getFilteredProperties(index);

    if (filtered.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox_rounded, size: 48, color: Colors.grey.shade400),
            const SizedBox(height: 8),
            Text(
              'விளம்பரங்கள் இல்லை',
              style: TextStyle(color: Colors.grey.shade600, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => _fetchProperties(force: true),
      child: ListView.separated(
        padding: const EdgeInsets.all(12),
        itemCount: filtered.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (context, i) {
          final p = filtered[i];
          final priceStr = CurrencyFormatter.formatIndianPrice(p.price, isRental: p.isRental);
          final status = p.status.toLowerCase();
          final isPending = status == 'pending';
          final isRejected = status == 'rejected';

          return Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isPending ? const Color(0xFFFDE68A) : const Color(0xFFE2E8F0),
                width: isPending ? 1.5 : 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.02),
                  blurRadius: 4,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Thumbnail
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        width: 80,
                        height: 80,
                        color: Colors.grey.shade200,
                        child: p.primaryImageUrl != null && p.primaryImageUrl!.isNotEmpty
                            ? Image.network(
                                p.primaryImageUrl!,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => const Icon(Icons.terrain_rounded),
                              )
                            : const Icon(Icons.terrain_rounded, color: Colors.grey),
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  p.title,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                    color: Color(0xFF1E293B),
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              // Status pill
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: isPending
                                      ? const Color(0xFFFEF3C7)
                                      : (isRejected ? const Color(0xFFFEE2E2) : const Color(0xFFDCFCE7)),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  isPending ? 'Pending' : (isRejected ? 'Rejected' : 'Live'),
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: isPending
                                        ? const Color(0xFFD97706)
                                        : (isRejected ? const Color(0xFFDC2626) : const Color(0xFF16A34A)),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(p.location, style: const TextStyle(fontSize: 11.5, color: Color(0xFF64748B)), maxLines: 1),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Text(priceStr, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: Color(0xFF047857))),
                              const SizedBox(width: 8),
                              Text('${p.areaSqFt} Sq.Ft', style: const TextStyle(fontSize: 11, color: Color(0xFF475569))),
                            ],
                          ),
                          if (p.contactPhone != null && p.contactPhone!.isNotEmpty) ...[
                            const SizedBox(height: 2),
                            Text('📞 ${p.contactPhone}', style: const TextStyle(fontSize: 11, color: Color(0xFF0284C7), fontWeight: FontWeight.bold)),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Actions Bar
                Row(
                  children: [
                    // Clean inspect dialog without alarm sound
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => AdminPropertyDetailDialog.show(
                          context,
                          p,
                          onHandled: _fetchProperties,
                        ),
                        icon: const Icon(Icons.visibility_rounded, size: 16),
                        label: const Text('விபரம்', style: TextStyle(fontSize: 12)),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          minimumSize: Size.zero,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),

                    if (isPending) ...[
                      // Quick Accept
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _updateStatus(p.id, 'active'),
                          icon: const Icon(Icons.check_circle_rounded, size: 16),
                          label: const Text('ஒப்புதல்', style: TextStyle(fontSize: 12)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF16A34A),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            minimumSize: Size.zero,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),

                      // Quick Reject
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _updateStatus(p.id, 'rejected'),
                          icon: const Icon(Icons.cancel_rounded, size: 16),
                          label: const Text('நிராகரி', style: TextStyle(fontSize: 12)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFDC2626),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            minimumSize: Size.zero,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
