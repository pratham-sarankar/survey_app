import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:io';
import '../providers/auth_provider.dart';
import '../providers/survey_provider.dart';
import '../models/survey_entry.dart';
import '../utils/validators.dart';
import '../utils/dialog_helper.dart';
import '../services/location_service.dart';
import '../config/service_locator.dart';
import '../widgets/location_map_widget.dart';

class AddEntryScreen extends StatefulWidget {
  final SurveyEntry? entry;

  const AddEntryScreen({super.key, this.entry});

  @override
  State<AddEntryScreen> createState() => _AddEntryScreenState();
}

class _AddEntryScreenState extends State<AddEntryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _scrollController = ScrollController();
  
  // Text controllers
  final _uidController = TextEditingController();
  final _areaCodeController = TextEditingController();
  final _qrPlateController = TextEditingController();
  final _ownerNameHindiController = TextEditingController();
  final _ownerNameEnglishController = TextEditingController();
  final _mobileNumberController = TextEditingController();
  final _whatsappNumberController = TextEditingController();
  final _latitudeController = TextEditingController();
  final _longitudeController = TextEditingController();
  final _notesController = TextEditingController();

  PropertyStatus? _selectedPropertyStatus;
  List<File> _selectedImages = [];
  bool _isLoadingLocation = false;

  final LocationService _locationService = serviceLocator<LocationService>();
  final ImagePicker _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    if (widget.entry != null) {
      _populateFields();
    }
  }

  void _populateFields() {
    final entry = widget.entry!;
    _uidController.text = entry.uid;
    _areaCodeController.text = entry.areaCode;
    _qrPlateController.text = entry.qrPlateHouseNumber;
    _ownerNameHindiController.text = entry.ownerNameHindi;
    _ownerNameEnglishController.text = entry.ownerNameEnglish;
    _mobileNumberController.text = entry.mobileNumber;
    _whatsappNumberController.text = entry.whatsappNumber;
    _latitudeController.text = entry.latitude.toString();
    _longitudeController.text = entry.longitude.toString();
    _notesController.text = entry.notes ?? '';
    _selectedPropertyStatus = entry.propertyStatus;
  }

  @override
  void dispose() {
    _uidController.dispose();
    _areaCodeController.dispose();
    _qrPlateController.dispose();
    _ownerNameHindiController.dispose();
    _ownerNameEnglishController.dispose();
    _mobileNumberController.dispose();
    _whatsappNumberController.dispose();
    _latitudeController.dispose();
    _longitudeController.dispose();
    _notesController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      _isLoadingLocation = true;
    });

    try {
      final position = await _locationService.getCurrentLocation();
      if (position != null) {
        _latitudeController.text = position.latitude.toString();
        _longitudeController.text = position.longitude.toString();
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Location updated successfully'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to get current location'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isLoadingLocation = false;
      });
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final pickedFile = await _imagePicker.pickImage(source: source);
      if (pickedFile != null) {
        setState(() {
          _selectedImages.add(File(pickedFile.path));
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error picking image: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  void _showImageSourceDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Image Source'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Camera'),
              onTap: () {
                Navigator.of(context).pop();
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Gallery'),
              onTap: () {
                Navigator.of(context).pop();
                _pickImage(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final surveyProvider = Provider.of<SurveyProvider>(context, listen: false);

    if (authProvider.user == null) {
      DialogHelper.showErrorDialog(
        context,
        title: 'Error',
        message: 'User not authenticated',
      );
      return;
    }

    final entry = SurveyEntry(
      id: widget.entry?.id,
      uid: _uidController.text.trim(),
      areaCode: _areaCodeController.text.trim(),
      qrPlateHouseNumber: _qrPlateController.text.trim(),
      ownerNameHindi: _ownerNameHindiController.text.trim(),
      ownerNameEnglish: _ownerNameEnglishController.text.trim(),
      mobileNumber: _mobileNumberController.text.trim(),
      whatsappNumber: _whatsappNumberController.text.trim(),
      latitude: double.parse(_latitudeController.text),
      longitude: double.parse(_longitudeController.text),
      notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
      propertyStatus: _selectedPropertyStatus,
      images: _selectedImages.map((file) => file.path).toList(),
      userId: authProvider.user!.id,
      createdAt: widget.entry?.createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
    );

    bool success;
    if (widget.entry == null) {
      success = await surveyProvider.createEntry(entry);
    } else {
      success = await surveyProvider.updateEntry(entry);
    }

    if (success && mounted) {
      DialogHelper.showSuccessDialog(
        context,
        title: 'Success',
        message: widget.entry == null 
            ? 'Survey entry created successfully' 
            : 'Survey entry updated successfully',
        onOk: () => Navigator.of(context).pop(),
      );
    } else if (mounted) {
      DialogHelper.showErrorDialog(
        context,
        title: 'Error',
        message: surveyProvider.error ?? 'Failed to save entry',
      );
    }
  }

  void _onLocationTapped(double lat, double lng) {
    _latitudeController.text = lat.toString();
    _longitudeController.text = lng.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.entry == null ? 'Add Entry' : 'Edit Entry'),
        actions: [
          Consumer<SurveyProvider>(
            builder: (context, surveyProvider, child) {
              return TextButton(
                onPressed: surveyProvider.isLoading ? null : _submitForm,
                child: surveyProvider.isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('SAVE'),
              );
            },
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: Scrollbar(
          controller: _scrollController,
          child: SingleChildScrollView(
            controller: _scrollController,
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildBasicInfoSection(),
                const SizedBox(height: 24),
                _buildOwnerInfoSection(),
                const SizedBox(height: 24),
                _buildContactInfoSection(),
                const SizedBox(height: 24),
                _buildLocationSection(),
                const SizedBox(height: 24),
                _buildAdditionalInfoSection(),
                const SizedBox(height: 24),
                _buildImagesSection(),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBasicInfoSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Basic Information',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _uidController,
              decoration: const InputDecoration(
                labelText: 'UID *',
                border: OutlineInputBorder(),
              ),
              validator: (value) => Validators.validateRequired(value, 'UID'),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _areaCodeController,
              decoration: const InputDecoration(
                labelText: 'Area Code *',
                border: OutlineInputBorder(),
              ),
              validator: (value) => Validators.validateRequired(value, 'Area Code'),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _qrPlateController,
              decoration: const InputDecoration(
                labelText: 'QR Plate House Number *',
                border: OutlineInputBorder(),
              ),
              validator: (value) => Validators.validateRequired(value, 'QR Plate House Number'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOwnerInfoSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Owner Information',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _ownerNameHindiController,
              decoration: const InputDecoration(
                labelText: 'Owner Name (Hindi) *',
                border: OutlineInputBorder(),
              ),
              validator: (value) => Validators.validateRequired(value, 'Owner Name (Hindi)'),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _ownerNameEnglishController,
              decoration: const InputDecoration(
                labelText: 'Owner Name (English) *',
                border: OutlineInputBorder(),
              ),
              validator: (value) => Validators.validateRequired(value, 'Owner Name (English)'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactInfoSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Contact Information',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _mobileNumberController,
              decoration: const InputDecoration(
                labelText: 'Mobile Number *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.phone),
              ),
              keyboardType: TextInputType.phone,
              validator: Validators.validatePhoneNumber,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _whatsappNumberController,
              decoration: const InputDecoration(
                labelText: 'WhatsApp Number *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.chat),
              ),
              keyboardType: TextInputType.phone,
              validator: Validators.validatePhoneNumber,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Location Information',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _latitudeController,
                    decoration: const InputDecoration(
                      labelText: 'Latitude *',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    validator: Validators.validateLatitude,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _longitudeController,
                    decoration: const InputDecoration(
                      labelText: 'Longitude *',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    validator: Validators.validateLongitude,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isLoadingLocation ? null : _getCurrentLocation,
                icon: _isLoadingLocation
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.my_location),
                label: Text(_isLoadingLocation ? 'Getting Location...' : 'Get Current Location'),
              ),
            ),
            const SizedBox(height: 16),
            if (_latitudeController.text.isNotEmpty && _longitudeController.text.isNotEmpty)
              SizedBox(
                height: 200,
                child: LocationMapWidget(
                  latitude: double.tryParse(_latitudeController.text) ?? 0,
                  longitude: double.tryParse(_longitudeController.text) ?? 0,
                  onLocationTapped: _onLocationTapped,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdditionalInfoSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Additional Information',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: 'Notes',
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            Text(
              'Property Status',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            Column(
              children: PropertyStatus.values.map((status) {
                return RadioListTile<PropertyStatus>(
                  title: Text(_getPropertyStatusText(status)),
                  value: status,
                  groupValue: _selectedPropertyStatus,
                  onChanged: (value) {
                    setState(() {
                      _selectedPropertyStatus = value;
                    });
                  },
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImagesSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Images',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: _showImageSourceDialog,
                  icon: const Icon(Icons.add_a_photo),
                  label: const Text('Add Image'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_selectedImages.isEmpty)
              Container(
                height: 100,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Center(
                  child: Text(
                    'No images selected',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              )
            else
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemCount: _selectedImages.length,
                itemBuilder: (context, index) {
                  return Stack(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          image: DecorationImage(
                            image: FileImage(_selectedImages[index]),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Positioned(
                        top: 4,
                        right: 4,
                        child: GestureDetector(
                          onTap: () => _removeImage(index),
                          child: Container(
                            padding: const EdgeInsets.all(2),
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.close,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  String _getPropertyStatusText(PropertyStatus status) {
    switch (status) {
      case PropertyStatus.ownerChanged:
        return 'Is Owner Changed';
      case PropertyStatus.newProperty:
        return 'Is New Property';
      case PropertyStatus.extended:
        return 'Is Extended';
      case PropertyStatus.demolished:
        return 'Is Demolished';
    }
  }
}