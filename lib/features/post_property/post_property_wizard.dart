import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/currency_formatter.dart';
import '../../core/utils/image_picker_service.dart';
import '../../core/utils/land_units.dart';
import '../../core/utils/location_service.dart';
import '../../models/agent.dart';
import '../../models/property.dart';
import '../../state/app_state_providers.dart';
import 'post_success_screen.dart';

class PostPropertyWizard extends ConsumerStatefulWidget {
  final String? initialCategory;
  const PostPropertyWizard({super.key, this.initialCategory});

  @override
  ConsumerState<PostPropertyWizard> createState() => _PostPropertyWizardState();
}

class _PostPropertyWizardState extends ConsumerState<PostPropertyWizard> {
  int _currentStep = 0;
  final int _totalSteps = 3;

  // ===== Step 1: Basic & Location =====
  String _selectedPosterType = 'Owner'; // 'Owner', 'Promoter', 'Builder', 'Agent'
  String _selectedMainCategory = 'House'; // 'House', 'Land', 'Farmland', 'Shop', 'Apartment', 'Rental'
  String _selectedDistrict = 'தென்காசி';
  final TextEditingController _areaLocalityController = TextEditingController(text: 'தென்காசி');
  final TextEditingController _landmarkController = TextEditingController();
  final TextEditingController _contactPhoneController = TextEditingController();
  double? _latitude = 8.9594;
  double? _longitude = 77.3154;
  bool _isDetectingLocation = false;
  String _selectedFacing = 'கிழக்கு (East)';

  // ===== Step 2: Category-Specific Fields =====

  // 0. வீடு (House / Villa) Specific Fields - Mapped from Handwritten Notebook Note
  String _houseSubType = 'தனி வீடு'; // தனி வீடு, கெஸ்ட் House, பண்ணை வீடு, குடிசை வீடு, நத்தம் பட்டா வீடு, ஓட்டு வீடு, Un-Approved வீடு, பஞ்சாயத்து அப்ரூவல், Finance வீடு
  int _houseBhk = 2; // 1, 2, 3, 4, 5+
  final TextEditingController _houseBuiltAreaSqFtController = TextEditingController(text: '1200');
  String _houseLandUnit = 'Cents';
  final TextEditingController _houseLandAreaValueController = TextEditingController(text: '3');
  String _houseStatus = 'முழுமை பெற்றது (Complete)'; // 'முழுமை பெற்றது (Complete)', 'கட்டுமானத்தில் உள்ளது (Incomplete)', 'பராமரிப்பில் உள்ளது (Working)'
  final Set<String> _selectedHouseAmenities = {'போர்வெல்', 'வீட்டு நல்லி (குடிநீர் இணைப்பு)', 'EB மின் இணைப்பு', 'காம்பவுண்ட் சுவர்'};

  // 1. நிலம் (Land / Plot) Fields
  String _landSubType = 'DTCP Approved மனை';
  String _selectedLandUnit = 'Cents'; // 'Cents', 'குழி (Kuzhi)', 'Acres', 'Sq.Ft', 'Grounds'
  final TextEditingController _landAreaValueController = TextEditingController(text: '5');
  final Set<String> _selectedLandFeatures = {'போர்வெல் (Borewell)', 'EB மின் இணைப்பு', 'கம்பி / முள்வேலி'};
  String _selectedApproval = 'DTCP Approved'; // 'DTCP Approved', 'RERA Approved', 'Panchayat Approved', 'Unapproved'
  bool _isBankLoanAvailable = true; // Finance: இருக்கு / இல்லை

  // 2. தோட்டம் (Farmland / Thottam) Fields
  String _farmSubType = 'தென்னந்தோப்பு';
  String _selectedFarmUnit = 'Acres';
  final TextEditingController _farmAreaValueController = TextEditingController(text: '2');
  final Set<String> _selectedFarmWaterEb = {'போர்வெல்', 'இலவச விவசாய EB', 'கிணறு'};
  bool _hasTrees = true;
  final TextEditingController _treesDetailsController = TextEditingController(text: '120 தென்னை மரங்கள், 10 மாமரம்');
  bool _hasIncome = true;
  final TextEditingController _incomeDetailsController = TextEditingController(text: 'மாதம் ₹45,000 தேங்காய் மகசூல்');

  // 3. அபார்ட்மெண்ட் (Apartment / Flat) Fields
  String _aptSubType = '2 BHK அபார்ட்மெண்ட்';
  int _selectedBhk = 2;
  final TextEditingController _aptBuiltSqFtController = TextEditingController(text: '1050');
  final TextEditingController _aptUdsController = TextEditingController(text: '1.2 Cent UDS');
  bool _hasLift = true;
  String _selectedWaterSource = 'Bore + Govt Water (இரண்டும்)'; // 'Bore Water', 'Govt Water', 'Both'
  String _selectedAptApproval = 'CMDA / DTCP Approved';

  // 4. வாடகைக்கு (For Rent / Lease) Fields
  String _selectedRentalSubType = 'வீடு (House)'; // வீடு, கடை, Complex, காலி இடம், தோட்டம் குத்தகை, Business, அலுவலகம்
  bool _isLease = false; // false = Monthly Rent, true = Lease
  final TextEditingController _advanceAmountController = TextEditingController(text: '50000');
  final TextEditingController _rentAmountController = TextEditingController(text: '8500');

  // 5. கடை / அலுவலகம் (Shop / Office) Fields
  String _shopSubType = 'கடை (Shop)';
  String _selectedCommercialAreaType = 'Main Bazaar (மெயின் பஜார்)';
  final TextEditingController _shopAreaSqFtController = TextEditingController(text: '350');
  String _shopPowerPhase = 'Single Phase EB';
  bool _shopHasFan = true;
  bool _shopHasTable = true;
  bool _shopHasWater = true;
  bool _shopHasShutter = true;

  // ===== Step 3: Financial, Media & Confirmation =====
  final TextEditingController _priceController = TextEditingController(text: '2500000');
  bool _isPriceNegotiable = true; // பேசலாம் (Negotiable) vs நிலையானது (Fixed)
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  String? _customImageBase64;
  bool _isPickingImage = false;

  final List<String> _districts = [
    'தென்காசி',
    'திருநெல்வேலி',
    'தூத்துக்குடி',
    'விருதுநகர்',
    'மதுரை',
    'சென்னை',
    'கோயம்புத்தூர்',
  ];

  final List<String> _facingDirections = [
    'கிழக்கு (East)',
    'வடக்கு (North)',
    'மேற்கு (West)',
    'தெற்கு (South)',
    'வடகிழக்கு (North-East)',
    'தென்கிழக்கு (South-East)',
    'வடமேற்கு (North-West)',
    'தென்மேற்கு (South-West)',
    'கார்னர் பிளாட் (Corner Plot)',
  ];



  final List<String> _farmWaterOptions = [
    'போர்வெல்',
    'இலவச விவசாய EB',
    'கமர்ஷியல் EB',
    'கிணறு (Open Well)',
    'வாய்க்கால் பாசனம்',
    'சொட்டு நீர் பாசனம்',
  ];

