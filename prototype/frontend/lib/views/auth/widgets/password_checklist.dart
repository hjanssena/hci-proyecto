import 'package:bebeia_front/core/validators.dart';
import 'package:flutter/material.dart';

class PasswordChecklist extends StatelessWidget {
  final String password;

  const PasswordChecklist({Key? key, required this.password}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final reqs = PasswordRequirements.check(password);

    return Column(
      children: [
        _buildRequirementItem("Mínimo 10 caracteres", reqs.hasMinLength),
        _buildRequirementItem("Una Mayúscula", reqs.hasUppercase),
        _buildRequirementItem("Una Minúscula", reqs.hasLowercase),
        _buildRequirementItem("Un Número", reqs.hasNumber),
        _buildRequirementItem("Un Símbolo (!@#\$&*~)", reqs.hasSymbol),
      ],
    );
  }

  Widget _buildRequirementItem(String text, bool isValid) {
    return Row(
      children: [
        Icon(
          isValid ? Icons.check_circle : Icons.circle_outlined,
          color: isValid ? Colors.green : Colors.grey,
          size: 16,
        ),
        const SizedBox(width: 8),
        Text(
          text,
          style: TextStyle(
            color: isValid ? Colors.green : Colors.grey.shade600,
            fontSize: 13,
          ),
        ),
      ],
    );
  }
}
