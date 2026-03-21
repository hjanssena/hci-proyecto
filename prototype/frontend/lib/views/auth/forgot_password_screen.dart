import 'package:bebeia_front/core/validators.dart';
import 'package:bebeia_front/viewmodels/users/forgot_password_viewmodel.dart';
import 'package:bebeia_front/views/auth/widgets/password_checklist.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({Key? key}) : super(key: key);

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailFormKey = GlobalKey<FormState>();
  final _resetFormKey = GlobalKey<FormState>();

  final _emailController = TextEditingController();
  final _codeController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    // Wipe the global ViewModel state clean every time this screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ForgotPasswordViewModel>().resetFlow();
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _codeController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _handleRequestCode(BuildContext context) async {
    if (_emailFormKey.currentState!.validate()) {
      await context.read<ForgotPasswordViewModel>().requestReset(
        _emailController.text.trim(),
      );
    }
  }

  void _handleConfirmReset(BuildContext context) async {
    if (_resetFormKey.currentState!.validate()) {
      final viewModel = context.read<ForgotPasswordViewModel>();

      await viewModel.confirmReset(
        _codeController.text.trim(),
        _newPasswordController.text,
        _confirmPasswordController.text,
      );

      if (!mounted) return;

      if (viewModel.state == ForgotPasswordState.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Password reset successfully. You can now log in.'),
            backgroundColor: Colors.green,
          ),
        );
        // Pop the screen. Next time they click "Forgot Password", initState clears it.
        Navigator.pop(context);
      } else if (viewModel.state == ForgotPasswordState.error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(viewModel.errorMessage ?? 'Error resetting password'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reset Password')),
      body: SafeArea(
        child: Consumer<ForgotPasswordViewModel>(
          builder: (context, viewModel, child) {
            // Use the explicit step instead of relying on the loading state
            final isStep2 = viewModel.step == 2;

            return Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: isStep2
                    ? _buildStep2ConfirmReset(viewModel)
                    : _buildStep1RequestCode(viewModel),
              ),
            );
          },
        ),
      ),
    );
  }

  // Step 1: Email Field
  Widget _buildStep1RequestCode(ForgotPasswordViewModel viewModel) {
    return Form(
      key: _emailFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Enter your email address to receive a 6-character verification code.',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              labelText: 'Email',
              border: OutlineInputBorder(),
            ),
            validator: (value) => value == null || value.isEmpty
                ? 'Please enter your email'
                : null,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: viewModel.state == ForgotPasswordState.loading
                ? null
                : () => _handleRequestCode(context),
            child: viewModel.state == ForgotPasswordState.loading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Send Verification Code'),
          ),
          if (viewModel.state == ForgotPasswordState.error) ...[
            const SizedBox(height: 16),
            Text(
              viewModel.errorMessage ?? '',
              style: const TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }

  // Step 2: Verification code field -> new password and password confirm fields
  Widget _buildStep2ConfirmReset(ForgotPasswordViewModel viewModel) {
    return Form(
      key: _resetFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Check your email for the verification code.',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),

          TextFormField(
            controller: _codeController,
            maxLength: 6,
            decoration: const InputDecoration(
              labelText: '6-Character Code',
              border: OutlineInputBorder(),
            ),
            validator: (value) => value == null || value.length != 6
                ? 'Enter the 6-character code'
                : null,
          ),
          const SizedBox(height: 16),

          TextFormField(
            controller: _newPasswordController,
            obscureText: _obscurePassword,
            decoration: InputDecoration(
              labelText: 'New Password',
              border: const OutlineInputBorder(),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword ? Icons.visibility : Icons.visibility_off,
                ),
                onPressed: () =>
                    setState(() => _obscurePassword = !_obscurePassword),
              ),
            ),
            validator: Validators.validatePassword,
          ),
          const SizedBox(height: 8),
          ValueListenableBuilder<TextEditingValue>(
            valueListenable: _newPasswordController,
            builder: (context, value, child) {
              return PasswordChecklist(password: value.text);
            },
          ),
          const SizedBox(height: 16),

          TextFormField(
            controller: _confirmPasswordController,
            obscureText: _obscurePassword,
            decoration: const InputDecoration(
              labelText: 'Confirm New Password',
              border: OutlineInputBorder(),
            ),
            validator: (value) =>
                Validators.confirmPassword(value, _newPasswordController.text),
          ),
          const SizedBox(height: 24),

          ElevatedButton(
            onPressed: viewModel.state == ForgotPasswordState.loading
                ? null
                : () => _handleConfirmReset(context),
            child: viewModel.state == ForgotPasswordState.loading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Reset Password'),
          ),
        ],
      ),
    );
  }
}
