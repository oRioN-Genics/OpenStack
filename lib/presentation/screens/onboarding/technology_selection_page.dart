import 'package:flutter/material.dart';

class TechnologySelectionPage extends StatelessWidget {
  const TechnologySelectionPage({
    super.key,
    required this.techGroups,
    required this.selectedTechnologies,
    required this.onToggleTechnology,
    required this.onBack,
    required this.onNext,
    required this.onSkip,
  });

  final Map<String, List<String>> techGroups;
  final Set<String> selectedTechnologies;
  final void Function(String tech) onToggleTechnology;
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
            'Select tools or frameworks you know (optional).',
            style: TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: ListView(
              children: techGroups.entries.map((entry) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        entry.key,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: entry.value.map((tech) {
                          final selected = selectedTechnologies.contains(tech);
                          return FilterChip(
                            label: Text(tech),
                            selected: selected,
                            onSelected: (_) => onToggleTechnology(tech),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
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
