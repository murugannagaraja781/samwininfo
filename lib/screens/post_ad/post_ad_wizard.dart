import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/l10n/locale_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/land_units.dart';
import '../../models/agent.dart';
import '../../models/property.dart';
import '../../state/app_state_providers.dart';
import 'step_category.dart';
import 'step_contact.dart';
import 'step_details.dart';
import 'step_pricing.dart';

class PostAdWizard extends ConsumerStatefulWidget {
  const PostAdWizard({super.key});

  @override
  ConsumerState<PostAdWizard> createState() => _PostAdWizardState();
}

class _PostAdWizardState extends ConsumerState<PostAdWizard> {
  final PageController _pageController = PageController();
  int _currentStep = 0;
  static const int _totalSteps = 4;

  // Step 1 State
  String _selectedCategory = 'Plots';

  // Step 2 State
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  String _selectedFacing = 'East';
  bool _isDtcpVerified = true;

  // Step 3 State
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _areaController = TextEditingController();
  String _selectedUnit = 'Cents';

  // Step 4 State
  final TextEditingController _locationController =
      TextEditingController(text: 'Surandai Road, Tenkasi');
  final TextEditingController _sellerNameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  int _selectedPhotoIndex = 0;

  @override
  void initState() {
    super.initState();
    // Pre-populate seller info from user profile if available
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final profile = ref.read(userProfileProvider);
      if (profile.name.isNotEmpty) {
        _sellerNameController.text = profile.name;
      }
      if (profile.phone.isNotEmpty) {
        _phoneController.text = profile.phone;
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _titleController.dispose();
    _descController.dispose();
    _priceController.dispose();
    _areaController.dispose();
    _locationController.dispose();
    _sellerNameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _goToNextStep() {
    if (_currentStep == 1) {
      if (_titleController.text.trim().isEmpty) {
        _showError('Please enter a property title');
        return;
      }
    } else if (_currentStep == 2) {
      final price = double.tryParse(_priceController.text.trim()) ?? 0;
      if (price <= 0) {
        _showError('Please enter a valid price');
        return;
      }
      final area = double.tryParse(_areaController.text.trim()) ?? 0;
      if (area <= 0) {
        _showError('Please enter the land measurement value');
        return;
      }
    }

    if (_currentStep < _totalSteps - 1) {
      setState(() => _currentStep++);
      _pageController.animateToPage(
        _currentStep,
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeInOut,
      );
    } else {
      _submitAd();
    }
  }

  void _goToPreviousStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
      _pageController.animateToPage(
        _currentStep,
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeInOut,
      );
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _submitAd() async {
    final title = _titleController.text.trim().isNotEmpty
        ? _titleController.text.trim()
        : 'Prime $_selectedUnit $_selectedCategory in Tenkasi';
    final desc = _descController.text.trim().isNotEmpty
        ? _descController.text.trim()
        : 'Excellent DTCP approved property located in prime Tenkasi area with good road access and sweet water.';
    final price = double.tryParse(_priceController.text.trim()) ?? 2500000.0;
    final unitVal = double.tryParse(_areaController.text.trim()) ?? 5.0;
    final sqFt = LandUnitConverter.toSqFt(unitVal, _selectedUnit);
    final location = _locationController.text.trim().isNotEmpty
        ? _locationController.text.trim()
        : 'Tenkasi, Tamil Nadu';
    final sellerName = _sellerNameController.text.trim().isNotEmpty
        ? _sellerNameController.text.trim()
        : 'Tenkasi Seller';
    final phone = _phoneController.text.trim().isNotEmpty
        ? _phoneController.text.trim()
        : '9842100000';

    final newProperty = Property(
      id: 'prop_user_${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      description: desc,
      price: price,
      location: location,
      city: 'Tenkasi',
      propertyType: _selectedCategory,
      areaSqFt: sqFt,
      landUnit: _selectedUnit,
      landUnitValue: unitVal,
      facing: _selectedFacing,
      floor: 'Ground Floor',
      isVerified: _isDtcpVerified,
      isFeatured: true,
      isUserPosted: true,
      status: 'active',
      views: 1,
      enquiries: 0,
      postedDate: DateTime.now(),
      agent: Agent(
        id: 'agent_user',
        name: sellerName,
        agencyName: 'Direct Owner / Seller',
        phone: phone,
        email: 'seller@tenkasidreams.com',
        avatarKey: 'agent_1',
        rating: 5.0,
        reviewsCount: 1,
        experienceYears: 5,
        totalListings: 1,
        isVerified: true,
        about: 'Direct seller in Tenkasi',
      ),
    );

    // Save to riverpod provider & local storage
    await ref.read(propertiesProvider.notifier).addProperty(newProperty);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle_rounded, color: Colors.white),
              const SizedBox(width: 10),
              Expanded(child: Text(ref.tr('post_success_msg'))),
            ],
          ),
          backgroundColor: AppColors.primary,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 3),
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final progress = (_currentStep + 1) / _totalSteps;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          ref.tr('post_ad_title'),
          style: AppTextStyles.h4.copyWith(
            fontWeight: FontWeight.w700,
            fontSize: 16.5,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Text(
                '${_currentStep + 1}/$_totalSteps',
                style: const TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: AppColors.surfaceAlt,
            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
            minHeight: 4,
          ),
        ),
      ),
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          StepCategory(
            selectedType: _selectedCategory,
            onTypeSelected: (type) {
              setState(() => _selectedCategory = type);
              _goToNextStep();
            },
          ),
          StepDetails(
            titleController: _titleController,
            descController: _descController,
            selectedFacing: _selectedFacing,
            onFacingSelected: (facing) => setState(() => _selectedFacing = facing),
            isDtcpVerified: _isDtcpVerified,
            onDtcpToggled: (val) => setState(() => _isDtcpVerified = val),
          ),
          StepPricing(
            priceController: _priceController,
            areaController: _areaController,
            selectedUnit: _selectedUnit,
            onUnitSelected: (unit) => setState(() => _selectedUnit = unit),
          ),
          StepContact(
            locationController: _locationController,
            sellerNameController: _sellerNameController,
            phoneController: _phoneController,
            selectedPhotoIndex: _selectedPhotoIndex,
            onPhotoSelected: (idx) => setState(() => _selectedPhotoIndex = idx),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 18),
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: AppColors.border, width: 1)),
        ),
        child: Row(
          children: [
            if (_currentStep > 0) ...[
              Expanded(
                flex: 1,
                child: OutlinedButton(
                  onPressed: _goToPreviousStep,
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.border, width: 1.5),
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    ref.tr('btn_back'),
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
            ],
            Expanded(
              flex: 2,
              child: ElevatedButton(
                onPressed: _goToNextStep,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  _currentStep == _totalSteps - 1
                      ? ref.tr('btn_post_now')
                      : ref.tr('btn_next'),
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
