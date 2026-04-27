import 'package:flutter/material.dart';

/// Shows a confirmation dialog with optional reason text field.
/// Returns the reason string if confirmed (empty string if no reason field), or null if cancelled.
Future<String?> showConfirmationDialog(
  BuildContext context, {
  required String title,
  required String message,
  String confirmLabel = 'Confirmar',
  String cancelLabel = 'Cancelar',
  Color confirmColor = Colors.red,
  bool requireReason = false,
  String reasonLabel = 'Motivo',
}) async {
  final reasonController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  return showDialog<String>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: Form(
        key: formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(message),
            if (requireReason) ...[
              const SizedBox(height: 16),
              TextFormField(
                controller: reasonController,
                decoration: InputDecoration(
                  labelText: reasonLabel,
                  border: const OutlineInputBorder(),
                ),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Este campo es obligatorio';
                  }
                  return null;
                },
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, null),
          child: Text(cancelLabel),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: confirmColor,
            foregroundColor: Colors.white,
          ),
          onPressed: () {
            if (requireReason && !formKey.currentState!.validate()) return;
            Navigator.pop(context, requireReason ? reasonController.text.trim() : '');
          },
          child: Text(confirmLabel),
        ),
      ],
    ),
  );
}
