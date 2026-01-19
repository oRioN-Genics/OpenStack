import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:open_stack/domain/entities/bookmark.dart';
import 'package:open_stack/presentation/controllers/issue_detail_controller.dart';

final bookmarksControllerProvider = StreamProvider<List<Bookmark>>((ref) {
  final repo = ref.read(bookmarkRepositoryProvider);
  return repo.watchAll();
});
