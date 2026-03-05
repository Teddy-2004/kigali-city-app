import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/listing.dart';
import '../../providers/listing_provider.dart';
import '../../providers/auth_provider.dart' as ap;
import '../../theme.dart';

class AddListingScreen extends StatefulWidget {
  final Listing? listing; // if provided, edit mode

  const AddListingScreen({super.key, this.listing});

  @override
  State<AddListingScreen> createState() => _AddListingScreenState();
}

class _AddListingScreenState extends State<AddListingScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _addressCtrl;
  late final TextEditingController _contactCtrl;
  late final TextEditingController _descCtrl;
  late final TextEditingController _latCtrl;
  late final TextEditingController _lngCtrl;
  String _selectedCategory = kCategories[0];
  bool _isSaving = false;

  bool get isEditing => widget.listing != null;

  @override
  void initState() {
    super.initState();
    final l = widget.listing;
    _nameCtrl = TextEditingController(text: l?.name ?? '');
    _addressCtrl = TextEditingController(text: l?.address ?? '');
    _contactCtrl = TextEditingController(text: l?.contactNumber ?? '');
    _descCtrl = TextEditingController(text: l?.description ?? '');
    _latCtrl = TextEditingController(text: l?.latitude.toString() ?? '');
    _lngCtrl = TextEditingController(text: l?.longitude.toString() ?? '');
    if (l != null) _selectedCategory = l.category;
  }

  @override
  void dispose() {
    for (final c in [_nameCtrl, _addressCtrl, _contactCtrl, _descCtrl, _latCtrl, _lngCtrl]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    final uid = context.read<ap.AuthProvider>().user?.uid ?? '';
    final provider = context.read<ListingProvider>();

    final listing = Listing(
      id: widget.listing?.id ?? '',
      name: _nameCtrl.text.trim(),
      category: _selectedCategory,
      address: _addressCtrl.text.trim(),
      contactNumber: _contactCtrl.text.trim(),
      description: _descCtrl.text.trim(),
      latitude: double.tryParse(_latCtrl.text) ?? -1.9441,
      longitude: double.tryParse(_lngCtrl.text) ?? 30.0619,
      createdBy: uid,
      timestamp: isEditing ? widget.listing!.timestamp : DateTime.now(),
    );

    bool success;
    if (isEditing) {
      success = await provider.updateListing(listing);
    } else {
      success = await provider.createListing(listing);
    }

    setState(() => _isSaving = false);

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(isEditing ? 'Listing updated!' : 'Listing created!')),
      );
      Navigator.pop(context);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.errorMessage ?? 'Failed to save listing'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Listing' : 'Add Listing'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          TextButton(
            onPressed: _isSaving ? null : _save,
            child: _isSaving
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
                  )
                : const Text('Save', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _field(_nameCtrl, 'Place / Service Name', Icons.store_outlined,
                    validator: (v) => (v?.isEmpty ?? true) ? 'Name is required' : null),
                const SizedBox(height: 16),
                // Category dropdown
                DropdownButtonFormField<String>(
                  initialValue: _selectedCategory,
                  dropdownColor: AppColors.surface,
                  decoration: const InputDecoration(
                    labelText: 'Category',
                    prefixIcon: Icon(Icons.category_outlined, color: AppColors.textMuted),
                  ),
                  style: const TextStyle(color: AppColors.textPrimary),
                  items: kCategories
                      .map((cat) => DropdownMenuItem(value: cat, child: Text(cat)))
                      .toList(),
                  onChanged: (v) => setState(() => _selectedCategory = v!),
                ),
                const SizedBox(height: 16),
                _field(_addressCtrl, 'Address', Icons.location_on_outlined,
                    validator: (v) => (v?.isEmpty ?? true) ? 'Address is required' : null),
                const SizedBox(height: 16),
                _field(_contactCtrl, 'Contact Number', Icons.phone_outlined,
                    keyboardType: TextInputType.phone),
                const SizedBox(height: 16),
                _field(_descCtrl, 'Description', Icons.description_outlined,
                    maxLines: 4,
                    validator: (v) => (v?.isEmpty ?? true) ? 'Description is required' : null),
                const SizedBox(height: 16),
                const Text(
                  'Geographic Coordinates',
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: _field(_latCtrl, 'Latitude', Icons.my_location,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                          validator: (v) {
                            if (v == null || v.isEmpty) return 'Required';
                            if (double.tryParse(v) == null) return 'Invalid';
                            return null;
                          }),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _field(_lngCtrl, 'Longitude', Icons.my_location,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                          validator: (v) {
                            if (v == null || v.isEmpty) return 'Required';
                            if (double.tryParse(v) == null) return 'Invalid';
                            return null;
                          }),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  'Kigali center: lat -1.9441, lng 30.0619',
                  style: TextStyle(color: AppColors.textMuted, fontSize: 12),
                ),
                const SizedBox(height: 32),
                ElevatedButton.icon(
                  onPressed: _isSaving ? null : _save,
                  icon: Icon(isEditing ? Icons.save : Icons.add),
                  label: Text(isEditing ? 'Update Listing' : 'Create Listing'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _field(
    TextEditingController ctrl,
    String label,
    IconData icon, {
    int? maxLines,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: ctrl,
      maxLines: maxLines ?? 1,
      keyboardType: keyboardType,
      style: const TextStyle(color: AppColors.textPrimary),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppColors.textMuted),
        alignLabelWithHint: maxLines != null && maxLines > 1,
      ),
      validator: validator,
    );
  }
}
