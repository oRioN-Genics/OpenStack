import 'package:open_stack/data/repositories/badge_repository.dart';
import 'package:open_stack/data/repositories/bookmark_repository.dart';
import 'package:open_stack/data/repositories/contribution_repository.dart';
import 'package:open_stack/domain/entities/badge.dart';
import 'package:open_stack/domain/entities/bookmark.dart';
import 'package:open_stack/domain/entities/contribution_event.dart';

class BadgeService {
  final ContributionRepository contributions;
  final BookmarkRepository bookmarks;
  final BadgeRepository badges;

  BadgeService({
    required this.contributions,
    required this.bookmarks,
    required this.badges,
  });

  /// Dummy award logic for now.
  Future<List<Badge>> evaluateAwards(
    List<ContributionEvent> events,
    List<Bookmark> bms,
  ) async {
    final out = <Badge>[];
    if (events.any((e) => e.type == 'PR_MERGED')) {
      out.add(
        Badge(
          code: 'first-merge',
          title: 'First Merge!',
          description: 'Your first PR got merged — bravo.',
          awardedAt: DateTime.now(),
        ),
      );
    }
    return out;
  }
}
