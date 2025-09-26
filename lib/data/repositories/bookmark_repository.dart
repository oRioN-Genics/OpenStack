import 'package:open_stack/domain/entities/bookmark.dart';

abstract class BookmarkRepository {
  Future<void> save(Bookmark b);
  Future<void> remove(String id);
  Stream<List<Bookmark>> watchAll();
  Future<bool> isBookmarked(String issueId);
}
