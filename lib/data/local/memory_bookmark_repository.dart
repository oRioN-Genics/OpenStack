import 'dart:async';

import 'package:open_stack/data/repositories/bookmark_repository.dart';
import 'package:open_stack/domain/entities/bookmark.dart';

class MemoryBookmarkRepository implements BookmarkRepository {
  final List<Bookmark> _items = [];
  final StreamController<List<Bookmark>> _controller =
      StreamController<List<Bookmark>>.broadcast();

  @override
  Future<void> save(Bookmark b) async {
    _items.removeWhere((i) => i.id == b.id);
    _items.add(b);
    _controller.add(List.unmodifiable(_items));
  }

  @override
  Future<void> remove(String id) async {
    _items.removeWhere((i) => i.id == id || i.repoId == id || i.issueId == id);
    _controller.add(List.unmodifiable(_items));
  }

  @override
  Stream<List<Bookmark>> watchAll() async* {
    yield List.unmodifiable(_items);
    yield* _controller.stream;
  }

  @override
  Future<bool> isBookmarked(String issueId) async {
    return _items.any(
      (i) => i.id == issueId || i.repoId == issueId || i.issueId == issueId,
    );
  }
}
