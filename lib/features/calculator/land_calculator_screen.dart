import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/land_units.dart';

class LandCalculatorScreen extends ConsumerStatefulWidget {
  const LandCalculatorScreen({super.key});

  @override
  ConsumerState<LandCalculatorScreen> createState() => _LandCalculatorScreenState();
}

class _LandCalculatorScreenState extends ConsumerState<LandCalculatorScreen> {
  final TextEditingController _inputController = TextEditingController(text: '1');
  String _selectedFromUnit = 'Acres';

  final List<String> _units = [
    'Acres',
    'Cents',
    'குழி (Kuzhi)',
    'ஹெக்டேர் (Hectare)',
    'Sq.Ft',
    'Grounds',
  ];

  double get _inputValue => double.tryParse(_inputController.text.trim()) ?? 0.0;

  int get _calculatedSqFt => LandUnitConverter.toSqFt(_inputValue, _selectedFromUnit);

  @override
  void dispose() {
    _inputController.dispose();
    super.dispose();
  }

  void _setPreset(double val, String unit) {
    setState(() {
      _selectedFromUnit = unit;
      _inputController.text = val % 1 == 0 ? val.toInt().toString() : val.toString();
    });
  }

  void _copySummary(BuildContext context) {
    final sqFt = _calculatedSqFt;
    final acres = LandUnitConverter.fromSqFt(sqFt, 'Acres');
    final cents = LandUnitConverter.fromSqFt(sqFt, 'Cents');
    final kuzhi = LandUnitConverter.fromSqFt(sqFt, 'Kuzhi');
    final hectare = LandUnitConverter.fromSqFt(sqFt, 'Hectare');

    final text = '''
📐 தென்காசி நில அளவீடு (Tenkasi Land Measurement):
──────────────────────
• அளவு: $_inputValue $_selectedFromUnit
• சென்ட் (Cent): $cents
• குழி (Kuzhi): $kuzhi
• ஏக்கர் (Acre): $acres
• ஹெக்டேர் (Hectare): $hectare
• சதுர அடி (Sq.Ft): $sqFt sq.ft
──────────────────────
SamWin
''';
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('அளவீடு விவரங்கள் நகலெடுக்கப்பட்டது (Copied)!'),
        backgroundColor: AppColors.primary,
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final sqFt = _calculatedSqFt;
    final cents = LandUnitConverter.fromSqFt(sqFt, 'Cents');
    final kuzhi = LandUnitConverter.fromSqFt(sqFt, 'Kuzhi');
    final acres = LandUnitConverter.fromSqFt(sqFt, 'Acres');
    final hectare = LandUnitConverter.fromSqFt(sqFt, 'Hectare');
    final grounds = LandUnitConverter.fromSqFt(sqFt, 'Grounds');

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'நில அளவை மாற்றி',
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
            ),
            Text(
              'Land Unit Calculator (Kuzhi, Cent, Acre, Hectare)',
              style: TextStyle(fontSize: 11, color: Colors.white.withValues(alpha: 0.85)),
            ),
          ],
        ),
        backgroundColor: AppColors.primaryDark,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.copy_rounded),
            tooltip: 'Copy Calculation',
            onPressed: () => _copySummary(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Input Card
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'உள்ளீடு அளவு மற்றும் அலகு (Enter Value & Unit)',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      // Value Input
                      Expanded(
                        flex: 5,
                        child: TextField(
                          controller: _inputController,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: AppColors.primaryDark,
                          ),
                          decoration: InputDecoration(
                            hintText: '0',
                            filled: true,
                            fillColor: const Color(0xFFF1F5F9),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          onChanged: (_) => setState(() {}),
                        ),
                      ),
                      const SizedBox(width: 10),
                      // Unit Dropdown
                      Expanded(
                        flex: 6,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          decoration: BoxDecoration(
                            color: AppColors.primaryLight,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: _selectedFromUnit,
                              isExpanded: true,
                              icon: const Icon(Icons.arrow_drop_down, color: AppColors.primaryDark),
                              style: const TextStyle(
                                color: AppColors.primaryDark,
                                fontWeight: FontWeight.w700,
                                fontSize: 13.5,
                              ),
                              items: _units.map((unit) {
                                return DropdownMenuItem(
                                  value: unit,
                                  child: Text(unit, overflow: TextOverflow.ellipsis),
                                );
                              }).toList(),
                              onChanged: (val) {
                                if (val != null) {
                                  setState(() => _selectedFromUnit = val);
                                }
                              },
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Quick Presets
                  const Text(
                    'விரைவு அளவுகள் (Quick Presets):',
                    style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: AppColors.textMuted),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: [
                      _buildPresetChip('1 Cent', 1, 'Cents'),
                      _buildPresetChip('3 Kuzhi (குழி)', 3, 'குழி (Kuzhi)'),
                      _buildPresetChip('5 Cents', 5, 'Cents'),
                      _buildPresetChip('10 Cents', 10, 'Cents'),
                      _buildPresetChip('1 Acre', 1, 'Acres'),
                      _buildPresetChip('300 Kuzhi', 300, 'குழி (Kuzhi)'),
                      _buildPresetChip('1 Hectare', 1, 'ஹெக்டேர் (Hectare)'),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Live Conversion Matrix Title
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'அனைத்து அலகுகளின் மாற்று அளவு',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                    color: Color(0xFF0F172A),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFFDCFCE7),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text(
                    'நேரலை (Live)',
                    style: TextStyle(
                      color: Color(0xFF15803D),
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Conversion Result Grid
            _buildResultCard(
              titleEn: 'Cent (சென்ட்)',
              titleTa: 'சென்ட்',
              value: '$cents',
              subtitle: '1 Cent = 435.6 Sq.Ft = ~3.025 குழி',
              icon: Icons.grid_view_rounded,
              color: const Color(0xFF0284C7),
              isHighlighted: _selectedFromUnit.contains('Cent'),
            ),
            const SizedBox(height: 10),

            _buildResultCard(
              titleEn: 'Kuzhi (குழி)',
              titleTa: 'குழி',
              value: '$kuzhi',
              subtitle: '1 குழி = 144 Sq.Ft (3 குழி ≈ 1 சென்ட்)',
              icon: Icons.terrain_rounded,
              color: const Color(0xFF16A34A),
              isHighlighted: _selectedFromUnit.contains('குழி') || _selectedFromUnit.contains('Kuzhi'),
            ),
            const SizedBox(height: 10),

            _buildResultCard(
              titleEn: 'Acre (ஏக்கர்)',
              titleTa: 'ஏக்கர்',
              value: '$acres',
              subtitle: '1 Acre = 100 Cents = 300 குழி = 43,560 Sq.Ft',
              icon: Icons.landscape_rounded,
              color: const Color(0xFF9333EA),
              isHighlighted: _selectedFromUnit.contains('Acre'),
            ),
            const SizedBox(height: 10),

            _buildResultCard(
              titleEn: 'Hectare (ஹெக்டேர்)',
              titleTa: 'ஹெக்டேர்',
              value: '$hectare',
              subtitle: '1 Hectare = 2.471 Acres = 247.1 Cents',
              icon: Icons.public_rounded,
              color: const Color(0xFFEA580C),
              isHighlighted: _selectedFromUnit.contains('Hectare') || _selectedFromUnit.contains('ஹெக்டேர்'),
            ),
            const SizedBox(height: 10),

            _buildResultCard(
              titleEn: 'Square Feet (சதுர அடி)',
              titleTa: 'சதுர அடி',
              value: '$sqFt',
              subtitle: 'மொத்த நில பரப்பு (Total Area in Sq.Ft)',
              icon: Icons.square_foot_rounded,
              color: const Color(0xFF475569),
              isHighlighted: _selectedFromUnit.contains('Sq.Ft'),
            ),
            const SizedBox(height: 10),

            _buildResultCard(
              titleEn: 'Grounds (கிரவுண்ட்)',
              titleTa: 'கிரவுண்ட்',
              value: '$grounds',
              subtitle: '1 Ground = 2,400 Sq.Ft = ~5.51 Cents',
              icon: Icons.apartment_rounded,
              color: const Color(0xFF0D9488),
              isHighlighted: _selectedFromUnit.contains('Ground'),
            ),

            const SizedBox(height: 24),

            // Tamil Land Conversion Reference Table
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFEFF6FF),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFBFDBFE)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: const [
                      Icon(Icons.menu_book_rounded, color: Color(0xFF1D4ED8), size: 20),
                      SizedBox(width: 8),
                      Text(
                        'தென் மாவட்ட நில அளவை குறிப்பு (Cheat Sheet)',
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 13.5,
                          color: Color(0xFF1E3A8A),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildCheatRow('1 குழி (Kuzhi)', '= 144 சதுர அடி (Sq.Ft)'),
                  _buildCheatRow('1 சென்ட் (Cent)', '= 435.6 சதுர அடி ≈ 3.025 குழி'),
                  _buildCheatRow('1 ஏக்கர் (Acre)', '= 100 சென்ட் = 300 குழி = 43,560 சதுர அடி'),
                  _buildCheatRow('1 ஹெக்டேர் (Hectare)', '= 2.471 ஏக்கர் = 247.1 சென்ட்'),
                  _buildCheatRow('1 கிரவுண்ட் (Ground)', '= 2,400 சதுர அடி ≈ 5.51 சென்ட்'),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildPresetChip(String label, double val, String unit) {
    return InkWell(
      onTap: () => _setPreset(val, unit),
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: const Color(0xFFCBD5E1)),
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 11.5,
            fontWeight: FontWeight.w700,
            color: Color(0xFF334155),
          ),
        ),
      ),
    );
  }

  Widget _buildResultCard({
    required String titleEn,
    required String titleTa,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
    required bool isHighlighted,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isHighlighted ? color.withValues(alpha: 0.08) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isHighlighted ? color : const Color(0xFFE2E8F0),
          width: isHighlighted ? 2 : 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      titleTa,
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 14,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    Text(
                      value,
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 18,
                        color: isHighlighted ? color : AppColors.primaryDark,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCheatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          const Icon(Icons.arrow_right, size: 16, color: Color(0xFF2563EB)),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1E3A8A),
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Color(0xFF334155),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
