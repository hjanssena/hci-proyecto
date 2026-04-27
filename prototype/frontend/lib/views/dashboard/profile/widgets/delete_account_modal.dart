import 'package:bebeia_front/viewmodels/users/profile_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DeleteAccountModal extends StatefulWidget {
  const DeleteAccountModal({Key? key}) : super(key: key);

  @override
  State<DeleteAccountModal> createState() => _DeleteAccountModalState();
}

class _DeleteAccountModalState extends State<DeleteAccountModal> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  bool _isConfirmed = false;

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<ProfileViewModel>();

    return AlertDialog(
      title: const Text('Eliminar cuenta', style: TextStyle(color: Colors.red)),
      content: SizedBox(
        width: 400,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Esta acción es permanente. Se anonimizarán tus datos y se cancelarán tus suscripciones activas.',
                style: TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Ingresa tu contraseña para confirmar',
                  border: OutlineInputBorder(),
                ),
                validator: (v) => v!.isEmpty ? 'Requerido' : null,
              ),
              const SizedBox(height: 16),
              CheckboxListTile(
                title: const Text(
                  'Entiendo que mis datos serán borrados permanentemente.',
                ),
                value: _isConfirmed,
                onChanged: (val) => setState(() => _isConfirmed = val!),
                controlAffinity: ListTileControlAffinity.leading,
                contentPadding: EdgeInsets.zero,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
          ),
          onPressed: (!_isConfirmed || viewModel.state == ProfileState.loading)
              ? null
              : () async {
                  if (_formKey.currentState!.validate()) {
                    await viewModel.deleteAccount(
                      _passwordController.text,
                      _isConfirmed,
                    );
                    if (viewModel.state == ProfileState.deleted &&
                        context.mounted) {
                      Navigator.of(
                        context,
                      ).pushNamedAndRemoveUntil('/login', (route) => false);
                    }
                  }
                },
          child: const Text('Confirmar Eliminación'),
        ),
      ],
    );
  }
}
