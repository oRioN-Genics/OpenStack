import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:open_stack/data/repositories/bookmark_repository.dart';
import 'package:open_stack/domain/entities/bookmark.dart';

final bookmarksControllerProvider = StreamProvider<List<Bookmark>>((ref) {
  final repo = ref.read(bookmarkRepositoryProvider);
  return repo.watchAll();
});
