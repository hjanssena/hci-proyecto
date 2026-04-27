import 'package:bebeia_front/viewmodels/users/verification_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class EmailVerificationScreen extends StatefulWidget {
  const EmailVerificationScreen({Key? key}) : super(key: key);

  @override
  State<EmailVerificationScreen> createState() =>
      _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen> {
  @override
  void initState() {
    super.initState();
    // Use addPostFrameCallback to trigger the logic after the first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _processVerification();
    });
  }

  void _processVerification() {
    // Extracting the 'token' from the URL: /verify-email?token=...
    final uri = Uri.base;
    final token = uri.queryParameters['token'];

    if (token != null) {
      context.read<VerificationViewModel>().verifyToken(token);
    } else {
      // Handle missing token
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<VerificationViewModel>();

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (viewModel.state == VerificationState.loading) ...[
              const CircularProgressIndicator(),
              const SizedBox(height: 20),
              const Text("Verificando tu cuenta..."),
            ],
            if (viewModel.state == VerificationState.success) ...[
              const Icon(Icons.check_circle, color: Colors.green, size: 64),
              const SizedBox(height: 16),
              Text(viewModel.message ?? ""),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () =>
                    Navigator.pushReplacementNamed(context, '/login'),
                child: const Text("Ir al Login"),
              ),
            ],
            if (viewModel.state == VerificationState.error) ...[
              const Icon(Icons.error, color: Colors.red, size: 64),
              const SizedBox(height: 16),
              Text(viewModel.message ?? ""),
              const SizedBox(height: 24),
              TextButton(
                onPressed: () =>
                    Navigator.pushReplacementNamed(context, '/login'),
                child: const Text("Volver al inicio"),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
