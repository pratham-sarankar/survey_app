import 'package:get_it/get_it.dart';

import '../services/auth_service.dart';
import '../services/location_service.dart';
import '../services/survey_service.dart';

final GetIt serviceLocator = GetIt.instance;

Future<void> setupServiceLocator() async {
  // Register services
  serviceLocator.registerLazySingleton<AuthService>(() => AuthService());
  serviceLocator
      .registerLazySingleton<LocationService>(() => LocationService());

  // Survey service depends on AuthService for tokens
  serviceLocator.registerLazySingleton<SurveyService>(() {
    final authService = serviceLocator<AuthService>();
    return SurveyService(authService);
  });
}
