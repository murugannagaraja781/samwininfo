import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import '../../core/config/api_config.dart';
import '../../core/utils/currency_formatter.dart';
import '../../models/property.dart';
import 'admin_ad_alert_service.dart';
import 'admin_categories_screen.dart';
import 'admin_legal_requests_screen.dart';
import 'admin_listings_screen.dart';
import 'admin_live_chat_screen.dart';
import 'admin_property_detail_dialog.dart';
import 'admin_requirements_screen.dart';
import 'admin_settings_screen.dart';
import 'admin_users_screen.dart';
import 'incoming_ad_alert_dialog.dart';
import '../../state/app_state_providers.dart';

class AdminDashboardScreen extends ConsumerStatefulWidget {
  final int initialTab;
  final String? pendingPropertyId;

  const AdminDashboardScreen({
    super.key,
    this.initialTab = 0,
    this.pendingPropertyId,
  });

  static AdminDashboardScreenState? instance;

  static void openPendingTab({String? propertyId}) {
    if (instance != null && instance!.mounted) {
      instance!.switchToPendingTab(propertyId: propertyId);
    }
  }

  @override
  ConsumerState<AdminDashboardScreen> createState() => AdminDashboardScreenState();
}

class AdminDashboardScreenState extends ConsumerState<AdminDashboardScreen> {
  int _currentTabIndex = 0;
  int _pendingTabKey = 0;
  bool _isLoading = true;
  List<Property> _allProperties = [];
  int _pendingCount = 0;
  int _publishedCount = 0;
  int _rejectedCount = 0;
  int get publishedCount => _publishedCount;
  int get rejectedCount => _rejectedCount;
  final int _totalUsers = 1248;
  final int _totalLeads = 312;

