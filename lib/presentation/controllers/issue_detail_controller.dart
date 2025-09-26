import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:open_stack/data/repositories/bookmark_repository.dart';
import 'package:open_stack/domain/entities/issue.dart';
import 'package:open_stack/domain/entities/issue_summary.dart';
import 'package:open_stack/services/summary_service.dart';

class IssueDetailController extends Notifier<AsyncValue<IssueSummary>> {
  late final SummaryService _summaries;
  late final BookmarkRepository _bookmarks;

  @override
  AsyncValue<IssueSummary> build() {
    _summaries = ref.read(summaryServiceProvider);
    _bookmarks = ref.read(bookmarkRepositoryProvider);
    return const AsyncValue.loading();
  }

  Future<void> loadSummary(Issue i) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _summaries.summarize(i));
  }

  Future<void> toggleBookmark(Issue i) async {
    final isSaved = await _bookmarks.isBookmarked(i.id);
    if (isSaved) {
      // placeholder for now
    } else {
      // placeholder save
    }
  }
}

final issueDetailControllerProvider =
    NotifierProvider<IssueDetailController, AsyncValue<IssueSummary>>(
      IssueDetailController.new,
    );

final summaryServiceProvider = Provider<SummaryService>((ref) {
  throw UnimplementedError('SummaryService not provided yet.');
});

final bookmarkRepositoryProvider = Provider<BookmarkRepository>((ref) {
  throw UnimplementedError('BookmarkRepository not provided yet.');
});
