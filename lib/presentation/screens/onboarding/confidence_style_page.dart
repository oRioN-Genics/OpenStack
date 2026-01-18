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
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'How confident do you feel contributing to open source?',
            style: TextStyle(fontSize: 16),
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
            );
          }),
          const SizedBox(height: 12),
          const Text(
            'What kind of contribution do you prefer?',
            style: TextStyle(fontSize: 16),
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
            );
          }),
          const Spacer(),
          Row(
            children: [
              OutlinedButton(onPressed: onBack, child: const Text('Back')),
              const Spacer(),
              TextButton(onPressed: onSkip, child: const Text('Skip')),
              const SizedBox(width: 8),
              ElevatedButton(onPressed: onNext, child: const Text('Next')),
            ],
          ),
        ],
      ),
    );
  }
}
