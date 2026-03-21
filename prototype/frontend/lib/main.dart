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

// ViewModels
import 'viewmodels/users/login_viewmodel.dart';
import 'viewmodels/users/register_viewmodel.dart';
import 'viewmodels/users/profile_viewmodel.dart';
import 'viewmodels/users/forgot_password_viewmodel.dart';

// Views
import 'views/auth/login_screen.dart';
import 'views/auth/register_screen.dart';
import 'views/auth/forgot_password_screen.dart';
import 'views/dashboard/dashboard_screen.dart';

void main() {
  usePathUrlStrategy();
  // Initialize the base API client
  final apiClient = ApiClient();

  // Initialize Repositories
  final authRepository = AuthRepository(apiClient);
  final userRepository = UserRepository(apiClient);
  final mediaRepository = MediaRepository(apiClient);

  runApp(
    MultiProvider(
      providers: [
        // Inject ViewModels
        ChangeNotifierProvider(create: (_) => LoginViewModel(authRepository)),
        ChangeNotifierProvider(
          create: (_) => RegisterViewModel(authRepository),
        ),
        ChangeNotifierProvider(
          create: (_) => ForgotPasswordViewModel(authRepository),
        ),
        ChangeNotifierProvider(create: (_) => ProfileViewModel(userRepository)),
        ChangeNotifierProvider(
          create: (_) => VerificationViewModel(authRepository),
        ),
        ChangeNotifierProvider(
          create: (_) => DashboardViewModel(authRepository),
        ),
        ChangeNotifierProvider(create: (_) => MediaViewModel(mediaRepository)),
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
        primarySwatch: Colors.blue,
        useMaterial3: true,
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(120, 48),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
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
            return MaterialPageRoute(
              builder: (_) => const ForgotPasswordScreen(),
            );
          case '/dashboard':
            return MaterialPageRoute(builder: (_) => const DashboardScreen());
          default:
            return MaterialPageRoute(builder: (_) => const LoginScreen());
        }
      },
    );
  }
}
