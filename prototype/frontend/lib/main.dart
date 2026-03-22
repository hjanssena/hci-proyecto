import 'package:bebeia_front/repositories/media_repository.dart';
import 'package:bebeia_front/viewmodels/dashboard_viewmodel.dart';
import 'package:bebeia_front/viewmodels/media_viewmodel.dart';
import 'package:bebeia_front/viewmodels/users/verification_viewmodel.dart';
import 'package:bebeia_front/views/auth/verify_email.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_web_plugins/url_strategy.dart';

// Core and Repositories
import 'core/api_client.dart';
import 'repositories/users/auth_repository.dart';
import 'repositories/users/user_repository.dart';
import 'repositories/events/event_repository.dart';
import 'repositories/events/category_repository.dart';
import 'repositories/events/enrollment_repository.dart';
import 'repositories/events/payment_repository.dart';

import 'repositories/events/professor_repository.dart';

// ViewModels
import 'viewmodels/users/login_viewmodel.dart';
import 'viewmodels/users/register_viewmodel.dart';
import 'viewmodels/users/profile_viewmodel.dart';
import 'viewmodels/users/forgot_password_viewmodel.dart';
import 'viewmodels/events/event_list_viewmodel.dart';
import 'viewmodels/events/event_form_viewmodel.dart';
import 'viewmodels/events/category_viewmodel.dart';
import 'viewmodels/events/enrollment_viewmodel.dart';
import 'viewmodels/events/payment_viewmodel.dart';


// Views
import 'views/auth/login_screen.dart';
import 'views/auth/register_screen.dart';
import 'views/auth/forgot_password_screen.dart';
import 'views/dashboard/dashboard_screen.dart';

void main() {
  usePathUrlStrategy();
  final apiClient = ApiClient();

  // Repositories
  final authRepository = AuthRepository(apiClient);
  final userRepository = UserRepository(apiClient);
  final mediaRepository = MediaRepository(apiClient);
  final eventRepository = EventRepository(apiClient);
  final categoryRepository = CategoryRepository(apiClient);
  final enrollmentRepository = EnrollmentRepository(apiClient);
  final paymentRepository = PaymentRepository(apiClient);
  final professorRepository = ProfessorRepository(apiClient);

  runApp(
    MultiProvider(
      providers: [
        // User ViewModels (existing)
        ChangeNotifierProvider(create: (_) => LoginViewModel(authRepository)),
        ChangeNotifierProvider(create: (_) => RegisterViewModel(authRepository)),
        ChangeNotifierProvider(create: (_) => ForgotPasswordViewModel(authRepository)),
        ChangeNotifierProvider(create: (_) => ProfileViewModel(userRepository)),
        ChangeNotifierProvider(create: (_) => VerificationViewModel(authRepository)),
        ChangeNotifierProvider(create: (_) => DashboardViewModel(authRepository)),
        ChangeNotifierProvider(create: (_) => MediaViewModel(mediaRepository)),
        // Event Module ViewModels
        ChangeNotifierProvider(create: (_) => EventListViewModel(eventRepository)),
        ChangeNotifierProvider(create: (_) => EventFormViewModel(eventRepository, categoryRepository, professorRepository)),
        ChangeNotifierProvider(create: (_) => CategoryViewModel(categoryRepository)),
        ChangeNotifierProvider(create: (_) => EnrollmentViewModel(enrollmentRepository, eventRepository)),
        ChangeNotifierProvider(create: (_) => PaymentViewModel(paymentRepository)),

      ],
      child: const FCAContinua(),
    ),
  );
}

class FCAContinua extends StatelessWidget {
  const FCAContinua({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FCA Educación Continua',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF002E5F),
          primary: const Color(0xFF002E5F),
          secondary: const Color(0xFFC79316),
        ),
        useMaterial3: true,
        navigationRailTheme: NavigationRailThemeData(
          backgroundColor: const Color(0xFF002E5F),
          selectedIconTheme: const IconThemeData(color: Color(0xFFC79316)),
          unselectedIconTheme: const IconThemeData(color: Colors.white70),
          selectedLabelTextStyle: const TextStyle(color: Color(0xFFC79316), fontWeight: FontWeight.bold),
          unselectedLabelTextStyle: const TextStyle(color: Colors.white70),
          indicatorColor: const Color(0xFFC79316).withAlpha(51),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF002E5F),
            foregroundColor: Colors.white,
            minimumSize: const Size(120, 48),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: const Color(0xFFC79316),
            side: const BorderSide(color: Color(0xFFC79316), width: 1.5),
            minimumSize: const Size(120, 48),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF002E5F),
          foregroundColor: Colors.white,
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Color(0xFFC79316),
          foregroundColor: Colors.white,
        ),
      ),
      onGenerateRoute: (settings) {
        final Uri uri = Uri.parse(settings.name ?? '');

        if (uri.path == '/verify-email') {
          return MaterialPageRoute(
            builder: (context) => const EmailVerificationScreen(),
            settings: settings,
          );
        }
        switch (uri.path) {
          case '/register':
            return MaterialPageRoute(builder: (_) => const RegisterScreen());
          case 'forgot-password':
            return MaterialPageRoute(builder: (_) => const ForgotPasswordScreen());
          case '/dashboard':
            return MaterialPageRoute(builder: (_) => const DashboardScreen());
          default:
            return MaterialPageRoute(builder: (_) => const LoginScreen());
        }
      },
    );
  }
}
