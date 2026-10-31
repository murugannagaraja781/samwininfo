import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../models/property.dart';
import '../../state/app_state_providers.dart';

class EditPropertyScreen extends ConsumerStatefulWidget {
  final Property property;

  const EditPropertyScreen({super.key, required this.property});

  @override
  ConsumerState<EditPropertyScreen> createState() => _EditPropertyScreenState();
}

class _EditPropertyScreenState extends ConsumerState<EditPropertyScreen> {
  late TextEditingController _titleController;
  late TextEditingController _priceController;
  late TextEditingController _descriptionController;
  late TextEditingController _areaController;
  late String _status;

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.property.title);
    _priceController = TextEditingController(text: widget.property.price.toInt().toString());
    _descriptionController = TextEditingController(text: widget.property.description);
    _areaController = TextEditingController(text: widget.property.areaSqFt.toString());
    _status = widget.property.status;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    _areaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Edit Listing'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Ad Status', style: AppTextStyles.labelLarge),
              const SizedBox(height: 8),
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment(value: 'active', label: Text('Active')),
                  ButtonSegment(value: 'pending', label: Text('Pending')),
                  ButtonSegment(value: 'sold', label: Text('Sold/Rented')),
                ],
                selected: {_status},
                onSelectionChanged: (newVal) {
                  setState(() => _status = newVal.first);
                },
              ),

              const SizedBox(height: 20),

              Text('Title *', style: AppTextStyles.labelLarge),
              const SizedBox(height: 8),
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(),
                validator: (val) => val == null || val.trim().isEmpty ? 'Title is required' : null,
              ),

              const SizedBox(height: 18),

              Text('Price (₹) *', style: AppTextStyles.labelLarge),
              const SizedBox(height: 8),
              TextFormField(
                controller: _priceController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(prefixIcon: Icon(Icons.currency_rupee_rounded, size: 20)),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) return 'Price is required';
                  if (double.tryParse(val) == null) return 'Enter valid number';
                  return null;
                },
              ),

              const SizedBox(height: 18),

              Text('Built-up Area (Sq.Ft) *', style: AppTextStyles.labelLarge),
              const SizedBox(height: 8),
              TextFormField(
                controller: _areaController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(suffixText: 'sq.ft'),
                validator: (val) => val == null || int.tryParse(val) == null ? 'Enter valid sq.ft' : null,
              ),

              const SizedBox(height: 18),

              Text('Description *', style: AppTextStyles.labelLarge),
              const SizedBox(height: 8),
              TextFormField(
                controller: _descriptionController,
                maxLines: 5,
                decoration: const InputDecoration(),
                validator: (val) => val == null || val.trim().length < 10 ? 'Min 10 characters required' : null,
              ),

              const SizedBox(height: 30),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _saveChanges,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: const Text('Save Changes'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _saveChanges() async {
    if (_formKey.currentState!.validate()) {
      final updated = widget.property.copyWith(
        title: _titleController.text.trim(),
        price: double.parse(_priceController.text.trim()),
        areaSqFt: int.parse(_areaController.text.trim()),
        description: _descriptionController.text.trim(),
        status: _status,
      );

      await ref.read(propertiesProvider.notifier).updateProperty(updated);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Listing updated successfully!'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: AppColors.success,
          ),
        );
        Navigator.pop(context);
      }
    }
  }
}