  @override
  void initState() {
    super.initState();
    AdminDashboardScreen.instance = this;
    _currentTabIndex = widget.initialTab;
    _fetchAdminData(force: widget.initialTab == 3);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      AdminAdAlertService().startMonitoring(context);
      if (widget.pendingPropertyId != null && widget.pendingPropertyId!.isNotEmpty) {
        switchToPendingTab(propertyId: widget.pendingPropertyId);
      }
    });
  }

  void switchToPendingTab({String? propertyId}) {
    if (!mounted) return;
    setState(() {
      _currentTabIndex = 3; // Pending tab
      _pendingTabKey++;
    });
    _fetchAdminData(force: true);

    if (propertyId != null && propertyId.isNotEmpty) {
      Future.delayed(const Duration(milliseconds: 350), () async {
        if (!mounted) return;
        Property? prop = _allProperties.cast<Property?>().firstWhere(
          (p) => p?.id == propertyId,
          orElse: () => null,
        );

        if (prop == null) {
          try {
            final url = Uri.parse('${ApiConfig.instance.serverUrl}/properties.php?id=$propertyId');
            final res = await http.get(url).timeout(const Duration(seconds: 4));
            if (res.statusCode == 200) {
              final resData = jsonDecode(res.body);
              if (resData['property'] != null) {
                prop = Property.fromMap(resData['property'] as Map<String, dynamic>);
              }
            }
          } catch (_) {}
        }

        if (prop != null && mounted) {
          IncomingAdAlertDialog.show(
            context,
            prop,
            onHandled: () => _fetchAdminData(force: true),
          );
        }
      });
    }
  }

  @override
  void dispose() {
    if (AdminDashboardScreen.instance == this) {
      AdminDashboardScreen.instance = null;
    }
    AdminAdAlertService().stopMonitoring();
    super.dispose();
  }

  DateTime? _lastAdminFetchTime;

  void _applyProperties(List<Property> props) {
    int pending = 0;
    int active = 0;
    int rejected = 0;

    for (final p in props) {
      final s = p.status.toLowerCase();
      if (s == 'pending') {
        pending++;
      } else if (s == 'rejected') {
        rejected++;
      } else {
        active++;
      }
    }

    if (mounted) {
      setState(() {
        _allProperties = props;
        _pendingCount = pending;
        _publishedCount = active;
        _rejectedCount = rejected;
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchAdminData({bool force = false}) async {
    // 1. Instant offline-first load from Local Storage (0ms render, no waiting)
    if (_allProperties.isEmpty) {
      final cachedProps = ref.read(localStorageServiceProvider).getProperties();
      if (cachedProps.isNotEmpty) {
        _applyProperties(cachedProps);
      }
    }

    // 2. Prevent unwanted API calls if data was fetched within the last 3 minutes unless forced
    if (!force && _lastAdminFetchTime != null && DateTime.now().difference(_lastAdminFetchTime!).inMinutes < 3) {
      if (mounted) setState(() => _isLoading = false);
      return;
    }

    if (_allProperties.isEmpty) {
      setState(() => _isLoading = true);
    }

    try {
      final url = Uri.parse('${ApiConfig.instance.serverUrl}/properties.php?all=true');
      final res = await http.get(url).timeout(const Duration(seconds: 5));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final List<dynamic> list = data['data'] ?? data['properties'] ?? [];
        final props = list.map((m) => Property.fromMap(m as Map<String, dynamic>)).toList();

        // 3. Save to Local Storage
        await ref.read(localStorageServiceProvider).saveProperties(props);
        _lastAdminFetchTime = DateTime.now();

        _applyProperties(props);
        return;
      }
    } catch (e) {
      debugPrint('Admin fetch data error: $e');
    }
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    AdminAdAlertService().updateContext(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: _buildAdminAppBar(),
      drawer: _buildAdminDrawer(),
      body: _buildCurrentTabBody(),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  PreferredSizeWidget _buildAdminAppBar() {
    return AppBar(
      backgroundColor: const Color(0xFF0F3D6E),
      elevation: 2,
      leading: Builder(
        builder: (ctx) => IconButton(
          icon: const Icon(Icons.menu_rounded, color: Colors.white, size: 26),
          onPressed: () => Scaffold.of(ctx).openDrawer(),
        ),
      ),
      titleSpacing: 0,
      title: Row(
        children: [
          // Circular Logo
          Image.asset(
            'assets/images/admin_app_logo.png',
            height: 36,
            width: 36,
            errorBuilder: (_, __, ___) => const Icon(Icons.terrain_rounded, color: Colors.amber, size: 28),
          ),
          const SizedBox(width: 8),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'SamWin',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  letterSpacing: 0.3,
                ),
              ),
              Text(
                'LAND PROMOTERS',
                style: TextStyle(
                  fontSize: 9.5,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF93C5FD),
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
        ],
      ),
      actions: [
        // Refresh Button
        IconButton(
          icon: const Icon(Icons.refresh_rounded, color: Colors.white, size: 22),
          tooltip: 'புதுப்பி',
          onPressed: _fetchAdminData,
        ),
        // Notification Bell with Pending Badge
        Stack(
          alignment: Alignment.center,
          children: [
            IconButton(
              icon: const Icon(Icons.notifications_rounded, color: Colors.white, size: 22),
              tooltip: 'Pending விளம்பரங்கள் ($_pendingCount)',
              onPressed: () {
                setState(() => _currentTabIndex = 3);
              },
            ),
            if (_pendingCount > 0)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFFDC2626),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.white, width: 1.5),
                  ),
                  constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
                  child: Center(
                    child: Text(
                      '$_pendingCount',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 9.5,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
        // Admin dropdown pill
        Container(
          margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.account_circle, color: Colors.white, size: 18),
              SizedBox(width: 4),
              Text(
                'Admin ▾',
                style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCurrentTabBody() {
    if (_currentTabIndex == 1) {
      return const AdminListingsScreen(initialFilter: 'all');
    }
    if (_currentTabIndex == 2) {
      return const AdminLiveChatScreen();
    }
    if (_currentTabIndex == 3) {
      return AdminListingsScreen(
        key: ValueKey('admin_pending_$_pendingTabKey'),
        initialFilter: 'pending',
        forceRefresh: true,
      );
    }
    if (_currentTabIndex == 4) {
      return _buildAdminProfileTab();
    }

    return RefreshIndicator(
      onRefresh: () => _fetchAdminData(force: true),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Dashboard Header Row
            _buildDashboardHeaderRow(),
            const SizedBox(height: 14),

            // 2. 4 Stat Cards (Users, Properties, Leads, Pending)
            _buildStatCardsGrid(),
            const SizedBox(height: 18),

            // 3. 12 Action Grid
            _buildActionGrid(),
            const SizedBox(height: 22),

            // 4. Recent Listings with Status Badges
            _buildRecentListingsSection(),
          ],
        ),
      ),
    );
  }

  // Header with "Dashboard / Welcome Back" and Date Badge
  Widget _buildDashboardHeaderRow() {
    final now = DateTime.now();
    final dateStr = DateFormat('dd MMM yyyy').format(now);
    final dayStr = DateFormat('EEEE').format(now);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Dashboard',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w900,
                color: Color(0xFF0F172A),
              ),
            ),
            SizedBox(height: 2),
            Text(
              'Welcome Back, Admin',
              style: TextStyle(
                fontSize: 12.5,
                color: Color(0xFF64748B),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFE2E8F0)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 4,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Row(
            children: [
              const Icon(Icons.calendar_month_rounded, size: 16, color: Color(0xFF0284C7)),
              const SizedBox(width: 6),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    dateStr,
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                  ),
                  Text(
                    dayStr,
                    style: const TextStyle(fontSize: 9.5, color: Color(0xFF64748B)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  // 4 Top Stat Cards matching Image 1
  Widget _buildStatCardsGrid() {
    final pendingCount = _pendingCount;
    final propCount = _allProperties.length;

    return Row(
      children: [
        // 1. Users (Blue)
        Expanded(
          child: _buildStatCard(
            title: 'Users',
            value: '$_totalUsers',
            growth: '↑ 12%',
            icon: Icons.groups_rounded,
            color: const Color(0xFF0284C7),
          ),
        ),
        const SizedBox(width: 8),

        // 2. Properties (Green)
        Expanded(
          child: _buildStatCard(
            title: 'Properties',
            value: '$propCount',
            growth: '↑ 8%',
            icon: Icons.home_work_rounded,
            color: const Color(0xFF059669),
            onTap: () {
              setState(() => _currentTabIndex = 1);
            },
          ),
        ),
        const SizedBox(width: 8),

        // 3. Leads (Orange)
        Expanded(
          child: _buildStatCard(
            title: 'Leads',
            value: '$_totalLeads',
            growth: '↑ 15%',
            icon: Icons.chat_bubble_outline_rounded,
            color: const Color(0xFFEA580C),
          ),
        ),
        const SizedBox(width: 8),

        // 4. Pending Approval (Purple/Red)
        Expanded(
          child: _buildStatCard(
            title: 'Pending',
            value: '$pendingCount',
            growth: pendingCount > 0 ? '⚠️ $pendingCount புதியது' : '0 நிலுவை',
            icon: Icons.schedule_rounded,
            color: pendingCount > 0 ? const Color(0xFFDC2626) : const Color(0xFF7C3AED),
            onTap: () {
              setState(() => _currentTabIndex = 3);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required String growth,
    required IconData icon,
    required Color color,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.3),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: Colors.white, size: 24),
            const SizedBox(height: 6),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 10.5,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              growth,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 9.5,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 12 Action Grid in 4 Columns
  Widget _buildActionGrid() {
    final items = [
      {'title': 'Users', 'icon': Icons.groups_rounded, 'color': const Color(0xFF0284C7), 'filter': 'users'},
      {'title': 'Properties', 'icon': Icons.home_rounded, 'color': const Color(0xFF059669), 'filter': 'all'},
      {'title': 'Pending', 'icon': Icons.schedule_rounded, 'color': const Color(0xFFD97706), 'filter': 'pending'},
      {'title': 'Published', 'icon': Icons.campaign_rounded, 'color': const Color(0xFF2563EB), 'filter': 'published'},
      {'title': 'Rejected', 'icon': Icons.cancel_rounded, 'color': const Color(0xFFDC2626), 'filter': 'rejected'},
      {'title': 'Paid Ads', 'icon': Icons.star_rounded, 'color': const Color(0xFF7C3AED), 'filter': 'paid'},
      {'title': 'Leads', 'icon': Icons.forum_rounded, 'color': const Color(0xFF0D9488), 'filter': 'leads'},
      {'title': 'Reports', 'icon': Icons.warning_amber_rounded, 'color': const Color(0xFFE11D48), 'filter': 'reports'},
      {'title': 'Location', 'icon': Icons.location_on_rounded, 'color': const Color(0xFF0284C7), 'filter': 'location'},
      {'title': 'Categories', 'icon': Icons.grid_view_rounded, 'color': const Color(0xFF059669), 'filter': 'categories'},
      {'title': 'Notifications', 'icon': Icons.notifications_rounded, 'color': const Color(0xFFE11D48), 'filter': 'notifications'},
      {'title': 'Settings', 'icon': Icons.settings_rounded, 'color': const Color(0xFF475569), 'filter': 'settings'},
    ];

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: items.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          mainAxisSpacing: 10,
          crossAxisSpacing: 8,
          childAspectRatio: 0.88,
        ),
        itemBuilder: (context, index) {
          final item = items[index];
          final color = item['color'] as Color;
          return InkWell(
            onTap: () => _onActionItemTap(item['filter'] as String),
            borderRadius: BorderRadius.circular(12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(item['icon'] as IconData, color: color, size: 24),
                ),
                const SizedBox(height: 6),
                Text(
                  item['title'] as String,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF334155),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _onActionItemTap(String filter) {
    if (filter == 'leads') {
      setState(() => _currentTabIndex = 2); // Live Chat / Leads
    } else if (filter == 'pending' || filter == 'all' || filter == 'published' || filter == 'rejected' || filter == 'paid') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => AdminListingsScreen(initialFilter: filter == 'paid' ? 'published' : filter),
        ),
      );
    } else if (filter == 'users') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const AdminUsersScreen()),
      );
    } else if (filter == 'categories') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const AdminCategoriesScreen()),
      );
    } else if (filter == 'settings') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const AdminSettingsScreen()),
      );
    } else if (filter == 'reports') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const AdminRequirementsScreen()),
      );
    } else if (filter == 'notifications') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const AdminLegalRequestsScreen()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('⚡ $filter பக்கம் திறக்கப்படுகிறது...'),
          duration: const Duration(seconds: 1),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  // Recent Listings Section
  Widget _buildRecentListingsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Recent Listings',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w900,
                color: Color(0xFF0F172A),
              ),
            ),
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AdminListingsScreen(initialFilter: 'all')),
                );
              },
              child: const Text(
                'View All >',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0284C7),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        if (_isLoading)
          const Center(child: Padding(padding: EdgeInsets.all(24), child: CircularProgressIndicator()))
        else if (_allProperties.isEmpty)
          const Center(child: Text('விளம்பரங்கள் இல்லை.'))
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _allProperties.take(6).length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final prop = _allProperties[index];
              return _buildRecentListingCard(prop);
            },
          ),
      ],
    );
  }

  Widget _buildRecentListingCard(Property prop) {
    final status = prop.status.toLowerCase();
    final isPending = status == 'pending';
    final isRejected = status == 'rejected';

    final badgeText = isPending ? 'Pending' : (isRejected ? 'Rejected' : 'Live');
    final badgeColor = isPending
        ? const Color(0xFFD97706)
        : (isRejected ? const Color(0xFFDC2626) : const Color(0xFF16A34A));

    final price = CurrencyFormatter.formatIndianPrice(prop.price, isRental: prop.isRental);

    return InkWell(
      onTap: () {
        AdminPropertyDetailDialog.show(context, prop, onHandled: _fetchAdminData);
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE2E8F0)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Row(
          children: [
            // Thumbnail
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Container(
                width: 70,
                height: 70,
                color: Colors.grey.shade200,
                child: prop.primaryImageUrl != null && prop.primaryImageUrl!.isNotEmpty
                    ? Image.network(prop.primaryImageUrl!, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const Icon(Icons.terrain_rounded))
                    : const Icon(Icons.terrain_rounded, color: Colors.grey),
              ),
            ),
            const SizedBox(width: 12),

            // Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    prop.title,
                    style: const TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E293B),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    prop.location,
                    style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        '${prop.areaSqFt} Sq.Ft  |  ',
                        style: const TextStyle(fontSize: 11, color: Color(0xFF475569), fontWeight: FontWeight.w600),
                      ),
                      Text(
                        price,
                        style: const TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF047857),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Status Badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: badgeColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: badgeColor.withValues(alpha: 0.4)),
              ),
              child: Text(
                badgeText,
                style: TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w800,
                  color: badgeColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Bottom Navigation Bar matching Image 1
  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade200)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(0, Icons.home_rounded, 'Home'),
              _buildNavItem(1, Icons.list_alt_rounded, 'All Ads'),
              _buildNavItem(2, Icons.chat_bubble_rounded, 'Live Chat'),
              _buildNavItem(3, Icons.hourglass_top_rounded, 'Pending'),
              _buildNavItem(4, Icons.person_rounded, 'Profile'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final isSelected = _currentTabIndex == index;
    Widget iconWidget = Icon(
      icon,
      color: isSelected ? const Color(0xFF0284C7) : const Color(0xFF94A3B8),
      size: 22,
    );

    if (index == 3 && _pendingCount > 0) {
      iconWidget = Badge(
        label: Text(
          '$_pendingCount',
          style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: Colors.white),
        ),
        backgroundColor: const Color(0xFFDC2626),
        child: iconWidget,
      );
    }

    return InkWell(
      onTap: () => setState(() => _currentTabIndex = index),
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            iconWidget,
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? const Color(0xFF0284C7) : const Color(0xFF64748B),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Admin Drawer Sidebar matching Image 1
  Widget _buildAdminDrawer() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF0F3D6E), Color(0xFF0284C7)],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset('assets/images/admin_app_logo.png', height: 48, width: 48),
                const SizedBox(height: 10),
                const Text(
                  'தென்காசி கனவுகள்',
                  style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const Text(
                  'Super Admin Control Panel',
                  style: TextStyle(color: Colors.white70, fontSize: 11),
                ),
              ],
            ),
          ),
          _buildDrawerTile(Icons.dashboard_rounded, 'Dashboard', () => Navigator.pop(context)),
          _buildDrawerTile(Icons.groups_rounded, 'Users / Owners / Agents', () {
            Navigator.pop(context);
            Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminUsersScreen()));
          }),
          _buildDrawerTile(Icons.home_work_rounded, 'Property Listings', () {
            Navigator.pop(context);
            setState(() => _currentTabIndex = 1);
          }),
          _buildDrawerTile(Icons.hourglass_top_rounded, 'Pending Approval', () {
            Navigator.pop(context);
            setState(() => _currentTabIndex = 3);
          }),
          _buildDrawerTile(Icons.campaign_rounded, 'Published Ads', () {
            Navigator.pop(context);
            Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminListingsScreen(initialFilter: 'published')));
          }),
          _buildDrawerTile(Icons.cancel_rounded, 'Rejected Ads', () {
            Navigator.pop(context);
            Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminListingsScreen(initialFilter: 'rejected')));
          }),
          _buildDrawerTile(Icons.grid_view_rounded, 'Categories Management', () {
            Navigator.pop(context);
            Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminCategoriesScreen()));
          }),
          _buildDrawerTile(Icons.chat_bubble_rounded, 'Live User Chat', () {
            Navigator.pop(context);
            setState(() => _currentTabIndex = 2);
          }),
          _buildDrawerTile(Icons.assignment_rounded, 'Buyer Requirements', () {
            Navigator.pop(context);
            Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminRequirementsScreen()));
          }),
          _buildDrawerTile(Icons.gavel_rounded, 'Legal Advice Requests', () {
            Navigator.pop(context);
            Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminLegalRequestsScreen()));
          }),
          const Divider(),
          _buildDrawerTile(Icons.settings_rounded, 'Settings', () {
            Navigator.pop(context);
            Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminSettingsScreen()));
          }),
        ],
      ),
    );
  }

  Widget _buildDrawerTile(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF0F3D6E), size: 22),
      title: Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
      dense: true,
      onTap: onTap,
    );
  }

  Widget _buildAdminProfileTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Center(
          child: Column(
            children: [
              Image.asset('assets/images/admin_app_logo.png', height: 80, width: 80),
              const SizedBox(height: 12),
              const Text(
                'Super Administrator',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const Text(
                'admin@tenkasidreams.com',
                style: TextStyle(color: Colors.grey, fontSize: 13),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Card(
          child: Column(
            children: [
              ListTile(
                leading: const Icon(Icons.security),
                title: const Text('Admin Portal Security'),
                subtitle: const Text('Active Session'),
                trailing: const Icon(Icons.check_circle, color: Colors.green),
              ),
              ListTile(
                leading: const Icon(Icons.notifications_active),
                title: const Text('Real-time Ad Alarm'),
                subtitle: const Text('Continuous Ringing Enabled'),
                trailing: const Icon(Icons.volume_up, color: Colors.blue),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
