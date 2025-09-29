import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:provider/provider.dart';

import '../models/property.dart';
import '../models/survey.dart';
import '../models/survey_form.dart';
import '../providers/survey_provider.dart';
import '../screens/survey_photos_screen.dart';
import '../utils/validators.dart';

class AddSurveyScreen extends StatefulWidget {
  final Survey? survey;
  final Property? property;

  const AddSurveyScreen({
    super.key,
    this.survey,
    this.property,
  });

  @override
  State<AddSurveyScreen> createState() => _AddSurveyScreenState();
}

class _AddSurveyScreenState extends State<AddSurveyScreen> {
  final _formKey = GlobalKey<FormState>();
  late final SurveyForm _form;
  late GoogleMapController _mapController;
  late TextEditingController latController;
  late TextEditingController lngController;
  Set<Marker> _markers = {};
  bool _isMapReady = false;

  final LatLng _defaultLocation = const LatLng(28.6139, 77.2090);
  LatLng? _selectedLocation;
  bool _whatsappSameAsContact = false;

  @override
  void initState() {
    super.initState();

    // Initialize form with existing survey data or property data
    _form = SurveyForm(
      propertyUid: widget.survey?.propertyUid ?? widget.property?.uid ?? '',
      qrId: widget.survey?.qrId ?? '',
      ownerName: widget.survey?.ownerName ?? widget.property?.ownerName ?? '',
      fatherOrSpouseName: widget.survey?.fatherOrSpouseName ??
          widget.property?.fatherName ??
          '',
      wardNumber: widget.survey?.wardNumber ?? '',
      contactNumber:
          widget.survey?.contactNumber ?? widget.property?.mobileNo ?? '',
      whatsappNumber: widget.survey?.whatsappNumber ?? '',
      latitude: widget.survey?.latitude ?? 0.0,
      longitude: widget.survey?.longitude ?? 0.0,
    );
    latController = TextEditingController(
      text: _form.latitude.toString(),
    );
    lngController = TextEditingController(
      text: _form.longitude.toString(),
    );

    if (widget.survey != null) {
      _selectedLocation =
          LatLng(widget.survey!.latitude, widget.survey!.longitude);
    }
  }

  @override
  void dispose() {
    if (_isMapReady) {
      _mapController.dispose();
    }
    super.dispose();
  }

  Future<void> _getCurrentLocation() async {
    try {
      final permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        final requested = await Geolocator.requestPermission();
        if (requested == LocationPermission.denied && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Location permission denied')),
          );
          return;
        }
      }

      final position = await Geolocator.getCurrentPosition();
      setState(() {
        _form.latitude = position.latitude;
        _form.longitude = position.longitude;
        _selectedLocation = LatLng(position.latitude, position.longitude);
        latController.text = position.latitude.toString();
        lngController.text = position.longitude.toString();
        _updateMarker();
      });

