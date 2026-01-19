import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:open_stack/domain/entities/bookmark.dart';
import 'package:open_stack/presentation/controllers/bookmark_controller.dart';
import 'package:open_stack/presentation/controllers/issue_detail_controller.dart';
import 'package:url_launcher/url_launcher.dart';

class BookmarksPage extends ConsumerWidget {
  const BookmarksPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookmarks = ref.watch(bookmarksControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Bookmarks')),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFF7FAFC), Color(0xFFEFF6FF)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: bookmarks.when(
          data: (items) => _BookmarksList(items: items),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, _) => Center(child: Text('Error: $err')),
        ),
      ),
    );
  }
}

class _BookmarksList extends ConsumerWidget {
  const _BookmarksList({required this.items});

  final List<Bookmark> items;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    if (items.isEmpty) {
      return const Center(child: Text('No bookmarks yet.'));
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final bm = items[index];
        final repoId = bm.repoId;

        return Card(
          child: ListTile(
            title: Text(repoId, style: theme.textTheme.titleSmall),
            subtitle: Text(
              'Saved for later',
              style: theme.textTheme.bodySmall,
            ),
            onTap: () => _openRepo(context, repoId),
            trailing: IconButton(
              icon: const Icon(Icons.bookmark_remove_outlined),
              onPressed: () => _remove(ref, repoId),
            ),
          ),
        );
      },
    );
  }

  Future<void> _remove(WidgetRef ref, String repoId) async {
    final repo = ref.read(bookmarkRepositoryProvider);
    await repo.remove(repoId);
  }

  Future<void> _openRepo(BuildContext context, String repoId) async {
    final url = 'https://github.com/$repoId';
    final uri = Uri.parse(url);
    final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!ok && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open repository link.')),
      );
    }
  }
}
