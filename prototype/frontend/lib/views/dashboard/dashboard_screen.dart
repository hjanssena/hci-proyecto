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

  static const _navItems = [
    _NavItem(icon: Icons.event, label: 'Eventos'),
    _NavItem(icon: Icons.category, label: 'Categorías'),
    _NavItem(icon: Icons.assignment, label: 'Inscripciones'),
    _NavItem(icon: Icons.payment, label: 'Pagos'),
    _NavItem(icon: Icons.person, label: 'Mi cuenta'),
  ];

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
                Container(
                  width: 220,
                  color: const Color(0xFF002E5F),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Text(
                          'Hola, ${user?.name ?? "Usuario"}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const Divider(color: Colors.white24, height: 1),
                      const SizedBox(height: 8),
                      ...List.generate(_navItems.length, (i) {
                        return _SidebarItem(
                          icon: _navItems[i].icon,
                          label: _navItems[i].label,
                          selected: _selectedIndex == i,
                          onTap: () => setState(() => _selectedIndex = i),
                        );
                      }),
                      const Spacer(),
                      _SidebarItem(
                        icon: Icons.logout,
                        label: 'Cerrar sesión',
                        selected: false,
                        onTap: () => _handleLogout(context),
                        isLogout: true,
                      ),
                      const SizedBox(height: 12),
                    ],
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

class _NavItem {
  final IconData icon;
  final String label;
  const _NavItem({required this.icon, required this.label});
}

class _SidebarItem extends StatefulWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final bool isLogout;

  const _SidebarItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
    this.isLogout = false,
  });

  @override
  State<_SidebarItem> createState() => _SidebarItemState();
}

class _SidebarItemState extends State<_SidebarItem> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    final isHighlighted = widget.selected || _hovering;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: widget.selected
                ? const Color(0xFFC79316).withAlpha(40)
                : _hovering
                    ? Colors.white.withAlpha(25)
                    : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: widget.selected
                ? Border.all(color: const Color(0xFFC79316).withAlpha(80))
                : null,
          ),
          child: Row(
            children: [
              AnimatedScale(
                scale: _hovering ? 1.15 : 1.0,
                duration: const Duration(milliseconds: 200),
                child: Icon(
                  widget.icon,
                  size: 22,
                  color: widget.isLogout
                      ? (_hovering ? Colors.red.shade300 : Colors.white70)
                      : widget.selected
                          ? const Color(0xFFC79316)
                          : isHighlighted
                              ? Colors.white
                              : Colors.white70,
                ),
              ),
              const SizedBox(width: 14),
              Text(
                widget.label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: widget.selected ? FontWeight.bold : FontWeight.normal,
                  color: widget.isLogout
                      ? (_hovering ? Colors.red.shade300 : Colors.white70)
                      : widget.selected
                          ? const Color(0xFFC79316)
                          : isHighlighted
                              ? Colors.white
                              : Colors.white70,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
