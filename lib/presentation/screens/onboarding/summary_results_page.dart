import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:open_stack/domain/entities/recommendation.dart';
import 'package:open_stack/domain/enums/difficulty_preference.dart';
import 'package:open_stack/presentation/controllers/feed_controller.dart';

class SummaryResultsPage extends ConsumerWidget {
  const SummaryResultsPage({
    super.key,
    required this.domains,
    required this.languages,
    required this.technologies,
    required this.confidence,
    required this.contributionStyle,
    required this.difficulty,
    required this.activityDaysController,
    required this.onDifficultyChanged,
    required this.onSearch,
    required this.onBack,
  });

  final List<String> domains;
  final List<String> languages;
  final List<String> technologies;
  final String? confidence;
  final String? contributionStyle;
  final DifficultyPreference difficulty;
  final TextEditingController activityDaysController;
  final void Function(DifficultyPreference value) onDifficultyChanged;
  final Future<void> Function() onSearch;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final feed = ref.watch(feedControllerProvider);
    final summaryText = _buildSummary();

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(summaryText, style: const TextStyle(fontSize: 16)),
          const SizedBox(height: 12),
          DropdownButtonFormField<DifficultyPreference>(
            value: difficulty,
            items: const [
              DropdownMenuItem(
                value: DifficultyPreference.any,
                child: Text('Any'),
              ),
              DropdownMenuItem(
                value: DifficultyPreference.goodFirst,
                child: Text('Good first issue'),
              ),
              DropdownMenuItem(
                value: DifficultyPreference.helpWanted,
                child: Text('Help wanted'),
              ),
            ],
            onChanged: (value) {
              if (value == null) return;
              onDifficultyChanged(value);
            },
            decoration: const InputDecoration(labelText: 'Difficulty label'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: activityDaysController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Activity window (days)',
              hintText: '180',
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              OutlinedButton(onPressed: onBack, child: const Text('Back')),
              const Spacer(),
              ElevatedButton(
                onPressed: () => onSearch(),
                child: const Text('Find issues'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Expanded(
            child: feed.when(
              data: (items) => _ResultsList(items: items),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Center(child: Text('Error: $err')),
            ),
          ),
        ],
      ),
    );
  }

  String _buildSummary() {
    final domainPart = domains.isEmpty ? 'open source' : domains.join(' and ');
    final languagePart = languages.isEmpty
        ? ''
        : ' and your experience with ${languages.join(', ')}';
    final confidencePart = confidence == null
        ? ''
        : ' You feel $confidence about contributing.';
    final contributionPart = contributionStyle == null
        ? ''
        : ' You prefer $contributionStyle contributions.';
    return 'Based on your interest in $domainPart$languagePart, we found '
        'beginner-friendly repositories that are actively maintained and '
        'welcoming to new contributors.$confidencePart$contributionPart';
  }
}

class _ResultsList extends StatelessWidget {
  const _ResultsList({required this.items});

  final List<Recommendation> items;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const Center(child: Text('No results yet. Run a search.'));
    }

    final groups = <String, List<Recommendation>>{};
    final order = <String>[];

    for (final rec in items) {
      if (!groups.containsKey(rec.repo.id)) {
        groups[rec.repo.id] = [];
        order.add(rec.repo.id);
      }
      groups[rec.repo.id]!.add(rec);
    }

    return ListView.builder(
      itemCount: order.length,
      itemBuilder: (context, index) {
        final repoId = order[index];
        final recs = groups[repoId]!;
        final repo = recs.first.repo;
        final daysSince = DateTime.now().difference(repo.lastCommitAt).inDays;

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${repo.owner}/${repo.name}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Why recommended: ${repo.stars} stars, updated $daysSince days ago',
                  style: const TextStyle(fontSize: 12),
                ),
                const SizedBox(height: 8),
                ...recs.map((rec) {
                  final label = rec.issue.goodFirstIssue
                      ? 'Good first issue'
                      : rec.issue.helpWanted
                      ? 'Help wanted'
                      : 'Open issue';
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(rec.issue.title),
                        Text(label, style: const TextStyle(fontSize: 12)),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }
}
