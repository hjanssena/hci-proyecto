import 'package:bebeia_front/models/users/user.dart';
import 'package:bebeia_front/viewmodels/dashboard_viewmodel.dart';
import 'package:bebeia_front/viewmodels/users/login_viewmodel.dart';
import 'package:bebeia_front/viewmodels/users/profile_viewmodel.dart';
import 'package:bebeia_front/views/dashboard/profile/profile_screen.dart';
import 'package:bebeia_front/views/dashboard/events/event_list_screen.dart';
import 'package:bebeia_front/views/dashboard/categories/category_list_screen.dart';
import 'package:bebeia_front/views/dashboard/enrollments/enrollment_list_screen.dart';
import 'package:bebeia_front/views/dashboard/payments/payment_list_screen.dart';

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
                        color: Colors.white,
                      ),
                    ),
                  ),
                  destinations: const [
                    NavigationRailDestination(
                      icon: Icon(Icons.event),
                      label: Text('Eventos'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.category),
                      label: Text('Categorías'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.assignment),
                      label: Text('Inscripciones'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.payment),
                      label: Text('Pagos'),
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
                          icon: const Icon(Icons.logout, color: Colors.white70),
                          onPressed: () => _handleLogout(context),
                          tooltip: 'Cerrar sesión',
                        ),
                      ),
                    ),
                  ),
                ),
                const VerticalDivider(thickness: 1, width: 1),
                Expanded(
                  child: _buildContent(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    switch (_selectedIndex) {
      case 0:
        return const EventListScreen();
      case 1:
        return const CategoryListScreen();
      case 2:
        return const EnrollmentListScreen();
      case 3:
        return const PaymentListScreen();
      case 4:
        return const ProfileScreen();
      default:
        return const EventListScreen();
    }
  }

  void _handleLogout(BuildContext context) {
    Navigator.of(context).pushReplacementNamed('/login');
  }
}
