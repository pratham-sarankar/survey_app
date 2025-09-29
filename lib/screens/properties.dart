import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

import '../models/property.dart';

class PropertiesScreen extends StatefulWidget {
  const PropertiesScreen({super.key});

  @override
  State<PropertiesScreen> createState() => _PropertiesScreenState();
}

class _PropertiesScreenState extends State<PropertiesScreen> {
  List<Property> properties = [];
  bool isLoading = false;

  Future<void> _pickAndSaveFile() async {
    try {
      setState(() => isLoading = true);

      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (result != null) {
        final file = File(result.files.single.path!);
        final content = await file.readAsString();

        // Save file locally
        final directory = await getApplicationDocumentsDirectory();
        final localFile = File('${directory.path}/properties.json');
        await localFile.writeAsString(content);

        // Parse and update properties
        setState(() {
          properties = Property.parsePropertiesJson(content);
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
      }
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  Future<void> _loadLocalFile() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/properties.json');

      if (await file.exists()) {
        final content = await file.readAsString();
        setState(() {
          properties = Property.parsePropertiesJson(content);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Error loading saved properties: ${e.toString()}')),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _loadLocalFile();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Properties"),
        actions: [
          IconButton(
            icon: const Icon(Icons.file_download),
            onPressed: _pickAndSaveFile,
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : properties.isEmpty
              ? const Center(
                  child: Text(
                    'No properties loaded. Tap the download icon to load properties.',
                    textAlign: TextAlign.center,
                  ),
                )
              : ListView.builder(
                  itemCount: properties.length,
                  itemBuilder: (context, index) {
                    final property = properties[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      child: ListTile(
                        title: Text(property.ownerName),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('UID: ${property.uid}'),
                            if (property.fatherName.isNotEmpty)
                              Text('Father\'s Name: ${property.fatherName}'),
                            Text('Mobile: ${property.mobileNo}'),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
