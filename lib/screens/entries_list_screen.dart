import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/survey_provider.dart';
import '../models/survey_entry.dart';
import '../widgets/entry_card.dart';

class EntriesListScreen extends StatelessWidget {
  const EntriesListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<AuthProvider, SurveyProvider>(
      builder: (context, authProvider, surveyProvider, child) {
        if (surveyProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (surveyProvider.error != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error,
                  size: 64,
                  color: Colors.red[300],
                ),
                const SizedBox(height: 16),
                Text(
                  'Error loading entries',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                Text(
                  surveyProvider.error!,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    surveyProvider.clearError();
                    if (authProvider.isAdmin) {
                      surveyProvider.loadAllEntries();
                    } else if (authProvider.user != null) {
                      surveyProvider.loadMyEntries(authProvider.user!.id);
                    }
                  },
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        if (surveyProvider.entries.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.assignment_outlined,
                  size: 64,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  'No entries found',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                Text(
                  authProvider.isAdmin
                      ? 'No survey entries have been created yet.'
                      : 'You haven\'t created any survey entries yet.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.of(context).pushNamed('/add-entry');
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Add First Entry'),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            if (authProvider.isAdmin) {
              await surveyProvider.loadAllEntries();
            } else if (authProvider.user != null) {
              await surveyProvider.loadMyEntries(authProvider.user!.id);
            }
          },
          child: ListView.builder(
            padding: const EdgeInsets.all(8.0),
            itemCount: surveyProvider.entries.length,
            itemBuilder: (context, index) {
              final entry = surveyProvider.entries[index];
              return EntryCard(entry: entry);
            },
          ),
        );
      },
    );
  }
}