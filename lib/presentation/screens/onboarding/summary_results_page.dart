import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:open_stack/domain/entities/recommendation.dart';
import 'package:open_stack/domain/enums/difficulty_preference.dart';
import 'package:open_stack/presentation/controllers/feed_controller.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:open_stack/domain/entities/bookmark.dart';
import 'package:open_stack/presentation/controllers/bookmark_controller.dart';
import 'package:open_stack/presentation/controllers/issue_detail_controller.dart';

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
    final theme = Theme.of(context);

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFF7FAFC), Color(0xFFEFF6FF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Your summary', style: theme.textTheme.titleMedium),
                          const SizedBox(height: 6),
                          Text(summaryText, style: theme.textTheme.bodySmall),
                          const SizedBox(height: 12),
                          LayoutBuilder(
                            builder: (context, constraints) {
                              if (constraints.maxWidth < 520) {
                                return Column(
                                  children: [
                                    DropdownButtonFormField<
                                        DifficultyPreference>(
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
                                      decoration: const InputDecoration(
                                        labelText: 'Difficulty label',
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    TextField(
                                      controller: activityDaysController,
                                      keyboardType: TextInputType.number,
                                      decoration: const InputDecoration(
                                        labelText: 'Activity days',
                                        hintText: '180',
                                      ),
                                    ),
                                  ],
                                );
                              }

                              return Row(
                                children: [
                                  Expanded(
                                    child: DropdownButtonFormField<
                                        DifficultyPreference>(
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
                                      decoration: const InputDecoration(
                                        labelText: 'Difficulty label',
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  SizedBox(
                                    width: 180,
                                    child: TextField(
                                      controller: activityDaysController,
                                      keyboardType: TextInputType.number,
                                      decoration: const InputDecoration(
                                        labelText: 'Activity days',
                                        hintText: '180',
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              OutlinedButton(
                                onPressed: onBack,
                                child: const Text('Back'),
                              ),
                              const Spacer(),
                              ElevatedButton(
                                onPressed: () => onSearch(),
                                child: const Text('Find issues'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text('Recommended issues', style: theme.textTheme.titleMedium),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
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

class _ResultsList extends ConsumerWidget {
  const _ResultsList({required this.items});

  final List<Recommendation> items;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    if (items.isEmpty) {
      return const Center(child: Text('No results yet. Run a search.'));
    }

    final bookmarksAsync = ref.watch(bookmarksControllerProvider);
    final bookmarkedIds =
        bookmarksAsync.value?.map((b) => b.repoId).toSet() ?? <String>{};

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
          child: InkWell(
            onTap: () => _openRepo(context, repo.htmlUrl),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          '${repo.owner}/${repo.name}',
                          style: theme.textTheme.titleMedium,
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          bookmarkedIds.contains(repo.id)
                              ? Icons.bookmark
                              : Icons.bookmark_border,
                        ),
                        onPressed: () => _toggleBookmark(
                          ref,
                          context: context,
                          repoId: repo.id,
                          isBookmarked: bookmarkedIds.contains(repo.id),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 4),
                  Text(
                    '${repo.stars} stars - Updated $daysSince days ago',
                    style: theme.textTheme.bodySmall,
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
                          Text(label, style: theme.textTheme.bodySmall),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _toggleBookmark(
    WidgetRef ref, {
    required BuildContext context,
    required String repoId,
    required bool isBookmarked,
  }) async {
    final repo = ref.read(bookmarkRepositoryProvider);
    if (isBookmarked) {
      await repo.remove(repoId);
      _showSnack(context, 'Bookmark removed.');
      return;
    }
    await repo.save(
      Bookmark(
        id: repoId,
        issueId: repoId,
        repoId: repoId,
        savedAt: DateTime.now(),
      ),
    );
    _showSnack(context, 'Bookmark saved.');
  }

  void _showSnack(BuildContext context, String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _openRepo(BuildContext context, String url) async {
    if (url.isEmpty) {
      _showError(context, 'Missing repository link.');
      return;
    }
    final uri = Uri.tryParse(url);
    if (uri == null) {
      _showError(context, 'Invalid repository link.');
      return;
    }
    final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!ok && context.mounted) {
      _showError(context, 'Could not open the repository link.');
    }
  }

  void _showError(BuildContext context, String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}
