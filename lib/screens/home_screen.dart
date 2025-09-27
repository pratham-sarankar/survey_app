import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/survey_provider.dart';
import '../widgets/app_drawer.dart';
import 'entries_list_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeProviders();
    });
  }

  void _initializeProviders() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final surveyProvider = Provider.of<SurveyProvider>(context, listen: false);
    
    surveyProvider.initialize(authProvider.user?.token);
    
    // Load appropriate entries based on user role
    if (authProvider.isAdmin) {
      surveyProvider.loadAllEntries();
    } else if (authProvider.user != null) {
      surveyProvider.loadMyEntries(authProvider.user!.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Survey App'),
        centerTitle: true,
      ),
      drawer: const AppDrawer(),
      body: const EntriesListScreen(),
    );
  }
}