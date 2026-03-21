import 'package:bebeia_front/models/users/user.dart';
import 'package:bebeia_front/viewmodels/dashboard_viewmodel.dart';
import 'package:bebeia_front/viewmodels/users/login_viewmodel.dart';
import 'package:bebeia_front/viewmodels/users/profile_viewmodel.dart';
import 'package:bebeia_front/views/dashboard/profile/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final user = context.select<LoginViewModel, User?>((vm) => vm.currentUser);
    final viewModel = context.watch<DashboardViewModel>();
    return Scaffold(
      body: Column(
        children: [
          if (user != null && !user.hasVerifiedEmail)
            Container(
              width: double.infinity,
              color: Colors.orange.shade100,
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              child: Row(
                children: [
                  const Icon(Icons.mail_outline, size: 20),
                  const SizedBox(width: 8),
                  const Text(
                    'Tu correo no ha sido verificado. Revisa tu bandeja de entrada.',
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: viewModel.state == ProfileState.loading
                        ? null
                        : () async {
                            await viewModel.resendVerification();

                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    viewModel.errorMessage ?? 'Enlace enviado',
                                  ),
                                  backgroundColor: Colors.green,
                                ),
                              );
                            }
                          },
                    child: viewModel.state == ProfileState.loading
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Reenviar enlace'),
                  ),
                ],
              ),
            ),
          Expanded(
            child: Row(
              children: [
                // Web Sidebar
                NavigationRail(
                  extended: true,
                  selectedIndex: _selectedIndex,
                  onDestinationSelected: (int index) {
                    setState(() => _selectedIndex = index);
                  },
                  leading: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      'Hola, ${user?.name ?? "Usuario"}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  destinations: const [
                    NavigationRailDestination(
                      icon: Icon(Icons.dashboard),
                      label: Text('Dashboard'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.person),
                      label: Text('Mi cuenta'),
                    ),
                  ],
                  trailing: Expanded(
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 20.0),
                        child: IconButton(
                          icon: const Icon(Icons.logout, color: Colors.red),
                          onPressed: () => _handleLogout(context),
                          tooltip: 'Cerrar sesión',
                        ),
                      ),
                    ),
                  ),
                ),
                const VerticalDivider(thickness: 1, width: 1),
                // Main Content Area
                Expanded(
                  child: _selectedIndex == 0
                      ? const Placeholder()
                      : const ProfileScreen(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _handleLogout(BuildContext context) {
    // Call the logout/blacklist logic here
    Navigator.of(context).pushReplacementNamed('/login');
  }
}
