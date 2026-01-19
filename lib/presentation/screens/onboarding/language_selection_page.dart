import 'package:flutter/material.dart';

class LanguageSelectionPage extends StatelessWidget {
  const LanguageSelectionPage({
    super.key,
    required this.languageOptions,
    required this.selectedLanguages,
    required this.onToggleLanguage,
    required this.onBack,
    required this.onNext,
    required this.onSkip,
    required this.isLoading,
  });

  final List<String> languageOptions;
  final Set<String> selectedLanguages;
  final void Function(String language) onToggleLanguage;
  final VoidCallback onBack;
  final VoidCallback onNext;
  final VoidCallback onSkip;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Best results if you select 2-5 languages.',
            style: TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 12),
          if (isLoading)
            const Center(child: CircularProgressIndicator())
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: languageOptions.map((l) {
                final selected = selectedLanguages.contains(l);
                return FilterChip(
                  label: Text(l),
                  selected: selected,
                  onSelected: (_) => onToggleLanguage(l),
                );
              }).toList(),
            ),
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
