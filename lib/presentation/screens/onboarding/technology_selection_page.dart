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
    required this.isLoading,
  });

  final Map<String, List<String>> techGroups;
  final Set<String> selectedTechnologies;
  final void Function(String tech) onToggleTechnology;
  final VoidCallback onBack;
  final VoidCallback onNext;
  final VoidCallback onSkip;
  final bool isLoading;

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
          constraints: const BoxConstraints(maxWidth: 680),
          child: Card(
            margin: const EdgeInsets.all(16),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Tools you know', style: theme.textTheme.titleMedium),
                  const SizedBox(height: 6),
                  Text(
                    'Optional. This helps match project stacks.',
                    style: theme.textTheme.bodySmall,
                  ),
                  const SizedBox(height: 12),
                  if (isLoading)
                    const Center(child: CircularProgressIndicator())
                  else
                    ...techGroups.entries.map((entry) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              entry.key,
                              style: theme.textTheme.titleSmall,
                            ),
                            const SizedBox(height: 6),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: entry.value.map((tech) {
                                final selected =
                                    selectedTechnologies.contains(tech);
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
                    }),
                  const SizedBox(height: 12),
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
