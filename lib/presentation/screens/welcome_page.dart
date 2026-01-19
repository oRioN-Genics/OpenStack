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
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFF7FAFC), Color(0xFFEFF6FF)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Stack(
            children: [
              Align(
                alignment: Alignment.center,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 440),
                  child: Card(
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Open Stack',
                            style: theme.textTheme.titleLarge,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Find beginner-friendly open source issues faster.',
                            style: theme.textTheme.bodySmall,
                          ),
                          const SizedBox(height: 24),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: () => _handleSignIn(context, ref),
                              icon: const Icon(Icons.code),
                              label: const Text('Sign in with GitHub'),
                            ),
                          ),
                          const SizedBox(height: 8),
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton(
                              onPressed: () => _skipForNow(context),
                              child: const Text('Continue without sign in'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                right: 20,
                bottom: 16,
                child: Text(
                  'Built for first-time contributors',
                  style: theme.textTheme.bodySmall,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
