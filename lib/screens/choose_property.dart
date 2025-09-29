import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

import '../models/property.dart';

class ChoosePropertyScreen extends StatefulWidget {
  const ChoosePropertyScreen({super.key});

  @override
  State<ChoosePropertyScreen> createState() => _ChoosePropertyScreenState();
}

class _ChoosePropertyScreenState extends State<ChoosePropertyScreen> {
  List<Property> allProperties = [];
  List<Property> filteredProperties = [];
  bool isLoading = true;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadProperties();
  }

  Future<void> _loadProperties() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/properties.json');

      if (await file.exists()) {
        final content = await file.readAsString();
        setState(() {
          allProperties = Property.parsePropertiesJson(content);
          filteredProperties = allProperties;
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
      }
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading properties: ${e.toString()}')),
      );
    }
  }

  void _filterProperties(String query) {
    if (query.isEmpty) {
      setState(() => filteredProperties = allProperties);
      return;
    }

    final lowercaseQuery = query.toLowerCase();
    setState(() {
      filteredProperties = allProperties.where((property) {
        return property.uid.toLowerCase().contains(lowercaseQuery) ||
            property.ownerName.toLowerCase().contains(lowercaseQuery) ||
            property.fatherName.toLowerCase().contains(lowercaseQuery) ||
            property.mobileNo.toLowerCase().contains(lowercaseQuery);
      }).toList();
    });
  }

  void _proceedToSurvey([Property? selectedProperty]) {
    Navigator.pushNamed(
      context,
      '/add-survey',
      arguments: selectedProperty,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Choose Property'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: 'Search properties...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: _filterProperties,
            ),
          ),
          Expanded(
            child: filteredProperties.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'No properties found',
                          style: TextStyle(fontSize: 18),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => _proceedToSurvey(),
                          child: const Text('Skip Property Selection'),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: filteredProperties.length,
                    itemBuilder: (context, index) {
                      final property = filteredProperties[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        child: ListTile(
                          title: Text(property.ownerName),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('UID: ${property.uid}'),
                              if (property.fatherName.isNotEmpty)
                                Text("Father's Name: ${property.fatherName}"),
                              Text('Mobile: ${property.mobileNo}'),
                            ],
                          ),
                          onTap: () => _proceedToSurvey(property),
                        ),
                      );
                    },
                  ),
          ),
          if (filteredProperties.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                onPressed: () => _proceedToSurvey(),
                child: const Text('Skip Property Selection'),
              ),
            ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
