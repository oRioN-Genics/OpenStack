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

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Pick up to 5 domains that excite you.',
            style: TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 12),
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
              labelText: 'Other (type your own)',
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
              Text('Remaining: $remaining'),
            ],
          ),
          const Spacer(),
          Row(
            children: [
              TextButton(onPressed: onSkip, child: const Text('Skip')),
              const Spacer(),
              ElevatedButton(onPressed: onNext, child: const Text('Next')),
            ],
          ),
        ],
      ),
    );
  }
}
