// lib/views/profile/profile_screen.dart
import 'package:bebeia_front/core/validators.dart';
import 'package:bebeia_front/viewmodels/users/login_viewmodel.dart';
import 'package:bebeia_front/viewmodels/users/profile_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'widgets/change_password_modal.dart';
import 'widgets/delete_account_modal.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _lastNameController;

  @override
  void initState() {
    super.initState();
    // Prefill fields with data from the JWT
    final user = context.read<LoginViewModel>().currentUser;
    _nameController = TextEditingController(text: user?.name ?? '');
    _lastNameController = TextEditingController(text: user?.lastName ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _lastNameController.dispose();
    super.dispose();
  }

  void _handleSave(BuildContext context) async {
    if (!_formKey.currentState!.validate()) {
      return; // Stop here if validation fails; errors will show in red UI
    }
    final loginViewModel = context.read<LoginViewModel>();
    final viewModel = context.read<ProfileViewModel>();

    // Ensure we have a user ID before attempting to patch
    if (loginViewModel.currentUser?.id == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error: No se encontró el ID del usuario.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final success = await viewModel.updateBasicInfo(
      loginViewModel.currentUser!.id!,
      _nameController.text,
      _lastNameController.text,
    );

    if (context.mounted) {
      if (success) {
        // 1. Create a new User object with the updated text field values
        final updatedUser = loginViewModel.currentUser?.copyWith(
          name: _nameController.text.trim(),
          lastName: _lastNameController.text.trim(),
        );

        // 2. Pass it to the LoginViewModel to update the global state
        loginViewModel.updateUser(updatedUser!);

        // 3. Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Información actualizada correctamente.'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(viewModel.errorMessage ?? 'Error al actualizar'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Watch LoginViewModel for the hasVerifiedEmail status
    final user = context.watch<LoginViewModel>().currentUser;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(40.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Mi cuenta',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 32),

            // Name and Last Name Fields
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Nombre',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) =>
                        Validators.validateName(value, fieldName: 'El nombre'),
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: TextFormField(
                    controller: _lastNameController,
                    decoration: const InputDecoration(
                      labelText: 'Apellido',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) => Validators.validateName(
                      value,
                      fieldName: 'El apellido',
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Save Button for Basic Info
            Align(
              alignment: Alignment.centerRight,
              child: Consumer<ProfileViewModel>(
                builder: (context, viewModel, child) {
                  return ElevatedButton.icon(
                    icon: viewModel.state == ProfileState.loading
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.save),
                    label: const Text('Guardar cambios'),
                    onPressed: viewModel.state == ProfileState.loading
                        ? null
                        : () => _handleSave(context),
                  );
                },
              ),
            ),

            const SizedBox(height: 32),
            const Divider(),
            const SizedBox(height: 32),

            // Email Validation Section
            if (user != null && !user.hasVerifiedEmail) ...[
              Container(
                padding: const EdgeInsets.all(16),
                color: Colors.amber.shade50,
                child: Row(
                  children: [
                    const Icon(Icons.warning, color: Colors.amber),
                    const SizedBox(width: 12),
                    const Text('Tu correo no ha sido validado.'),
                  ],
                ),
              ),
              const SizedBox(height: 32),
            ],

            // Action Buttons (Modals)
            Row(
              children: [
                ElevatedButton(
                  onPressed: () => showDialog(
                    context: context,
                    builder: (_) => const ChangePasswordModal(),
                  ),
                  child: const Text('Cambiar contraseña'),
                ),
                const SizedBox(width: 16),
                OutlinedButton(
                  style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
                  onPressed: () => showDialog(
                    context: context,
                    builder: (_) => const DeleteAccountModal(),
                  ),
                  child: const Text('Eliminar cuenta'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
