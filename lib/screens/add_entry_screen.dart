import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:provider/provider.dart';

import '../models/survey_form.dart';
import '../providers/survey_provider.dart';
import '../utils/validators.dart';

class AddSurveyScreen extends StatefulWidget {
  const AddSurveyScreen({super.key});

  @override
  State<AddSurveyScreen> createState() => _AddSurveyScreenState();
}

class _AddSurveyScreenState extends State<AddSurveyScreen> {
  final _formKey = GlobalKey<FormState>();
  final _form = SurveyForm();
  late GoogleMapController _mapController;
  Set<Marker> _markers = {};
  bool _isMapReady = false;

  // Default location (can be set to a default city center)
  final LatLng _defaultLocation = const LatLng(28.6139, 77.2090); // Delhi
  LatLng? _selectedLocation;

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
      final success = await surveyProvider.createSurvey(context, _form);
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Survey created successfully')),
        );
        Navigator.of(context).pop();
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(surveyProvider.error ?? 'Failed to create survey'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to create survey'),
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
        title: const Text('Add Survey'),
      ),
      body: Consumer<SurveyProvider>(
        builder: (context, surveyProvider, child) {
          return Stack(
            children: [
              Form(
                key: _formKey,
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Property UID',
                        prefixIcon: Icon(Icons.home),
                      ),
                      validator: (value) =>
                          Validators.validatePropertyUid(value),
                      onSaved: (value) =>
                          _form.propertyUid = value?.trim() ?? '',
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'QR ID',
                        prefixIcon: Icon(Icons.qr_code),
                      ),
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
                      validator: (value) =>
                          Validators.validateRequired(value, 'Owner Name'),
                      onSaved: (value) => _form.ownerName = value?.trim() ?? '',
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Father/Spouse Name',
                        prefixIcon: Icon(Icons.person_outline),
                      ),
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
                      keyboardType: TextInputType.phone,
                      validator: Validators.validateMobile,
                      onSaved: (value) =>
                          _form.contactNumber = value?.trim() ?? '',
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'WhatsApp Number',
                        prefixIcon: Brand(Brands.whatsapp),
                      ),
                      keyboardType: TextInputType.phone,
                      validator: Validators.validateMobile,
                      onSaved: (value) =>
                          _form.whatsappNumber = value?.trim() ?? '',
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            decoration: const InputDecoration(
                              labelText: 'Latitude',
                              prefixIcon: Icon(Icons.location_on),
                            ),
                            keyboardType: TextInputType.number,
                            validator: Validators.validateLatitude,
                            controller: TextEditingController(
                              text: _form.latitude.toString(),
                            ),
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
                            decoration: const InputDecoration(
                              labelText: 'Longitude',
                              prefixIcon: Icon(Icons.location_on),
                            ),
                            keyboardType: TextInputType.number,
                            validator: Validators.validateLongitude,
                            controller: TextEditingController(
                              text: _form.longitude.toString(),
                            ),
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
                              _updateMarker();
                            });
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: surveyProvider.isLoading ? null : _submitForm,
                      child: Text(
                        surveyProvider.isLoading
                            ? 'Creating...'
                            : 'Create Survey',
                      ),
                    ),
                  ],
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
