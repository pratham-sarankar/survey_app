import 'package:flutter/material.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:survey_app/models/survey.dart';
import 'package:survey_app/services/photo_service.dart';

import '../config/service_locator.dart';
import '../providers/survey_provider.dart';
import '../utils/dialog_helper.dart';

class SurveyCard extends StatefulWidget {
  const SurveyCard({super.key, required this.survey});
  final Survey survey;
  @override
  State<SurveyCard> createState() => _SurveyCardState();
}

class _SurveyCardState extends State<SurveyCard> {
  @override
  Widget build(BuildContext context) {
    final PhotoService photoService = serviceLocator();
    return FutureBuilder(
        future: photoService.getLocalPhotos(widget.survey.id.toString()),
        builder: (context, snapshot) {
          final isDraft = snapshot.hasData && snapshot.data!.isNotEmpty;
          return Column(
            children: [
              Card(
                margin: const EdgeInsets.only(bottom: 16),
                elevation: 2,
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  onTap: () {
                    // TODO: Implement survey details view
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        color: Theme.of(context).primaryColor.withOpacity(0.1),
                        child: Row(
                          children: [
                            const Icon(Icons.home_work_outlined),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Property ID: ${widget.survey.propertyUid}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Theme.of(context).primaryColor,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      'Ward ${widget.survey.wardNumber}',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () => Navigator.of(context).pushNamed(
                                '/add-survey',
                                arguments: widget.survey,
                              ),
                              tooltip: 'Edit Survey',
                            ),
                            IconButton(
                              icon: const Icon(Icons.photo_library_outlined),
                              onPressed: () => Navigator.pushNamed(
                                context,
                                '/survey-photos',
                                arguments: widget.survey.id.toString(),
                              ),
                              tooltip: 'Survey Photos',
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline),
                              color: Colors.red,
                              onPressed: () => _deleteSurvey(widget.survey.id),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.person, size: 20),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    widget.survey.ownerName,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Expanded(
                                  child: Row(
                                    children: [
                                      const Icon(Icons.phone, size: 20),
                                      const SizedBox(width: 8),
                                      Text(
                                        widget.survey.contactNumber,
                                        style: TextStyle(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .secondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  child: Row(
                                    children: [
                                      Brand(Brands.whatsapp),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          widget.survey.whatsappNumber,
                                          style: TextStyle(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .secondary,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const Divider(height: 24),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Created: ${DateFormat('MMM d, yyyy').format(widget.survey.createdAt!)}',
                                  style: TextStyle(
                                    color:
                                        Theme.of(context).colorScheme.secondary,
                                    fontSize: 12,
                                  ),
                                ),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.location_on,
                                      size: 16,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .secondary,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${widget.survey.latitude.toStringAsFixed(6)}, ${widget.survey.longitude.toStringAsFixed(6)}',
                                      style: TextStyle(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .secondary,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 15, bottom: 15),
                        child: Text(
                          isDraft ? 'Status: Draft' : 'Status: Submitted',
                          style: TextStyle(
                            color: isDraft ? Colors.orange : Colors.green,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        });
  }

  Future<void> _deleteSurvey(int surveyId) async {
    final confirmed = await DialogHelper.showConfirmationDialog(
      context,
      title: 'Delete Survey',
      message: 'Are you sure you want to delete this survey?',
      confirmText: 'Delete',
      cancelText: 'Cancel',
    );

    if (!confirmed || !mounted) return;

    final surveyProvider = Provider.of<SurveyProvider>(context, listen: false);
    final success = await surveyProvider.deleteSurvey(context, surveyId);

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Survey deleted successfully')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(surveyProvider.error ?? 'Failed to delete survey'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
