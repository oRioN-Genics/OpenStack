import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:open_stack/presentation/controllers/profile_controller.dart';
import 'package:open_stack/presentation/screens/onboarding/onboarding_flow.dart';

class WelcomePage extends ConsumerWidget {
  const WelcomePage({super.key});

  Future<void> _handleSignIn(BuildContext context, WidgetRef ref) async {
    await ref.read(profileControllerProvider.notifier).signInGitHub();
    if (context.mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const OnboardingFlow()),
      );
    }
  }

  void _skipForNow(BuildContext context) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const OnboardingFlow()),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Welcome to Open Stack!',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => _handleSignIn(context, ref),
                    child: const Text('Sign in with GitHub'),
                  ),
                ],
              ),
            ),
            Positioned(
              right: 16,
              bottom: 16,
              child: TextButton(
                onPressed: () => _skipForNow(context),
                child: const Text('Skip for now'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