  final List<String> _rentalSubTypes = [
    'வீடு (House)',
    'கடை (Shop)',
    'Complex (வணிக வளாகம்)',
    'காலி இடம் / நிலம்',
    'தோட்டம் (குத்தகைக்கு)',
    'Business (வணிக இடம்)',
    'அலுவலகம் (Office)',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.initialCategory != null && widget.initialCategory != 'all' && widget.initialCategory!.isNotEmpty) {
      final cat = widget.initialCategory!.toLowerCase();
      if (cat == 'house') {
        _selectedMainCategory = 'House';
      } else if (cat == 'land' || cat == 'plots') {
        _selectedMainCategory = 'Land';
      } else if (cat == 'farmland' || cat == 'farm') {
        _selectedMainCategory = 'Farmland';
      } else if (cat == 'shop' || cat == 'commercial') {
        _selectedMainCategory = 'Shop';
      } else if (cat == 'apartment') {
        _selectedMainCategory = 'Apartment';
      } else if (cat == 'rental' || cat == 'rent') {
        _selectedMainCategory = 'Rental';
      }
    } else {
      _selectedMainCategory = 'Land';
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userProfile = ref.read(userProfileProvider);
      final rawP = userProfile.phone.replaceAll(RegExp(r'[^0-9]'), '');
      if (rawP.isNotEmpty && (_contactPhoneController.text.isEmpty || _contactPhoneController.text == '9894174944')) {
        _contactPhoneController.text = rawP;
      }
    });
    _autoGenerateTitle();
  }

  void _autoGenerateTitle() {
    if (_titleController.text.isEmpty) {
      if (_selectedMainCategory == 'House') {
        _titleController.text = '$_houseBhk BHK $_houseSubType - ${_houseBuiltAreaSqFtController.text} Sq.Ft, $_selectedDistrict';
      } else if (_selectedMainCategory == 'Land') {
        _titleController.text = '$_landSubType ${_landAreaValueController.text} $_selectedLandUnit இடம்';
      } else if (_selectedMainCategory == 'Farmland') {
        _titleController.text = '$_selectedDistrict அருகில் ${_farmAreaValueController.text} $_selectedFarmUnit $_farmSubType';
      } else if (_selectedMainCategory == 'Apartment') {
        _titleController.text = '$_aptSubType - ${_aptBuiltSqFtController.text} Sq.Ft, $_selectedDistrict';
      } else if (_selectedMainCategory == 'Rental') {
        _titleController.text = '$_selectedRentalSubType வாடகைக்கு / லீசுக்கு - $_selectedDistrict';
      } else if (_selectedMainCategory == 'Shop') {
        _titleController.text = '$_shopSubType - ${_shopAreaSqFtController.text} Sq.Ft, $_selectedDistrict';
      }
    }
  }

  @override
  void dispose() {
    _areaLocalityController.dispose();
    _landmarkController.dispose();
    _contactPhoneController.dispose();
    _houseBuiltAreaSqFtController.dispose();
    _houseLandAreaValueController.dispose();
    _landAreaValueController.dispose();
    _farmAreaValueController.dispose();
    _treesDetailsController.dispose();
    _incomeDetailsController.dispose();
    _aptBuiltSqFtController.dispose();
    _aptUdsController.dispose();
    _advanceAmountController.dispose();
    _rentAmountController.dispose();
    _priceController.dispose();
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primaryDark,
        foregroundColor: Colors.white,
        title: const Text(
          'விளம்பரம் பதிவிடு (Post Property)',
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () {
            if (_currentStep > 0) {
              setState(() => _currentStep--);
            } else {
              Navigator.pop(context);
            }
          },
        ),
      ),
      body: Column(
        children: [
          // Step Indicator (3 Steps)
          _buildStepIndicator(),

          // Step Body
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 30),
              child: _buildCurrentStepContent(),
            ),
          ),

          // Bottom Action Bar
          _buildBottomActions(),
        ],
      ),
    );
  }

  // ===== Step Indicator =====
  Widget _buildStepIndicator() {
    final stepLabels = [
      'அடிப்படை விவரங்கள்',
      'சொத்து & வசதிகள்',
      'விலை & முன்னோட்டம்',
    ];

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      child: Column(
        children: [
          // Stepper Circles with Connectors
          Row(
            children: [
              for (int i = 0; i < 3; i++) ...[
                if (i > 0)
                  Expanded(
                    child: Container(
                      height: 3,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        color: i <= _currentStep ? AppColors.primary : const Color(0xFFE2E8F0),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: i < _currentStep
                        ? AppColors.primary
                        : (i == _currentStep ? AppColors.primary : Colors.white),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: i <= _currentStep ? AppColors.primary : const Color(0xFFCBD5E1),
                      width: 2,
                    ),
                    boxShadow: i == _currentStep
                        ? [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.3),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : null,
                  ),
                  child: Center(
                    child: i < _currentStep
                        ? const Icon(Icons.check_rounded, color: Colors.white, size: 18)
                        : Text(
                            '${i + 1}',
                            style: TextStyle(
                              color: i == _currentStep ? Colors.white : const Color(0xFF64748B),
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 10),
          // Active step title badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 7,
                  height: 7,
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'படி ${_currentStep + 1} / 3: ${stepLabels[_currentStep]}',
                  style: const TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentStepContent() {
    switch (_currentStep) {
      case 0:
        return _buildStep1BasicDetails();
      case 1:
        return _buildStep2CategorySpecificDetails();
      case 2:
        return _buildStep3PriceAndPreview();
      default:
        return const SizedBox();
    }
  }

  // ==========================================
  // STEP 1: Basic Category & Contact Details
  // ==========================================
  Widget _buildStep1BasicDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 0. Selected Category Header (From Home Page)
        _buildSelectedCategoryHeader(),

        // 1. யார் பதிவு செய்கிறீர்கள்? (Who is posting?)
        _buildSectionTitle('1. யார் பதிவு செய்கிறீர்கள்? (Who is posting?)*'),
        const SizedBox(height: 10),
        Row(
          children: [
            _buildPosterTypeOption('Owner', 'உரிமையாளர்', Icons.person_rounded),
            const SizedBox(width: 6),
            _buildPosterTypeOption('Promoter', 'புரோமோட்டர்', Icons.campaign_rounded),
            const SizedBox(width: 6),
            _buildPosterTypeOption('Builder', 'பில்டர்', Icons.engineering_rounded),
            const SizedBox(width: 6),
            _buildPosterTypeOption('Agent', 'ஏஜென்ட்', Icons.support_agent_rounded),
          ],
        ),

        const SizedBox(height: 22),

        // 2. உட்பிரிவு / சப்-கேட்டகிரி தேர்வு செய்க (Sub-Categories directly!)
        _buildSubCategorySelector(),

        const SizedBox(height: 22),

        // 3. தொடர்பு மொபைல் எண் (Mobile Number Add)
        _buildSectionTitle('3. தொடர்பு மொபைல் எண் (Mobile Number for Call & WhatsApp)'),
        const SizedBox(height: 8),
        TextFormField(
          controller: _contactPhoneController,
          keyboardType: TextInputType.phone,
          decoration: _inputDecoration(
            hint: 'உதா: 98941 74944',
            prefixIcon: Icons.phone_rounded,
            suffix: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: Colors.green, width: 0.8),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.chat, size: 13, color: Colors.green),
                  SizedBox(width: 4),
                  Text('WhatsApp Active', style: TextStyle(color: Colors.green, fontSize: 11, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ),
        ),

        const SizedBox(height: 22),

        // 4. இருப்பிடம் & Google Map (Location Details)
        _buildSectionTitle('4. இருப்பிடம் & Google Map (Location)'),
        const SizedBox(height: 10),

        Row(
          children: [
            Expanded(
              flex: 1,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildFieldLabel('மாவட்டம் (District)'),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedDistrict,
                        isExpanded: true,
                        items: _districts.map((d) => DropdownMenuItem(value: d, child: Text(d, style: const TextStyle(fontSize: 13.5)))).toList(),
                        onChanged: (val) => setState(() => _selectedDistrict = val!),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              flex: 1,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildFieldLabel('ஊர் / பகுதி (Area / Town)'),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _areaLocalityController,
                    decoration: _inputDecoration(hint: 'உதா: பாவூர்சத்திரம்'),
                  ),
                ],
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        // GPS Location auto-detect button
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: _latitude != null ? const Color(0xFFE8F5E9) : AppColors.primaryLight.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _latitude != null ? const Color(0xFF4CAF50) : AppColors.primary.withValues(alpha: 0.3),
              width: _latitude != null ? 1.5 : 1.0,
            ),
          ),
          child: Row(
            children: [
              Icon(
                _latitude != null ? Icons.check_circle_rounded : Icons.my_location_rounded,
                color: _latitude != null ? const Color(0xFF2E7D32) : AppColors.primary,
                size: 22,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _latitude != null
                          ? '✅ நேரலை GPS இணைக்கப்பட்டது'
                          : '📍 மொபைல் GPS இருப்பிடத்தைப் பெறுக',
                      style: TextStyle(
                        color: _latitude != null ? const Color(0xFF1B5E20) : AppColors.primaryDark,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (_latitude != null)
                      Text(
                        '${_areaLocalityController.text.isNotEmpty ? "${_areaLocalityController.text} • " : ""}${_latitude!.toStringAsFixed(4)}° N, ${_longitude!.toStringAsFixed(4)}° E',
                        style: const TextStyle(
                          color: Color(0xFF2E7D32),
                          fontSize: 11.5,
                          fontWeight: FontWeight.w500,
                        ),
                      )
                    else
                      const Text(
                        'மொபைல் GPS அனுமதி கேட்டு துல்லியமாக இணைக்கும்',
                        style: TextStyle(color: Color(0xFF64748B), fontSize: 11),
                      ),
                  ],
                ),
              ),
              TextButton.icon(
                onPressed: _isDetectingLocation ? null : _detectLocation,
                style: TextButton.styleFrom(
                  backgroundColor: _latitude != null ? const Color(0xFF2E7D32) : AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  minimumSize: Size.zero,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                icon: _isDetectingLocation
                    ? const SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : Icon(
                        _latitude != null ? Icons.refresh_rounded : Icons.gps_fixed_rounded,
                        size: 14,
                      ),
                label: Text(
                  _latitude != null ? 'மீண்டும்' : 'GPS பெறுக',
                  style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 12),

        // Google Map Link or Nearby Landmark
        _buildFieldLabel('Google Map இணைப்பு / அடையாள இடம் (Landmark)'),
        const SizedBox(height: 6),
        TextFormField(
          controller: _landmarkController,
          decoration: _inputDecoration(hint: 'உதா: பழைய பேருந்து நிலையம் எதிரில், மெயின் ரோடு', prefixIcon: Icons.pin_drop_outlined),
        ),
      ],
    );
  }

  // ==============================================================
  // STEP 2: Category-Specific Requirements based on Handwritten Notes
  // ==============================================================
  Widget _buildStep2CategorySpecificDetails() {
    if (_selectedMainCategory == 'House') {
      return _buildHouseSpecificForm();
    } else if (_selectedMainCategory == 'Land') {
      return _buildLandSpecificForm();
    } else if (_selectedMainCategory == 'Farmland') {
      return _buildFarmlandSpecificForm();
    } else if (_selectedMainCategory == 'Apartment') {
      return _buildApartmentSpecificForm();
    } else if (_selectedMainCategory == 'Shop') {
      return _buildShopSpecificForm();
    } else {
      return _buildRentalSpecificForm();
    }
  }

  // --- 0. வீடு (House / Villa) Specific Form - Mapped from Handwritten Notebook Note ---
  Widget _buildHouseSpecificForm() {
    final landAreaVal = double.tryParse(_houseLandAreaValueController.text) ?? 3.0;
    final landSqFt = LandUnitConverter.toSqFt(landAreaVal, _houseLandUnit);


    final houseAmenitiesList = [
      'போர்வெல்',
      'வீட்டு நல்லி (குடிநீர் இணைப்பு)',
      'EB மின் இணைப்பு',
      'காம்பவுண்ட் சுவர்',
      'தார் ரோடு அணுகுமுறை',
      'கார் பார்க்கிங்',
      'வாஸ்து முறைப்படி கட்டப்பட்டது',
    ];

    final houseStatusOptions = [
      {'id': 'முழுமை பெற்றது (Complete)', 'title': 'முழுமை பெற்றது', 'sub': 'Complete / Ready to Move', 'icon': Icons.check_circle_rounded, 'color': Colors.green},
      {'id': 'கட்டுமானத்தில் உள்ளது (Incomplete)', 'title': 'கட்டுமானத்தில் உள்ளது', 'sub': 'Under Construction', 'icon': Icons.construction_rounded, 'color': Colors.orange},
      {'id': 'பராமரிப்பில் உள்ளது (Working)', 'title': 'பராமரிப்பு / புதுப்பித்தல்', 'sub': 'Working / Renovation', 'icon': Icons.build_circle_rounded, 'color': Colors.blue},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildModuleHeader('🏡 வீடு விவரங்கள் (House & Villa Specifications)', Icons.home_rounded, const Color(0xFF0284C7)),
        const SizedBox(height: 16),

        Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: const Color(0xFFE0F2FE),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFBAE6FD)),
          ),
          child: Row(
            children: [
              const Icon(Icons.check_circle_rounded, color: Color(0xFF0284C7), size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'தேர்ந்தெடுக்கப்பட்ட வீட்டின் வகை: $_houseSubType',
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF0369A1)),
                ),
              ),
            ],
          ),
        ),

        // 1. BHK தேர்வு (1, 2, 3, 4, 5+)
        _buildSectionTitle('1. படுக்கையறை எண்ணிக்கை (BHK)*'),
        const SizedBox(height: 8),
        Row(
          children: [1, 2, 3, 4, 5].map((bhk) {
            final isSel = _houseBhk == bhk;
            return Expanded(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _houseBhk = bhk;
                    _autoGenerateTitle();
                  });
                },
                child: Container(
                  margin: EdgeInsets.only(right: bhk < 5 ? 6 : 0),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: isSel ? const Color(0xFF0284C7) : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: isSel ? const Color(0xFF0284C7) : AppColors.border, width: isSel ? 2 : 1),
                    boxShadow: isSel ? [BoxShadow(color: const Color(0xFF0284C7).withValues(alpha: 0.25), blurRadius: 6)] : null,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.bed_rounded, size: 18, color: isSel ? Colors.white : const Color(0xFF0284C7)),
                      const SizedBox(height: 4),
                      Text(
                        bhk == 5 ? '5+ BHK' : '$bhk BHK',
                        style: TextStyle(
                          color: isSel ? Colors.white : AppColors.textPrimary,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),

        const SizedBox(height: 20),

        // 3. கட்டிடத்தின் அளவு Sqft & நிலத்தின் அளவு Land Area
        Row(
          children: [
            Expanded(
              flex: 1,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildFieldLabel('கட்டிடத்தின் அளவு (Built-up Sq.Ft)*'),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _houseBuiltAreaSqFtController,
                    keyboardType: TextInputType.number,
                    onChanged: (_) => setState(() => _autoGenerateTitle()),
                    decoration: _inputDecoration(hint: '1200', prefixIcon: Icons.home_work_rounded),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              flex: 1,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildFieldLabel('நிலத்தின் அளவு (Land Area)*'),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: TextFormField(
                          controller: _houseLandAreaValueController,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          onChanged: (_) => setState(() {}),
                          decoration: _inputDecoration(hint: '3'),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        flex: 3,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: _houseLandUnit,
                              isExpanded: true,
                              items: ['Cents', 'Sq.Ft', 'குழி (Kuzhi)'].map((u) => DropdownMenuItem(value: u, child: Text(u, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)))).toList(),
                              onChanged: (val) => setState(() => _houseLandUnit = val!),
                            ),
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
        const SizedBox(height: 6),
        Text(
          '💡 நில அளவு: $landAreaVal $_houseLandUnit = $landSqFt சதுர அடி (Sq.Ft)',
          style: const TextStyle(color: Color(0xFF0284C7), fontSize: 11.5, fontWeight: FontWeight.w600),
        ),

        const SizedBox(height: 20),

        // 4. வீட்டு நிலை (Complete / Incomplete / Working) from handwritten note
        _buildSectionTitle('3. வீட்டின் தற்போதைய நிலை (House Status / Stage)*'),
        const SizedBox(height: 8),
        Column(
          children: houseStatusOptions.map((opt) {
            final isSel = _houseStatus == opt['id'];
            final color = opt['color'] as MaterialColor;
            return GestureDetector(
              onTap: () => setState(() => _houseStatus = opt['id'] as String),
              child: Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: isSel ? color.shade50 : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSel ? color : AppColors.border,
                    width: isSel ? 2 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(opt['icon'] as IconData, color: isSel ? color : Colors.grey, size: 22),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            opt['title'] as String,
                            style: TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w700,
                              color: isSel ? color.shade900 : AppColors.textPrimary,
                            ),
                          ),
                          Text(
                            opt['sub'] as String,
                            style: TextStyle(fontSize: 11, color: isSel ? color.shade700 : AppColors.textMuted),
                          ),
                        ],
                      ),
                    ),
                    if (isSel)
                      Icon(Icons.check_circle, color: color, size: 20),
                  ],
                ),
              ),
            );
          }).toList(),
        ),

        const SizedBox(height: 20),

        // 5. முக்கிய வசதிகள் & இணைப்புகள் (போர்வெல், வீட்டு நல்லி, EB, காம்பவுண்ட் சுவர்)
        _buildSectionTitle('4. முக்கிய வசதிகள் & இணைப்புகள் (Key Amenities)'),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: houseAmenitiesList.map((amenity) {
            final isSel = _selectedHouseAmenities.contains(amenity);
            return FilterChip(
              label: Text(amenity, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: isSel ? Colors.white : AppColors.textPrimary)),
              selected: isSel,
              selectedColor: const Color(0xFF0284C7),
              backgroundColor: Colors.white,
              checkmarkColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8), side: BorderSide(color: isSel ? const Color(0xFF0284C7) : AppColors.border)),
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    _selectedHouseAmenities.add(amenity);
                  } else {
                    _selectedHouseAmenities.remove(amenity);
                  }
                });
              },
            );
          }).toList(),
        ),

        const SizedBox(height: 20),

        // 6. வீட்டு திசை (Facing Direction)
        _buildSectionTitle('5. வீட்டு வாசல் திசை (Facing Direction)'),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedFacing,
              isExpanded: true,
              items: _facingDirections.map((f) => DropdownMenuItem(value: f, child: Text(f, style: const TextStyle(fontSize: 13.5)))).toList(),
              onChanged: (val) => setState(() => _selectedFacing = val!),
            ),
          ),
        ),
      ],
    );
  }

  // --- 1. நிலம் (Land / Plot) Specific Form - Mapped from Handwritten Notebook Note ---
  Widget _buildLandSpecificForm() {
    final areaVal = double.tryParse(_landAreaValueController.text) ?? 5.0;
    final sqFt = LandUnitConverter.toSqFt(areaVal, _selectedLandUnit);
    final equivCent = (sqFt / LandUnitConverter.sqFtPerCent).toStringAsFixed(1);
    final equivAcre = (sqFt / LandUnitConverter.sqFtPerAcre).toStringAsFixed(2);

    final landUnitsList = [
      {'id': 'Cents', 'label': 'சென்ட் (Cent)', 'icon': Icons.crop_square_rounded},
      {'id': 'Acres', 'label': 'ஏக்கர் (Acre)', 'icon': Icons.crop_free_rounded},
      {'id': 'குழி (Kuzhi)', 'label': 'குழி (Kuzhi)', 'icon': Icons.grid_4x4_rounded},
      {'id': 'Sq.Ft', 'label': 'சதுர அடி (Sq.Ft)', 'icon': Icons.straighten_rounded},
    ];

    final approvalOptions = [
      {'id': 'DTCP Approved', 'num': '①', 'title': 'DTCP Approved', 'ta': 'DTCP அப்ரூவல்', 'desc': 'நகர் ஊரமைப்பு துறை அங்கீகாரம்', 'icon': Icons.verified_rounded, 'color': const Color(0xFF047857)},
      {'id': 'RERA Approved', 'num': '②', 'title': 'RERA Approved', 'ta': 'RERA அப்ரூவல்', 'desc': 'ரியல் எஸ்டேட் ஒழுங்குமுறை ஆணையம்', 'icon': Icons.verified_user_rounded, 'color': const Color(0xFF0284C7)},
      {'id': 'Panchayat Approved', 'num': '③', 'title': 'Panchayat', 'ta': 'பஞ்சாயத்து அப்ரூவல்', 'desc': 'கிராம பஞ்சாயத்து பிளான் ஒப்புதல்', 'icon': Icons.account_balance_rounded, 'color': const Color(0xFFD97706)},
      {'id': 'Unapproved', 'num': '④', 'title': 'UnApproval', 'ta': 'அப்ரூவல் இல்லாதது', 'desc': 'விவசாயம் / தனி மனை பட்டா இடம்', 'icon': Icons.info_outline_rounded, 'color': const Color(0xFF64748B)},
    ];

    final landFeaturesList = [
      {'name': 'போர்வெல் (Borewell)', 'icon': Icons.water_drop_rounded},
      {'name': 'EB மின் இணைப்பு', 'icon': Icons.electrical_services_rounded},
      {'name': 'தார் ரோடு அணுகுமுறை', 'icon': Icons.add_road_rounded},
      {'name': 'கம்பி / முள்வேலி', 'icon': Icons.fence_rounded},
      {'name': 'காம்பவுண்ட் சுவர்', 'icon': Icons.border_all_rounded},
      {'name': 'கிணறு (Open Well)', 'icon': Icons.waves_rounded},
      {'name': 'குடிநீர் இணைப்பு', 'icon': Icons.water_damage_rounded},
      {'name': 'நஞ்சை நிலம்', 'icon': Icons.grass_rounded},
      {'name': 'புஞ்சை நிலம்', 'icon': Icons.landscape_rounded},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildModuleHeader('🌾 நிலம் / பிளாட் விவரங்கள் (Land & Plot Specifications)', Icons.landscape_rounded, const Color(0xFF047857)),
        const SizedBox(height: 16),

        Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: const Color(0xFFECFDF5),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFA7F3D0)),
          ),
          child: Row(
            children: [
              const Icon(Icons.check_circle_rounded, color: Color(0xFF047857), size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'தேர்ந்தெடுக்கப்பட்ட மனை பிரிவு: $_landSubType',
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF065F46)),
                ),
              ),
            ],
          ),
        ),

        // 1. நிலத்தின் அளவு & அளவை அலகு (Cent / Acre / Kuzhi / Sq.Ft)
        _buildSectionTitle('1. நிலத்தின் அளவு & அலகு (எத்தனை Cent / Acre / குழி / Sq.Ft)*'),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              flex: 5,
              child: TextFormField(
                controller: _landAreaValueController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                onChanged: (_) => setState(() => _autoGenerateTitle()),
                decoration: _inputDecoration(
                  hint: '10',
                  prefixIcon: Icons.straighten_rounded,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              flex: 6,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedLandUnit,
                    isExpanded: true,
                    items: landUnitsList.map((u) {
                      return DropdownMenuItem(
                        value: u['id'] as String,
                        child: Row(
                          children: [
                            Icon(u['icon'] as IconData, size: 16, color: const Color(0xFF047857)),
                            const SizedBox(width: 6),
                            Expanded(child: Text(u['label'] as String, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold))),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) {
                        setState(() {
                          _selectedLandUnit = val;
                          _autoGenerateTitle();
                        });
                      }
                    },
                  ),
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 8),
        // Real-time Conversion Banner
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFFECFDF5),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFA7F3D0)),
          ),
          child: Row(
            children: [
              const Icon(Icons.calculate_rounded, color: Color(0xFF047857), size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '💡 $areaVal $_selectedLandUnit = $sqFt சதுர அடி (Sq.Ft) • $equivCent சென்ட் • $equivAcre ஏக்கர்',
                  style: const TextStyle(color: Color(0xFF065F46), fontSize: 11.5, fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // 3. அங்கீகாரம் (Approval: 1 DTCP, 2 RERA, 3 Panchayath, 4 UnApproval)
        _buildSectionTitle('3. நில அங்கீகாரம் (Approval Status)*'),
        const SizedBox(height: 8),
        Column(
          children: approvalOptions.map((opt) {
            final isSel = _selectedApproval == opt['id'];
            final color = opt['color'] as Color;
            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedApproval = opt['id'] as String;
                  _autoGenerateTitle();
                });
              },
              child: Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: isSel ? color.withValues(alpha: 0.08) : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSel ? color : AppColors.border,
                    width: isSel ? 2 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: isSel ? color : Colors.grey.shade100,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          opt['num'] as String,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w900,
                            color: isSel ? Colors.white : Colors.grey.shade700,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                opt['ta'] as String,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w800,
                                  color: isSel ? color : AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                '(${opt['title']})',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: isSel ? color : AppColors.textMuted,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          Text(
                            opt['desc'] as String,
                            style: TextStyle(fontSize: 11, color: isSel ? color.withValues(alpha: 0.8) : AppColors.textMuted),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      isSel ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
                      color: isSel ? color : Colors.grey.shade400,
                      size: 20,
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),

        const SizedBox(height: 20),

        // 4. Land நிலை & முக்கிய வசதிகள் (போர்வெல், EB இணைப்பு, ரோடு, வேலி...)
        _buildSectionTitle('4. நில நிலை & முக்கிய வசதிகள் (போர்வெல், EB இணைப்பு, இதர)*'),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: landFeaturesList.map((feat) {
            final name = feat['name'] as String;
            final icon = feat['icon'] as IconData;
            final isChecked = _selectedLandFeatures.contains(name);
            return FilterChip(
              avatar: Icon(icon, size: 16, color: isChecked ? Colors.white : const Color(0xFF047857)),
              label: Text(
                name,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: isChecked ? Colors.white : AppColors.textPrimary,
                ),
              ),
              selected: isChecked,
              selectedColor: const Color(0xFF047857),
              checkmarkColor: Colors.white,
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
                side: BorderSide(
                  color: isChecked ? const Color(0xFF047857) : AppColors.border,
                  width: isChecked ? 1.5 : 1,
                ),
              ),
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    _selectedLandFeatures.add(name);
                  } else {
                    _selectedLandFeatures.remove(name);
                  }
                });
              },
            );
          }).toList(),
        ),

        const SizedBox(height: 20),

        // 6. நிலம் பார்க்கும் திசை (Facing Direction)
        _buildSectionTitle('6. நிலம் பார்க்கும் திசை (Facing Direction)*'),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedFacing,
              isExpanded: true,
              items: _facingDirections.map((f) {
                return DropdownMenuItem(
                  value: f,
                  child: Row(
                    children: [
                      const Icon(Icons.explore_rounded, size: 16, color: Color(0xFF047857)),
                      const SizedBox(width: 8),
                      Text(f, style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600)),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (val) {
                if (val != null) {
                  setState(() => _selectedFacing = val);
                }
              },
            ),
          ),
        ),
      ],
    );
  }

  // --- 2. தோட்டம் (Farmland) Specific Form ---
  Widget _buildFarmlandSpecificForm() {
    final areaVal = double.tryParse(_farmAreaValueController.text) ?? 2.0;
    final sqFt = LandUnitConverter.toSqFt(areaVal, _selectedFarmUnit);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildModuleHeader('தோட்டம் & விவசாய நிலம் (Farmland Details)', Icons.agriculture_rounded, const Color(0xFF2E7D32)),
        const SizedBox(height: 16),

        Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: const Color(0xFFF0FDF4),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFBBF7D0)),
          ),
          child: Row(
            children: [
              const Icon(Icons.check_circle_rounded, color: Color(0xFF15803D), size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'தேர்ந்தெடுக்கப்பட்ட தோட்டம் வகை: $_farmSubType',
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF166534)),
                ),
              ),
            ],
          ),
        ),

        _buildSectionTitle('தோட்டத்தின் அளவு & அலகு (Farm Area)'),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              flex: 1,
              child: TextFormField(
                controller: _farmAreaValueController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                onChanged: (_) => setState(() {}),
                decoration: _inputDecoration(hint: '2', prefixIcon: Icons.straighten_rounded),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              flex: 1,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedFarmUnit,
                    isExpanded: true,
                    items: ['Acres', 'Cents', 'குழி (Kuzhi)', 'Sq.Ft'].map((u) => DropdownMenuItem(value: u, child: Text(u, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)))).toList(),
                    onChanged: (val) => setState(() => _selectedFarmUnit = val!),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text('💡 தோட்ட பரப்பளவு: $areaVal $_selectedFarmUnit = $sqFt சதுர அடி', style: const TextStyle(color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.bold)),

        const SizedBox(height: 20),

        _buildSectionTitle('நீர் & மின்சார வசதி (Water & Electricity)'),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _farmWaterOptions.map((opt) {
            final isChecked = _selectedFarmWaterEb.contains(opt);
            return FilterChip(
              label: Text(opt, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: isChecked ? Colors.white : AppColors.textPrimary)),
              selected: isChecked,
              selectedColor: const Color(0xFF2E7D32),
              checkmarkColor: Colors.white,
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8), side: BorderSide(color: isChecked ? const Color(0xFF2E7D32) : AppColors.border)),
              onSelected: (sel) {
                setState(() {
                  if (sel) {
                    _selectedFarmWaterEb.add(opt);
                  } else {
                    _selectedFarmWaterEb.remove(opt);
                  }
                });
              },
            );
          }).toList(),
        ),

        const SizedBox(height: 20),

        _buildSectionTitle('தோட்டத்தில் மரங்கள் உள்ளதா? (Trees / Plantation)'),
        const SizedBox(height: 8),
        Row(
          children: [
            _buildYesNoToggle(label: 'ஆம் (Yes, Trees)', isSelected: _hasTrees, onTap: () => setState(() => _hasTrees = true)),
            const SizedBox(width: 10),
            _buildYesNoToggle(label: 'இல்லை (Empty Land)', isSelected: !_hasTrees, onTap: () => setState(() => _hasTrees = false)),
          ],
        ),
        if (_hasTrees) ...[
          const SizedBox(height: 8),
          TextFormField(
            controller: _treesDetailsController,
            decoration: _inputDecoration(hint: 'உதா: 150 தென்னை மரங்கள், 20 மாமரம், 5 தேக்கு', prefixIcon: Icons.park_outlined),
          ),
        ],

        const SizedBox(height: 20),

        _buildSectionTitle('மகசூல் வருமானம் உள்ளதா? (Farm Yield / Income)'),
        const SizedBox(height: 8),
        Row(
          children: [
            _buildYesNoToggle(label: 'ஆம் (Income Generating)', isSelected: _hasIncome, onTap: () => setState(() => _hasIncome = true)),
            const SizedBox(width: 10),
            _buildYesNoToggle(label: 'இல்லை (No Income)', isSelected: !_hasIncome, onTap: () => setState(() => _hasIncome = false)),
          ],
        ),
        if (_hasIncome) ...[
          const SizedBox(height: 8),
          TextFormField(
            controller: _incomeDetailsController,
            decoration: _inputDecoration(hint: 'உதா: மாதம் ₹40,000 தேங்காய் & பால் வருமானம்', prefixIcon: Icons.currency_rupee_rounded),
          ),
        ],

        const SizedBox(height: 20),

        _buildSectionTitle('தோட்டம் பார்க்கும் திசை (Facing Direction)'),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedFacing,
              isExpanded: true,
              items: _facingDirections.map((f) => DropdownMenuItem(value: f, child: Text(f, style: const TextStyle(fontSize: 13.5)))).toList(),
              onChanged: (val) => setState(() => _selectedFacing = val!),
            ),
          ),
        ),
      ],
    );
  }

  // --- 3. அபார்ட்மெண்ட் (Apartment) Specific Form ---
  Widget _buildApartmentSpecificForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildModuleHeader('அபார்ட்மெண்ட் விவரங்கள் (Apartment Details)', Icons.apartment_rounded, const Color(0xFF0D47A1)),
        const SizedBox(height: 16),

        Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: const Color(0xFFEFF6FF),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFBFDBFE)),
          ),
          child: Row(
            children: [
              const Icon(Icons.check_circle_rounded, color: Color(0xFF1D4ED8), size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'தேர்ந்தெடுக்கப்பட்ட அபார்ட்மெண்ட்: $_aptSubType',
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF1E40AF)),
                ),
              ),
            ],
          ),
        ),

        _buildSectionTitle('BHK தேர்வு (Bedrooms)'),
        const SizedBox(height: 8),
        Row(
          children: [1, 2, 3, 4].map((bhk) {
            final isSel = _selectedBhk == bhk;
            return Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _selectedBhk = bhk),
                child: Container(
                  margin: const EdgeInsets.only(right: 6),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: isSel ? const Color(0xFF0D47A1) : Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: isSel ? const Color(0xFF0D47A1) : AppColors.border),
                  ),
                  child: Center(
                    child: Text(
                      '$bhk BHK',
                      style: TextStyle(
                        color: isSel ? Colors.white : AppColors.textPrimary,
                        fontWeight: FontWeight.bold,
                        fontSize: 13.5,
                      ),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),

        const SizedBox(height: 20),

        Row(
          children: [
            Expanded(
              flex: 1,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildFieldLabel('பில்ட்-அப் அளவு (Sq.Ft)'),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _aptBuiltSqFtController,
                    keyboardType: TextInputType.number,
                    decoration: _inputDecoration(hint: '1050', prefixIcon: Icons.square_foot_rounded),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              flex: 1,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildFieldLabel('UDS நில அளவு'),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _aptUdsController,
                    decoration: _inputDecoration(hint: '1.2 Cent UDS', prefixIcon: Icons.pie_chart_outline),
                  ),
                ],
              ),
            ),
          ],
        ),

        const SizedBox(height: 20),

        _buildSectionTitle('லிஃப்ட் வசதி (Lift / Elevator)'),
        const SizedBox(height: 8),
        Row(
          children: [
            _buildYesNoToggle(label: 'லிஃப்ட் வசதி இருக்கு (Lift Yes)', isSelected: _hasLift, onTap: () => setState(() => _hasLift = true)),
            const SizedBox(width: 10),
            _buildYesNoToggle(label: 'லிஃப்ட் இல்லை (No Lift)', isSelected: !_hasLift, onTap: () => setState(() => _hasLift = false)),
          ],
        ),

        const SizedBox(height: 20),

        _buildSectionTitle('குடிநீர் வசதி (Water Facility)'),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            'Bore Water (போர்வெல்)',
            'Govt Water (நகராட்சி குடிநீர்)',
            'Bore + Govt Water (இரண்டும்)',
          ].map((w) {
            final isSel = _selectedWaterSource.startsWith(w.split(' ').first);
            return ChoiceChip(
              label: Text(w, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: isSel ? Colors.white : AppColors.textPrimary)),
              selected: isSel,
              selectedColor: const Color(0xFF0D47A1),
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8), side: BorderSide(color: isSel ? const Color(0xFF0D47A1) : AppColors.border)),
              onSelected: (val) => setState(() => _selectedWaterSource = w),
            );
          }).toList(),
        ),

        const SizedBox(height: 20),

        _buildSectionTitle('அப்ரூவல் நிலை (Approval)'),
        const SizedBox(height: 8),
        Row(
          children: ['CMDA / DTCP Approved', 'RERA Approved', 'Unapproved'].map((a) {
            final isSel = _selectedAptApproval == a;
            return Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _selectedAptApproval = a),
                child: Container(
                  margin: const EdgeInsets.only(right: 6),
                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
                  decoration: BoxDecoration(
                    color: isSel ? const Color(0xFF0D47A1) : Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: isSel ? const Color(0xFF0D47A1) : AppColors.border),
                  ),
                  child: Center(
                    child: Text(
                      a.split(' ').first,
                      style: TextStyle(color: isSel ? Colors.white : AppColors.textPrimary, fontSize: 11, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),

        const SizedBox(height: 20),

        _buildSectionTitle('மெயின் டோர் திசை (Main Door Facing)'),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedFacing,
              isExpanded: true,
              items: _facingDirections.map((f) => DropdownMenuItem(value: f, child: Text(f, style: const TextStyle(fontSize: 13.5)))).toList(),
              onChanged: (val) => setState(() => _selectedFacing = val!),
            ),
          ),
        ),
      ],
    );
  }

  // --- 4. வாடகைக்கு (For Rent / Lease) Specific Form ---
  Widget _buildRentalSpecificForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildModuleHeader('வாடகைக்கு & லீசுக்கு (Rent & Lease Details)', Icons.key_rounded, const Color(0xFFE65100)),
        const SizedBox(height: 16),

        Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF7ED),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFFED7AA)),
          ),
          child: Row(
            children: [
              const Icon(Icons.check_circle_rounded, color: Color(0xFFEA580C), size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'தேர்ந்தெடுக்கப்பட்ட வாடகை வகை: $_selectedRentalSubType',
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFFC2410C)),
                ),
              ),
            ],
          ),
        ),

        _buildSectionTitle('வாடகை வகை (Rental Sub-Category)'),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _rentalSubTypes.map((sub) {
            final isSel = _selectedRentalSubType == sub;
            return ChoiceChip(
              label: Text(sub, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: isSel ? Colors.white : AppColors.textPrimary)),
              selected: isSel,
              selectedColor: const Color(0xFFE65100),
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8), side: BorderSide(color: isSel ? const Color(0xFFE65100) : AppColors.border)),
              onSelected: (val) => setState(() => _selectedRentalSubType = sub),
            );
          }).toList(),
        ),

        const SizedBox(height: 20),

        _buildSectionTitle('வாடகை முறை (Rent or Lease)'),
        const SizedBox(height: 8),
        Row(
          children: [
            _buildYesNoToggle(
              label: 'மாத வாடகை (Monthly Rent)',
              isSelected: !_isLease,
              onTap: () => setState(() => _isLease = false),
            ),
            const SizedBox(width: 10),
            _buildYesNoToggle(
              label: 'முழு லீஸ் (Full Lease)',
              isSelected: _isLease,
              onTap: () => setState(() => _isLease = true),
            ),
          ],
        ),

        const SizedBox(height: 20),

        Row(
          children: [
            Expanded(
              flex: 1,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildFieldLabel('அட்வான்ஸ் முன்பணம் (₹ Advance)'),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _advanceAmountController,
                    keyboardType: TextInputType.number,
                    decoration: _inputDecoration(hint: '50000', prefixIcon: Icons.account_balance_wallet_outlined),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              flex: 1,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildFieldLabel(_isLease ? 'லீஸ் தொகை (₹ Lease Amount)' : 'மாத வாடகை (₹ Monthly Rent)'),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _rentAmountController,
                    keyboardType: TextInputType.number,
                    decoration: _inputDecoration(hint: '8500', prefixIcon: Icons.currency_rupee_rounded),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  // --- 5. கடை / அலுவலகம் (Shop / Office) Specific Form ---
  Widget _buildShopSpecificForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildModuleHeader('கடை / அலுவலகம் விவரங்கள் (Shop & Office Specs)', Icons.storefront_rounded, const Color(0xFFD97706)),
        const SizedBox(height: 16),

        Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: const Color(0xFFFEF3C7),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFFDE68A)),
          ),
          child: Row(
            children: [
              const Icon(Icons.check_circle_rounded, color: Color(0xFFD97706), size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'தேர்ந்தெடுக்கப்பட்ட கடை வகை: $_shopSubType',
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF92400E)),
                ),
              ),
            ],
          ),
        ),

        _buildSectionTitle('அமைவிடம் / பகுதி வகை (Location Type)'),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            'Main Bazaar (மெயின் பஜார்)',
            'Bus Stand / Junction',
            'Highway (ஹைவே ரோடு)',
            'Village / Town',
          ].map((locType) {
            final isSel = _selectedCommercialAreaType == locType;
            return ChoiceChip(
              label: Text(locType, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: isSel ? Colors.white : AppColors.textPrimary)),
              selected: isSel,
              selectedColor: const Color(0xFFD97706),
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8), side: BorderSide(color: isSel ? const Color(0xFFD97706) : AppColors.border)),
              onSelected: (val) => setState(() => _selectedCommercialAreaType = locType),
            );
          }).toList(),
        ),

        const SizedBox(height: 20),

        _buildSectionTitle('கடையின் அளவு (Shop Built-up Area)'),
        const SizedBox(height: 8),
        TextFormField(
          controller: _shopAreaSqFtController,
          keyboardType: TextInputType.number,
          decoration: _inputDecoration(hint: '350', prefixIcon: Icons.square_foot_rounded, suffixText: 'Sq.Ft'),
        ),

        const SizedBox(height: 20),

        _buildSectionTitle('மின் இணைப்பு (EB Connection)*'),
        const SizedBox(height: 8),

        // EB Phase selection (EB உண்டு vs EB இல்லை)
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _shopPowerPhase = 'Single Phase EB'),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
                  decoration: BoxDecoration(
                    color: _shopPowerPhase != 'EB இல்லை' ? const Color(0xFFECFDF5) : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _shopPowerPhase != 'EB இல்லை' ? const Color(0xFF047857) : AppColors.border,
                      width: _shopPowerPhase != 'EB இல்லை' ? 2 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _shopPowerPhase != 'EB இல்லை' ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
                        color: _shopPowerPhase != 'EB இல்லை' ? const Color(0xFF047857) : Colors.grey,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('① EB உண்டு', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: Color(0xFF047857))),
                            Text('மின் இணைப்பு உள்ளது', style: TextStyle(fontSize: 10.5, color: Color(0xFF065F46))),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _shopPowerPhase = 'EB இல்லை'),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
                  decoration: BoxDecoration(
                    color: _shopPowerPhase == 'EB இல்லை' ? Colors.grey.shade100 : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _shopPowerPhase == 'EB இல்லை' ? Colors.grey.shade700 : AppColors.border,
                      width: _shopPowerPhase == 'EB இல்லை' ? 2 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _shopPowerPhase == 'EB இல்லை' ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
                        color: _shopPowerPhase == 'EB இல்லை' ? Colors.grey.shade800 : Colors.grey,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('② EB இல்லை', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: Colors.black87)),
                            Text('மின் இணைப்பு இல்லை', style: TextStyle(fontSize: 10.5, color: Colors.black54)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 20),

        Row(
          children: [
            Expanded(
              flex: 1,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildFieldLabel('அட்வான்ஸ் முன்பணம் (₹ Advance)'),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _advanceAmountController,
                    keyboardType: TextInputType.number,
                    decoration: _inputDecoration(hint: '50000', prefixIcon: Icons.account_balance_wallet_outlined),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              flex: 1,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildFieldLabel('மாத வாடகை (₹ Monthly Rent)'),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _rentAmountController,
                    keyboardType: TextInputType.number,
                    decoration: _inputDecoration(hint: '10000', prefixIcon: Icons.currency_rupee_rounded),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ==============================================================
  // STEP 3: Financial Details, Photo Upload & Live Card Preview
  // ==============================================================
  Widget _buildStep3PriceAndPreview() {
    final double rawPrice = double.tryParse(_priceController.text) ?? 2500000;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('1. விலை & பேசலாம் வசதி (Price & Negotiable)'),
        const SizedBox(height: 8),

        if (_selectedMainCategory != 'Rental') ...[
          TextFormField(
            controller: _priceController,
            keyboardType: TextInputType.number,
            onChanged: (_) => setState(() {}),
            decoration: _inputDecoration(
              hint: '2500000',
              prefixIcon: Icons.currency_rupee_rounded,
              suffix: Text(
                CurrencyFormatter.formatIndianPrice(rawPrice),
                style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary),
              ),
            ),
          ),
          const SizedBox(height: 10),
        ],

        Row(
          children: [
            _buildYesNoToggle(
              label: 'விலை பேசிக்கலாம் (Negotiable)',
              isSelected: _isPriceNegotiable,
              onTap: () => setState(() => _isPriceNegotiable = true),
            ),
            const SizedBox(width: 10),
            _buildYesNoToggle(
              label: 'நிலையான விலை (Fixed Price)',
              isSelected: !_isPriceNegotiable,
              onTap: () => setState(() => _isPriceNegotiable = false),
            ),
          ],
        ),

        const SizedBox(height: 22),

        _buildSectionTitle('2. புகைப்படங்கள் அப்லோடு (Land / Property Photo Upload)'),
        const SizedBox(height: 8),
        _buildPhotoUploadSection(),

        const SizedBox(height: 22),

        _buildSectionTitle('3. விளம்பரத் தலைப்பு & குறிப்புகள் (Title & Description)'),
        const SizedBox(height: 8),
        TextFormField(
          controller: _titleController,
          decoration: _inputDecoration(hint: 'உதா: தென்காசி மெயின் ரோடு 10 சென்ட் DTCP மனை விற்பனைக்கு'),
        ),
        const SizedBox(height: 10),
        TextFormField(
          controller: _descriptionController,
          maxLines: 3,
          decoration: _inputDecoration(hint: 'நிலத்தின் சிறப்பம்சங்கள், சுவையான நிலத்தடி குடிநீர், தார் சாலை அகலம் பற்றிய விவரங்கள்...'),
        ),

        const SizedBox(height: 24),

        _buildSectionTitle('4. உங்கள் கார்டு முன்னோட்டம் (Live Ad Preview)'),
        const SizedBox(height: 10),
        _buildLiveCardPreview(rawPrice),
      ],
    );
  }

  Widget _buildLiveCardPreview(double rawPrice) {
    String displayArea = '10 Cent';
    if (_selectedMainCategory == 'House') {
      displayArea = '$_houseBhk BHK | ${_houseBuiltAreaSqFtController.text} Sq.Ft (${_houseLandAreaValueController.text} $_houseLandUnit)';
    } else if (_selectedMainCategory == 'Land') {
      displayArea = '${_landAreaValueController.text} $_selectedLandUnit';
    } else if (_selectedMainCategory == 'Farmland') {
      displayArea = '${_farmAreaValueController.text} $_selectedFarmUnit';
    } else if (_selectedMainCategory == 'Apartment') {
      displayArea = '$_selectedBhk BHK (${_aptBuiltSqFtController.text} Sq.Ft)';
    } else if (_selectedMainCategory == 'Shop') {
      displayArea = '${_shopAreaSqFtController.text} Sq.Ft';
    } else if (_selectedMainCategory == 'Rental') {
      displayArea = _selectedRentalSubType;
    }

    final priceStr = _selectedMainCategory == 'Rental'
        ? '₹${_rentAmountController.text}/மாதம்'
        : CurrencyFormatter.formatIndianPrice(rawPrice);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.primary, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.12),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              Container(
                height: 140,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                  color: AppColors.primaryDark,
                  image: _customImageBase64 != null
                      ? DecorationImage(
                          image: MemoryImage(base64Decode(_customImageBase64!)),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: _customImageBase64 == null
                    ? Center(
                        child: Icon(
                          _selectedMainCategory == 'House'
                              ? Icons.home_rounded
                              : (_selectedMainCategory == 'Land'
                                  ? Icons.landscape_rounded
                                  : (_selectedMainCategory == 'Farmland'
                                      ? Icons.agriculture_rounded
                                      : (_selectedMainCategory == 'Shop'
                                          ? Icons.storefront_rounded
                                          : Icons.apartment_rounded))),
                          size: 50,
                          color: Colors.white38,
                        ),
                      )
                    : null,
              ),

              Positioned(
                top: 10,
                right: 10,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4)],
                  ),
                  child: Text(
                    _selectedPosterType,
                    style: const TextStyle(
                      color: AppColors.primaryDark,
                      fontWeight: FontWeight.w800,
                      fontSize: 11,
                    ),
                  ),
                ),
              ),

              Positioned(
                top: 10,
                left: 10,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _selectedMainCategory == 'House'
                        ? '$_houseBhk BHK $_houseSubType'
                        : (_selectedMainCategory == 'Land'
                            ? _selectedApproval
                            : (_selectedMainCategory == 'Farmland' ? 'தோட்டம்' : _selectedMainCategory)),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 11,
                    ),
                  ),
                ),
              ),
            ],
          ),

          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      priceStr,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: _isPriceNegotiable ? Colors.green.shade50 : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: _isPriceNegotiable ? Colors.green : Colors.grey),
                      ),
                      child: Text(
                        _isPriceNegotiable ? 'பேசலாம் (Negotiable)' : 'Fixed',
                        style: TextStyle(
                          color: _isPriceNegotiable ? Colors.green.shade800 : Colors.grey.shade700,
                          fontSize: 10.5,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 6),

                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        displayArea,
                        style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 12),
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.location_on, size: 14, color: AppColors.textMuted),
                    const SizedBox(width: 2),
                    Expanded(
                      child: Text(
                        '${_areaLocalityController.text}, $_selectedDistrict',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: AppColors.textSecondary, fontSize: 12.5),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 8),
                const Divider(height: 1, color: AppColors.borderLight),
                const SizedBox(height: 8),

                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 7),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.call, size: 14, color: AppColors.primary),
                            const SizedBox(width: 4),
                            Text(
                              _contactPhoneController.text.isNotEmpty ? _contactPhoneController.text : 'Call Now',
                              style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 11),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                      decoration: BoxDecoration(
                        color: const Color(0xFF25D366).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.chat_bubble_outline_rounded, size: 14, color: Color(0xFF1B8A44)),
                          SizedBox(width: 4),
                          Text(
                            'WhatsApp',
                            style: TextStyle(color: Color(0xFF1B8A44), fontWeight: FontWeight.bold, fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoUploadSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          if (_customImageBase64 != null) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.memory(
                base64Decode(_customImageBase64!),
                height: 160,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton.icon(
                  onPressed: _pickPhoto,
                  icon: const Icon(Icons.change_circle_outlined, size: 16),
                  label: const Text('புகைப்படம் மாற்றுக', style: TextStyle(fontSize: 12)),
                ),
                TextButton.icon(
                  onPressed: () => setState(() => _customImageBase64 = null),
                  icon: const Icon(Icons.delete_outline, size: 16, color: Colors.red),
                  label: const Text('நீக்குக', style: TextStyle(fontSize: 12, color: Colors.red)),
                ),
              ],
            ),
          ] else ...[
            InkWell(
              onTap: _pickPhoto,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.primary.withValues(alpha: 0.4), style: BorderStyle.solid),
                ),
                child: Column(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                      child: _isPickingImage
                          ? const Center(child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)))
                          : const Icon(Icons.add_a_photo_rounded, color: Colors.white, size: 24),
                    ),
                    const SizedBox(height: 10),
                    const Text('நிலத்தின் புகைப்படங்கள் சேர்க்க (Upload Photos)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.primaryDark)),
                    const SizedBox(height: 4),
                    const Text('Camera அல்லது Gallery-லிருந்து தேர்வு செய்யலாம்', style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
    );
  }

  Widget _buildFieldLabel(String label) {
    return Text(
      label,
      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
    );
  }

  Widget _buildModuleHeader(String title, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              title,
              style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 13.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPosterTypeOption(String id, String titleTa, IconData icon) {
    final isSel = _selectedPosterType == id;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedPosterType = id),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
          decoration: BoxDecoration(
            color: isSel ? AppColors.primary : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: isSel ? AppColors.primary : AppColors.border),
            boxShadow: isSel ? [BoxShadow(color: AppColors.primary.withValues(alpha: 0.25), blurRadius: 6)] : null,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 20, color: isSel ? Colors.white : AppColors.primary),
              const SizedBox(height: 4),
              Text(
                titleTa,
                style: TextStyle(color: isSel ? Colors.white : AppColors.textPrimary, fontSize: 11, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Map<String, dynamic> _getCategoryMeta(String catId) {
    switch (catId) {
      case 'Land':
        return {
          'id': 'Land',
          'nameTa': 'நிலம் / பிளாட்',
          'nameEn': 'Plots & Land',
          'icon': Icons.landscape_rounded,
          'color': const Color(0xFF1B5E20),
        };
      case 'Farmland':
        return {
          'id': 'Farmland',
          'nameTa': 'தோட்டம் / விவசாயம்',
          'nameEn': 'Farm & Thottam',
          'icon': Icons.agriculture_rounded,
          'color': const Color(0xFF2E7D32),
        };
      case 'Shop':
        return {
          'id': 'Shop',
          'nameTa': 'கடை / வணிகம்',
          'nameEn': 'Shop & Office',
          'icon': Icons.storefront_rounded,
          'color': const Color(0xFFD97706),
        };
      case 'Apartment':
        return {
          'id': 'Apartment',
          'nameTa': 'அபார்ட்மெண்ட்',
          'nameEn': 'Flats & Apartments',
          'icon': Icons.apartment_rounded,
          'color': const Color(0xFF0D47A1),
        };
      case 'Rental':
        return {
          'id': 'Rental',
          'nameTa': 'வாடகைக்கு / லீஸ்',
          'nameEn': 'Rent & Lease',
          'icon': Icons.key_rounded,
          'color': const Color(0xFFE65100),
        };
      case 'House':
      default:
        return {
          'id': 'House',
          'nameTa': 'வீடு / தனி வீடு',
          'nameEn': 'House & Villa',
          'icon': Icons.home_rounded,
          'color': const Color(0xFF0284C7),
        };
    }
  }

  Widget _buildSelectedCategoryHeader() {
    final meta = _getCategoryMeta(_selectedMainCategory);
    final color = meta['color'] as Color;

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 1.2),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(meta['icon'] as IconData, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'தேர்ந்தெடுக்கப்பட்ட முதன்மை பிரிவு (Selected Category):',
                  style: TextStyle(fontSize: 10.5, color: AppColors.textSecondary, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 2),
                Text(
                  '${meta['nameTa']} (${meta['nameEn']})',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
          InkWell(
            onTap: _showChangeCategoryBottomSheet,
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: color.withValues(alpha: 0.4)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.swap_horiz_rounded, size: 15, color: color),
                  const SizedBox(width: 4),
                  Text(
                    'மாற்ற',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: color),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showChangeCategoryBottomSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      backgroundColor: Colors.white,
      builder: (ctx) {
        final categories = [
          _getCategoryMeta('House'),
          _getCategoryMeta('Land'),
          _getCategoryMeta('Farmland'),
          _getCategoryMeta('Shop'),
          _getCategoryMeta('Apartment'),
          _getCategoryMeta('Rental'),
        ];
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'முதன்மை பிரிவை மாற்றுக (Change Category)',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: categories.map((cat) {
                    final isSel = _selectedMainCategory == cat['id'];
                    final c = cat['color'] as Color;
                    return InkWell(
                      onTap: () {
                        setState(() {
                          _selectedMainCategory = cat['id'] as String;
                          _autoGenerateTitle();
                        });
                        Navigator.pop(ctx);
                      },
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: isSel ? c : c.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: c, width: isSel ? 2 : 1),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(cat['icon'] as IconData, size: 16, color: isSel ? Colors.white : c),
                            const SizedBox(width: 6),
                            Text(
                              cat['nameTa'] as String,
                              style: TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w700,
                                color: isSel ? Colors.white : c,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSubCategorySelector() {
    List<Map<String, dynamic>> subCats = [];

    if (_selectedMainCategory == 'Land') {
      subCats = [
        {'id': 'DTCP Approved மனை', 'ta': 'DTCP மனை', 'en': 'DTCP Approved', 'icon': Icons.verified_rounded, 'color': const Color(0xFF047857)},
        {'id': 'RERA Approved மனை', 'ta': 'RERA மனை', 'en': 'RERA Approved', 'icon': Icons.verified_user_rounded, 'color': const Color(0xFF0284C7)},
        {'id': 'பஞ்சாயத்து அப்ரூவல் மனை', 'ta': 'பஞ்சாயத்து மனை', 'en': 'Panchayat Approved', 'icon': Icons.account_balance_rounded, 'color': const Color(0xFFD97706)},
        {'id': 'பட்டா மனை / Unapproved', 'ta': 'பட்டா மனை', 'en': 'Patta / Individual', 'icon': Icons.description_rounded, 'color': const Color(0xFF475569)},
        {'id': 'காலி வீட்டு மனை', 'ta': 'காலி மனை', 'en': 'Residential Plot', 'icon': Icons.landscape_rounded, 'color': const Color(0xFF059669)},
        {'id': 'விவசாய பூமி / நஞ்சை', 'ta': 'விவசாய பூமி', 'en': 'Agri Land', 'icon': Icons.grass_rounded, 'color': const Color(0xFF15803D)},
        {'id': 'வணிக மனை / Commercial', 'ta': 'வணிக மனை', 'en': 'Commercial Plot', 'icon': Icons.store_mall_directory_rounded, 'color': const Color(0xFFB45309)},
      ];
    } else if (_selectedMainCategory == 'House') {
      subCats = [
        {'id': 'தனி வீடு', 'ta': 'தனி வீடு', 'en': 'Independent House', 'icon': Icons.home_rounded, 'color': const Color(0xFF0284C7)},
        {'id': 'வில்லா', 'ta': 'வில்லா (Villa)', 'en': 'Villa House', 'icon': Icons.villa_rounded, 'color': const Color(0xFF0284C7)},
        {'id': 'பண்ணை வீடு', 'ta': 'பண்ணை வீடு', 'en': 'Farm House', 'icon': Icons.cottage_rounded, 'color': const Color(0xFF15803D)},
        {'id': 'கெஸ்ட் House', 'ta': 'கெஸ்ட் House', 'en': 'Guest House', 'icon': Icons.bungalow_rounded, 'color': const Color(0xFF0D9488)},
        {'id': 'நத்தம் பட்டா வீடு', 'ta': 'நத்தம் பட்டா வீடு', 'en': 'Natham Patta House', 'icon': Icons.badge_rounded, 'color': const Color(0xFFD97706)},
        {'id': 'ஓட்டு வீடு', 'ta': 'ஓட்டு வீடு', 'en': 'Tiled Roof House', 'icon': Icons.roofing_rounded, 'color': const Color(0xFFEA580C)},
        {'id': 'குடிசை வீடு', 'ta': 'குடிசை வீடு', 'en': 'Hut / Kudisai', 'icon': Icons.cabin_rounded, 'color': const Color(0xFF78350F)},
        {'id': 'பஞ்சாயத்து / DTCP அப்ரூவல்', 'ta': 'அப்ரூவல் வீடு', 'en': 'Approved House', 'icon': Icons.verified_rounded, 'color': const Color(0xFF047857)},
        {'id': 'Finance வீடு', 'ta': 'Finance வீடு', 'en': 'Loan / Finance House', 'icon': Icons.account_balance_rounded, 'color': const Color(0xFF4338CA)},
      ];
    } else if (_selectedMainCategory == 'Farmland') {
      subCats = [
        {'id': 'தென்னந்தோப்பு', 'ta': 'தென்னந்தோப்பு', 'en': 'Coconut Farm', 'icon': Icons.nature_rounded, 'color': const Color(0xFF15803D)},
        {'id': 'மாந்தோப்பு', 'ta': 'மாந்தோப்பு', 'en': 'Mango Grove', 'icon': Icons.park_rounded, 'color': const Color(0xFF16A34A)},
        {'id': 'விவசாய நஞ்சை நிலம்', 'ta': 'விவசாய நஞ்சை பூமி', 'en': 'Agricultural Wetland', 'icon': Icons.grass_rounded, 'color': const Color(0xFF047857)},
        {'id': 'புஞ்சை தோட்டம்', 'ta': 'புஞ்சை தோட்டம்', 'en': 'Dryland Farm', 'icon': Icons.landscape_rounded, 'color': const Color(0xFF65A30D)},
        {'id': 'பண்ணை தோட்டம்', 'ta': 'பண்ணை தோட்டம்', 'en': 'Farmhouse with Land', 'icon': Icons.cottage_rounded, 'color': const Color(0xFF059669)},
        {'id': 'குத்தகை தோட்டம்', 'ta': 'குத்தகை தோட்டம்', 'en': 'Farmland for Lease', 'icon': Icons.vpn_key_rounded, 'color': const Color(0xFFD97706)},
      ];
    } else if (_selectedMainCategory == 'Shop') {
      subCats = [
        {'id': 'கடை (Shop)', 'ta': 'கடை (Shop)', 'en': 'Shop', 'icon': Icons.storefront_rounded, 'color': const Color(0xFFD97706)},
        {'id': 'மெயின் பஜார் கடை', 'ta': 'மெயின் பஜார் கடை', 'en': 'Main Bazaar Shop', 'icon': Icons.storefront_rounded, 'color': const Color(0xFFB45309)},
        {'id': 'பஸ் ஸ்டாண்ட் / ஜங்ஷன் கடை', 'ta': 'பஸ் ஸ்டாண்ட் கடை', 'en': 'Bus Stand Shop', 'icon': Icons.directions_bus_rounded, 'color': const Color(0xFFB45309)},
        {'id': 'வணிக வளாகம்', 'ta': 'வணிக வளாகம்', 'en': 'Commercial Complex', 'icon': Icons.business_rounded, 'color': const Color(0xFF78350F)},
        {'id': 'அலுவலக இடம்', 'ta': 'அலுவலக இடம்', 'en': 'Office Space', 'icon': Icons.desktop_windows_rounded, 'color': const Color(0xFF0284C7)},
        {'id': 'ஷோரூம்', 'ta': 'ஷோரூம் இடம்', 'en': 'Showroom Space', 'icon': Icons.store_mall_directory_rounded, 'color': const Color(0xFF0D9488)},
        {'id': 'குடோன் / Warehouse', 'ta': 'குடோன் / Warehouse', 'en': 'Godown / Storage', 'icon': Icons.warehouse_rounded, 'color': const Color(0xFF475569)},
      ];
    } else if (_selectedMainCategory == 'Apartment') {
      subCats = [
        {'id': '1 BHK அபார்ட்மெண்ட்', 'ta': '1 BHK பிளாட்', 'en': '1 BHK Apartment', 'icon': Icons.apartment_rounded, 'color': const Color(0xFF0D47A1)},
        {'id': '2 BHK அபார்ட்மெண்ட்', 'ta': '2 BHK பிளாட்', 'en': '2 BHK Apartment', 'icon': Icons.apartment_rounded, 'color': const Color(0xFF0284C7)},
        {'id': '3 BHK ஆடம்பர பிளாட்', 'ta': '3 BHK ஆடம்பர பிளாட்', 'en': '3 BHK Luxury Flat', 'icon': Icons.apartment_rounded, 'color': const Color(0xFF1E3A8A)},
        {'id': 'ஸ்டுடியோ பிளாட்', 'ta': 'ஸ்டுடியோ பிளாட்', 'en': 'Studio Flat', 'icon': Icons.room_preferences_rounded, 'color': const Color(0xFF0D9488)},
        {'id': 'பென்ட்ஹவுஸ் / டூப்ளக்ஸ்', 'ta': 'பென்ட்ஹவுஸ்', 'en': 'Penthouse / Duplex', 'icon': Icons.holiday_village_rounded, 'color': const Color(0xFF7C3AED)},
        {'id': 'கேடட் கம்யூனிட்டி பிளாட்', 'ta': 'கேடட் கம்யூனிட்டி', 'en': 'Gated Community Flat', 'icon': Icons.security_rounded, 'color': const Color(0xFF047857)},
      ];
    } else {
      subCats = [
        {'id': 'வீடு (House)', 'ta': 'வாடகை வீடு', 'en': 'House for Rent', 'icon': Icons.home_rounded, 'color': const Color(0xFFE65100)},
        {'id': 'கடை (Shop)', 'ta': 'வாடகை கடை', 'en': 'Shop for Rent', 'icon': Icons.storefront_rounded, 'color': const Color(0xFFD97706)},
        {'id': 'Complex (வணிக வளாகம்)', 'ta': 'வணிக வளாகம் வாடகை', 'en': 'Commercial Complex', 'icon': Icons.business_rounded, 'color': const Color(0xFF78350F)},
        {'id': 'காலி இடம் / நிலம்', 'ta': 'காலி இடம் வாடகை', 'en': 'Empty Land Rent', 'icon': Icons.landscape_rounded, 'color': const Color(0xFF047857)},
        {'id': 'தோட்டம் (குத்தகைக்கு)', 'ta': 'தோட்டம் குத்தகைக்கு', 'en': 'Farmland for Lease', 'icon': Icons.agriculture_rounded, 'color': const Color(0xFF15803D)},
        {'id': 'அலுவலகம் (Office)', 'ta': 'அலுவலகம் வாடகை', 'en': 'Office for Rent', 'icon': Icons.desktop_windows_rounded, 'color': const Color(0xFF0284C7)},
        {'id': 'Business (வணிக இடம்)', 'ta': 'வணிக இடம்', 'en': 'Business Space', 'icon': Icons.store_rounded, 'color': const Color(0xFFEA580C)},
      ];
    }

    String currentSelectedSub = '';
    if (_selectedMainCategory == 'Land') {
      currentSelectedSub = _landSubType;
    } else if (_selectedMainCategory == 'House') {
      currentSelectedSub = _houseSubType;
    } else if (_selectedMainCategory == 'Farmland') {
      currentSelectedSub = _farmSubType;
    } else if (_selectedMainCategory == 'Shop') {
      currentSelectedSub = _shopSubType;
    } else if (_selectedMainCategory == 'Apartment') {
      currentSelectedSub = _aptSubType;
    } else {
      currentSelectedSub = _selectedRentalSubType;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('2. உட்பிரிவு / சப்-கேட்டகிரி தேர்வு செய்க (Select Sub-Category)*'),
        const SizedBox(height: 10),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: subCats.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            childAspectRatio: 2.25,
          ),
          itemBuilder: (context, index) {
            final item = subCats[index];
            final id = item['id'] as String;
            final isSel = currentSelectedSub == id;
            final color = item['color'] as Color;

            return GestureDetector(
              onTap: () {
                setState(() {
                  if (_selectedMainCategory == 'Land') {
                    _landSubType = id;
                    if (id.contains('DTCP')) {
                      _selectedApproval = 'DTCP Approved';
                    } else if (id.contains('RERA')) {
                      _selectedApproval = 'RERA Approved';
                    } else if (id.contains('பஞ்சாயத்து')) {
                      _selectedApproval = 'Panchayat Approved';
                    } else if (id.contains('Unapproved') || id.contains('பட்டா')) {
                      _selectedApproval = 'Unapproved';
                    }
                  } else if (_selectedMainCategory == 'House') {
                    _houseSubType = id;
                  } else if (_selectedMainCategory == 'Farmland') {
                    _farmSubType = id;
                  } else if (_selectedMainCategory == 'Shop') {
                    _shopSubType = id;
                    if (id.contains('மெயின் பஜார்')) {
                      _selectedCommercialAreaType = 'Main Bazaar (மெயின் பஜார்)';
                    } else if (id.contains('பஸ் ஸ்டாண்ட்')) {
                      _selectedCommercialAreaType = 'Bus Stand / Junction';
                    } else if (id.contains('அலுவலக')) {
                      _selectedCommercialAreaType = 'Office Space';
                    }
                  } else if (_selectedMainCategory == 'Apartment') {
                    _aptSubType = id;
                    if (id.contains('1 BHK')) {
                      _selectedBhk = 1;
                    } else if (id.contains('2 BHK')) {
                      _selectedBhk = 2;
                    } else if (id.contains('3 BHK')) {
                      _selectedBhk = 3;
                    }
                  } else {
                    _selectedRentalSubType = id;
                  }
                  _autoGenerateTitle();
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(
                  color: isSel ? color : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSel ? color : AppColors.border,
                    width: isSel ? 2 : 1,
                  ),
                  boxShadow: isSel
                      ? [BoxShadow(color: color.withValues(alpha: 0.28), blurRadius: 6, offset: const Offset(0, 2))]
                      : [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 4)],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: isSel ? Colors.white.withValues(alpha: 0.22) : color.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(item['icon'] as IconData, size: 16, color: isSel ? Colors.white : color),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            item['ta'] as String,
                            style: TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w800,
                              color: isSel ? Colors.white : AppColors.textPrimary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            item['en'] as String,
                            style: TextStyle(
                              fontSize: 9.5,
                              fontWeight: FontWeight.w500,
                              color: isSel ? Colors.white70 : AppColors.textMuted,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    if (isSel)
                      const Icon(Icons.check_circle_rounded, color: Colors.white, size: 16),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildYesNoToggle({required String label, required bool isSelected, required VoidCallback onTap}) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: isSelected ? AppColors.primary : AppColors.border),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : AppColors.textPrimary,
                fontSize: 11.5,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ),
    );
  }


  InputDecoration _inputDecoration({required String hint, IconData? prefixIcon, Widget? suffix, String? suffixText}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 13),
      prefixIcon: prefixIcon != null ? Icon(prefixIcon, size: 18, color: AppColors.textMuted) : null,
      suffix: suffix,
      suffixText: suffixText,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.border)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.border)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.primary, width: 1.5)),
    );
  }

  Widget _buildBottomActions() {
    final isLastStep = _currentStep == _totalSteps - 1;

    return SafeArea(
      top: false,
      bottom: true,
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
        decoration: BoxDecoration(
          color: Colors.white,
          border: const Border(top: BorderSide(color: AppColors.border)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: Row(
          children: [
            if (_currentStep > 0) ...[
              Expanded(
                flex: 1,
                child: OutlinedButton(
                  onPressed: () => setState(() => _currentStep--),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    side: const BorderSide(color: AppColors.border),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('பின்செல் (Back)', style: TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(width: 12),
            ],
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _onNextOrSubmit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isLastStep ? Colors.green.shade700 : AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 2,
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                        )
                      : Text(
                          isLastStep ? 'விளம்பரம் பதிவிடு (Post Property)' : 'அடுத்து (Next) →',
                          style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
                        ),
                ),
              ),
            ],
          ),
        ),
      );
  }

  bool _isSubmitting = false;

  void _onNextOrSubmit() {
    if (_isSubmitting) return;
    if (_currentStep < _totalSteps - 1) {
      setState(() => _currentStep++);
    } else {
      if (_customImageBase64 == null || _customImageBase64!.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('⚠️ தயவுசெய்து சொத்தின் புகைப்படத்தை பதிவேற்றவும் (Photo is mandatory)'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }
      _submitProperty();
    }
  }

  Future<void> _pickPhoto() async {
    setState(() => _isPickingImage = true);
    final result = await ImagePickerService.pickFromGallery(maxWidth: 1024, quality: 75);
    if (result != null) {
      setState(() {
        _customImageBase64 = result.base64Data;
      });
    }
    setState(() => _isPickingImage = false);
  }

  Future<void> _detectLocation() async {
    setState(() => _isDetectingLocation = true);
    final loc = await LocationService.getCurrentLiveLocation(context: context);
    if (!mounted) return;
    setState(() {
      _latitude = loc.latitude;
      _longitude = loc.longitude;
      if (loc.estimatedArea.isNotEmpty) {
        _areaLocalityController.text = loc.estimatedArea;
      }
      if (loc.estimatedCity.isNotEmpty) {
        if (_districts.contains(loc.estimatedCity)) {
          _selectedDistrict = loc.estimatedCity;
        } else {
          _selectedDistrict = 'Tenkasi';
        }
      }
      if (_landmarkController.text.isEmpty && loc.estimatedArea.isNotEmpty) {
        _landmarkController.text = '${loc.estimatedArea} மெயின் ரோடு';
      }
      _isDetectingLocation = false;
    });

    if (loc.isLiveGps) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '✅ நேரலை GPS பெறப்பட்டது: ${loc.estimatedArea} (${loc.formattedCoordinates})',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          backgroundColor: const Color(0xFF2E7D32),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else if (loc.error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('⚠️ ${loc.error}'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _submitProperty() async {
    if (_customImageBase64 == null || _customImageBase64!.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('⚠️ தயவுசெய்து சொத்தின் புகைப்படத்தை பதிவேற்றவும் (Photo is mandatory)'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final now = DateTime.now();
    final propId = 'user_prop_${now.millisecondsSinceEpoch}';

    int sqFt = 1200;
    String? unit;
    double? unitVal;

    if (_selectedMainCategory == 'House') {
      sqFt = int.tryParse(_houseBuiltAreaSqFtController.text) ?? 1200;
      unit = _houseLandUnit;
      unitVal = double.tryParse(_houseLandAreaValueController.text) ?? 3.0;
    } else if (_selectedMainCategory == 'Land') {
      unitVal = double.tryParse(_landAreaValueController.text) ?? 5.0;
      unit = _selectedLandUnit;
      sqFt = LandUnitConverter.toSqFt(unitVal, unit);
    } else if (_selectedMainCategory == 'Farmland') {
      unitVal = double.tryParse(_farmAreaValueController.text) ?? 2.0;
      unit = _selectedFarmUnit;
      sqFt = LandUnitConverter.toSqFt(unitVal, unit);
    } else if (_selectedMainCategory == 'Apartment') {
      sqFt = int.tryParse(_aptBuiltSqFtController.text) ?? 1050;
      unit = 'Sq.Ft';
    } else if (_selectedMainCategory == 'Shop') {
      sqFt = int.tryParse(_shopAreaSqFtController.text) ?? 350;
      unit = 'Sq.Ft';
    }

    final double price = (_selectedMainCategory == 'Rental' || _selectedMainCategory == 'Shop')
        ? (double.tryParse(_rentAmountController.text) ?? 10000)
        : (double.tryParse(_priceController.text) ?? 2500000);

    final title = _titleController.text.isNotEmpty
        ? _titleController.text
        : '$_selectedMainCategory in ${_areaLocalityController.text}, $_selectedDistrict';

    final fullLocation = '${_areaLocalityController.text}, $_selectedDistrict';

    final currentUser = ref.read(userProfileProvider);
    final userAgentPhone = _contactPhoneController.text.trim().isNotEmpty ? _contactPhoneController.text.trim() : currentUser.phone;
    final userAgentEmail = currentUser.email.isNotEmpty ? currentUser.email : 'user@tenkasidreams.com';
    final userAgentName = currentUser.name.isNotEmpty ? currentUser.name : '${_selectedPosterType.contains('Owner') ? 'உரிமையாளர்' : _selectedPosterType} (You)';



    final newProperty = Property(
      id: propId,
      title: title,
      description: _descriptionController.text.isNotEmpty
          ? _descriptionController.text
          : 'Verified $_selectedMainCategory property in $fullLocation.',
      price: price,
      location: fullLocation,
      city: _selectedDistrict,
      propertyType: _selectedMainCategory,
      areaSqFt: sqFt,
      bedrooms: _selectedMainCategory == 'House' ? _houseBhk : (_selectedMainCategory == 'Apartment' ? _selectedBhk : null),
      furnishingStatus: _selectedMainCategory == 'House' ? _houseStatus : 'Semi-Furnished',
      posterType: _selectedPosterType,
      landUnit: unit,
      landUnitValue: unitVal,
      landFeatures: _selectedMainCategory == 'House'
          ? _selectedHouseAmenities.toList()
          : (_selectedMainCategory == 'Land' ? _selectedLandFeatures.toList() : _selectedFarmWaterEb.toList()),
      approvalType: _selectedMainCategory == 'House'
          ? (_houseSubType.contains('அப்ரூவல்') ? 'Approved' : (_houseSubType.contains('Un-Approved') ? 'Unapproved' : 'Natham Patta'))
          : (_selectedMainCategory == 'Land' ? _selectedApproval : _selectedAptApproval),
      isBankLoanAvailable: _selectedMainCategory == 'House' ? (_houseSubType.contains('Finance') || _isBankLoanAvailable) : false,
      isPriceNegotiable: _isPriceNegotiable,
      contactPhone: userAgentPhone,
      facing: _selectedFacing,
      landmark: _landmarkController.text,
      latitude: _latitude,
      longitude: _longitude,
      customImageBase64: _customImageBase64,
      waterSource: _selectedWaterSource,
      hasLift: _hasLift,
      hasTrees: _selectedMainCategory == 'Farmland' ? _hasTrees : false,
      treesDetails: (_selectedMainCategory == 'Farmland' && _hasTrees) ? _treesDetailsController.text : null,
      hasIncome: _selectedMainCategory == 'Farmland' ? _hasIncome : false,
      incomeDetails: (_selectedMainCategory == 'Farmland' && _hasIncome) ? _incomeDetailsController.text : null,
      rentalSubType: _selectedMainCategory == 'House'
          ? _houseSubType
          : (_selectedMainCategory == 'Land'
              ? _landSubType
              : (_selectedMainCategory == 'Farmland'
                  ? _farmSubType
                  : (_selectedMainCategory == 'Shop'
                      ? _shopSubType
                      : (_selectedMainCategory == 'Apartment'
                          ? _aptSubType
                          : _selectedRentalSubType)))),
      advanceAmount: double.tryParse(_advanceAmountController.text),
      commercialAreaType: _selectedMainCategory == 'Shop' ? _selectedCommercialAreaType : null,
      hasTable: _selectedMainCategory == 'Shop' ? _shopHasTable : false,
      hasFan: _selectedMainCategory == 'Shop' ? _shopHasFan : false,
      hasWaterSupply: _selectedMainCategory == 'Shop' ? _shopHasWater : false,
      hasShutter: _selectedMainCategory == 'Shop' ? _shopHasShutter : false,
      powerPhase: _selectedMainCategory == 'Shop' ? _shopPowerPhase : null,
      agent: Agent(
        id: 'agent_${userAgentPhone.isNotEmpty ? userAgentPhone : (currentUser.email.isNotEmpty ? currentUser.email : 'user')}',
        name: userAgentName,
        agencyName: 'Tenkasi Dreams Verified',
        phone: userAgentPhone,
        email: userAgentEmail,
        avatarKey: 'avatar_user',
        rating: 5.0,
        reviewsCount: 1,
        experienceYears: 2,
        totalListings: 1,
        isVerified: true,
        about: 'Direct verified owner specializing in Tenkasi real estate.',
      ),
      postedDate: now,
      status: 'pending',
      isPremium: (_selectedPosterType == 'Owner'),
      isUserPosted: true,
    );

    await ref.read(propertiesProvider.notifier).addProperty(newProperty);
    unawaited(ref.read(propertiesProvider.notifier).syncWithServer());

    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => PostSuccessScreen(property: newProperty),
        ),
      );
    }
  }
}