      if (_isMapReady) {
        _mapController.animateCamera(
          CameraUpdate.newLatLngZoom(_selectedLocation!, 15),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to get current location')),
      );
    }
  }

  void _updateMarker() {
    if (_selectedLocation != null) {
      setState(() {
        _markers = {
          Marker(
            markerId: const MarkerId('selectedLocation'),
            position: _selectedLocation!,
            draggable: true,
            onDragEnd: (newPosition) {
              setState(() {
                _selectedLocation = newPosition;
                _form.latitude = newPosition.latitude;
                _form.longitude = newPosition.longitude;
              });
            },
          ),
        };
      });
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    _formKey.currentState!.save();

    final surveyProvider = Provider.of<SurveyProvider>(context, listen: false);

    try {
      bool success;
      String? surveyId;

      if (widget.survey != null) {
        // Update existing survey
        success = await surveyProvider.updateSurvey(
          context,
          widget.survey!.id,
          _form,
        );
        surveyId = widget.survey!.id.toString();
      } else {
        // Create new survey
        surveyId = await surveyProvider.createSurvey(context, _form);
        success = surveyId != null;
      }

      if (success && mounted && surveyId != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.survey != null
                ? 'Survey updated successfully'
                : 'Survey created successfully'),
          ),
        );

        // Navigate to photos screen
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => SurveyPhotosScreen(surveyId: surveyId!),
          ),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(surveyProvider.error ?? 'Operation failed'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Failed to ${widget.survey != null ? 'update' : 'create'} survey'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.survey != null ? 'Edit Survey' : 'Add Survey'),
      ),
      body: Consumer<SurveyProvider>(
        builder: (context, surveyProvider, child) {
          return Stack(
            children: [
              Form(
                key: _formKey,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Property UID',
                          prefixIcon: Icon(Icons.home),
                        ),
                        initialValue: _form.propertyUid,
                        validator: Validators.validatePropertyUid,
                        onSaved: (value) =>
                            _form.propertyUid = value?.trim() ?? '',
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'QR ID',
                          prefixIcon: Icon(Icons.qr_code),
                        ),
                        initialValue: _form.qrId,
                        validator: (value) =>
                            Validators.validateRequired(value, 'QR ID'),
                        onSaved: (value) => _form.qrId = value?.trim() ?? '',
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Owner Name',
                          prefixIcon: Icon(Icons.person),
                        ),
                        initialValue: _form.ownerName,
                        validator: (value) =>
                            Validators.validateRequired(value, 'Owner Name'),
                        onSaved: (value) =>
                            _form.ownerName = value?.trim() ?? '',
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Father/Spouse Name',
                          prefixIcon: Icon(Icons.person_outline),
                        ),
                        initialValue: _form.fatherOrSpouseName,
                        validator: (value) => Validators.validateRequired(
                            value, 'Father/Spouse Name'),
                        onSaved: (value) =>
                            _form.fatherOrSpouseName = value?.trim() ?? '',
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Ward Number',
                          prefixIcon: Icon(Icons.location_city),
                        ),
                        initialValue: _form.wardNumber,
                        validator: (value) =>
                            Validators.validateRequired(value, 'Ward Number'),
                        onSaved: (value) =>
                            _form.wardNumber = value?.trim() ?? '',
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Contact Number',
                          prefixIcon: Icon(Icons.phone),
                        ),
                        initialValue: _form.contactNumber,
                        keyboardType: TextInputType.phone,
                        validator: Validators.validateMobile,
                        onChanged: (value) {
                          setState(() {
                            _form.contactNumber = value.trim();
                          });
                        },
                        onSaved: (value) =>
                            _form.contactNumber = value?.trim() ?? '',
                      ),
                      const SizedBox(height: 16),
                      if (_whatsappSameAsContact)
                        TextFormField(
                          decoration: InputDecoration(
                            labelText: 'WhatsApp Number',
                            prefixIcon: Brand(Brands.whatsapp),
                          ),
                          enabled: false,
                          controller:
                              TextEditingController(text: _form.contactNumber),
                        )
                      else
                        TextFormField(
                          decoration: InputDecoration(
                            labelText: 'WhatsApp Number',
                            prefixIcon: Brand(Brands.whatsapp),
                          ),
                          enabled: !_whatsappSameAsContact,
                          initialValue: _form.whatsappNumber,
                          keyboardType: TextInputType.phone,
                          validator: Validators.validateMobile,
                          onSaved: (value) =>
                              _form.whatsappNumber = value?.trim() ?? '',
                        ),
                      Row(
                        children: [
                          Checkbox(
                            value: _whatsappSameAsContact,
                            onChanged: (value) {
                              setState(() {
                                _whatsappSameAsContact = value ?? false;
                                if (_whatsappSameAsContact) {
                                  _form.whatsappNumber = _form.contactNumber;
                                } else {
                                  _form.whatsappNumber = '';
                                }
                              });
                            },
                          ),
                          const SizedBox(width: 8),
                          const Text('WhatsApp number same as contact number'),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: latController,
                              decoration: const InputDecoration(
                                labelText: 'Latitude',
                                prefixIcon: Icon(Icons.location_on),
                              ),
                              keyboardType: TextInputType.number,
                              validator: Validators.validateLatitude,
                              onChanged: (value) {
                                final lat = double.tryParse(value);
                                if (lat != null) {
                                  setState(() {
                                    _form.latitude = lat;
                                    _selectedLocation =
                                        LatLng(lat, _form.longitude);
                                    _updateMarker();
                                  });
                                }
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              controller: lngController,
                              decoration: const InputDecoration(
                                labelText: 'Longitude',
                                prefixIcon: Icon(Icons.location_on),
                              ),
                              keyboardType: TextInputType.number,
                              validator: Validators.validateLongitude,
                              onChanged: (value) {
                                final lng = double.tryParse(value);
                                if (lng != null) {
                                  setState(() {
                                    _form.longitude = lng;
                                    _selectedLocation =
                                        LatLng(_form.latitude, lng);
                                    _updateMarker();
                                  });
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton.icon(
                        onPressed: _getCurrentLocation,
                        icon: const Icon(Icons.my_location),
                        label: const Text('Get Current Location'),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        height: 300,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: GoogleMap(
                            initialCameraPosition: CameraPosition(
                              target: _selectedLocation ?? _defaultLocation,
                              zoom: 15,
                            ),
                            markers: _markers,
                            onMapCreated: (controller) {
                              _mapController = controller;
                              _isMapReady = true;
                              if (_selectedLocation == null) {
                                _selectedLocation = _defaultLocation;
                                _updateMarker();
                              }
                            },
                            onTap: (position) {
                              setState(() {
                                _selectedLocation = position;
                                _form.latitude = position.latitude;
                                _form.longitude = position.longitude;
                                latController.text =
                                    position.latitude.toString();
                                lngController.text =
                                    position.longitude.toString();
                                _updateMarker();
                              });
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed:
                            surveyProvider.isLoading ? null : _submitForm,
                        child: Text(
                          surveyProvider.isLoading
                              ? 'Saving...'
                              : (widget.survey != null
                                  ? 'Update Survey'
                                  : 'Create Survey'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (surveyProvider.isLoading)
                const Positioned.fill(
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
