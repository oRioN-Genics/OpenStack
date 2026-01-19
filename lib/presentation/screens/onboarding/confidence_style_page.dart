import 'package:flutter/material.dart';

class ConfidenceStylePage extends StatelessWidget {
  const ConfidenceStylePage({
    super.key,
    required this.confidenceOptions,
    required this.contributionOptions,
    required this.selectedConfidence,
    required this.selectedContributionStyle,
    required this.onConfidenceChanged,
    required this.onContributionStyleChanged,
    required this.onBack,
    required this.onNext,
    required this.onSkip,
  });

  final List<String> confidenceOptions;
  final List<String> contributionOptions;
  final String? selectedConfidence;
  final String? selectedContributionStyle;
  final void Function(String value) onConfidenceChanged;
  final void Function(String value) onContributionStyleChanged;
  final VoidCallback onBack;
  final VoidCallback onNext;
  final VoidCallback onSkip;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFF7FAFC), Color(0xFFEFF6FF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: Card(
            margin: const EdgeInsets.all(16),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Confidence level', style: theme.textTheme.titleMedium),
                  const SizedBox(height: 6),
                  Text(
                    'How confident do you feel contributing to open source?',
                    style: theme.textTheme.bodySmall,
                  ),
                  const SizedBox(height: 8),
                  ...confidenceOptions.map((c) {
                    return RadioListTile<String>(
                      value: c,
                      groupValue: selectedConfidence,
                      onChanged: (value) {
                        if (value == null) return;
                        onConfidenceChanged(value);
                      },
                      title: Text(c),
                      dense: true,
                    );
                  }),
                  const SizedBox(height: 12),
                  Text(
                    'Contribution style',
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'What kind of contribution do you prefer?',
                    style: theme.textTheme.bodySmall,
                  ),
                  const SizedBox(height: 8),
                  ...contributionOptions.map((c) {
                    return RadioListTile<String>(
                      value: c,
                      groupValue: selectedContributionStyle,
                      onChanged: (value) {
                        if (value == null) return;
                        onContributionStyleChanged(value);
                      },
                      title: Text(c),
                      dense: true,
                    );
                  }),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      OutlinedButton(
                        onPressed: onBack,
                        child: const Text('Back'),
                      ),
                      const Spacer(),
                      TextButton(onPressed: onSkip, child: const Text('Skip')),
                      const SizedBox(width: 8),
                      ElevatedButton(onPressed: onNext, child: const Text('Next')),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
