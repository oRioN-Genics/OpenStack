import 'package:flutter/material.dart';

class DomainSelectionPage extends StatelessWidget {
  const DomainSelectionPage({
    super.key,
    required this.domains,
    required this.domainOptions,
    required this.otherDomainController,
    required this.maxDomains,
    required this.onToggleDomain,
    required this.onAddOtherDomain,
    required this.onNext,
    required this.onSkip,
  });

  final Set<String> domains;
  final List<String> domainOptions;
  final TextEditingController otherDomainController;
  final int maxDomains;
  final void Function(String domain) onToggleDomain;
  final VoidCallback onAddOtherDomain;
  final VoidCallback onNext;
  final VoidCallback onSkip;

  @override
  Widget build(BuildContext context) {
    final remaining = maxDomains - domains.length;
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
                  Text('Pick your focus areas', style: theme.textTheme.titleMedium),
                  const SizedBox(height: 6),
                  Text(
                    'Select up to 5 domains to personalize recommendations.',
                    style: theme.textTheme.bodySmall,
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: domainOptions.map((d) {
                      final selected = domains.contains(d);
                      return FilterChip(
                        label: Text(d),
                        selected: selected,
                        onSelected: (_) => onToggleDomain(d),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: otherDomainController,
                    decoration: const InputDecoration(
                      labelText: 'Other domain',
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      ElevatedButton(
                        onPressed: remaining > 0 ? onAddOtherDomain : null,
                        child: const Text('Add'),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Remaining: $remaining',
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      TextButton(onPressed: onSkip, child: const Text('Skip')),
                      const Spacer(),
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
