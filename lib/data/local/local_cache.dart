import 'package:open_stack/domain/entities/issue.dart';
import 'package:open_stack/domain/entities/repository.dart';

abstract class LocalCache {
  Future<void> putIssues(String cacheKey, List<Issue> issues);
  Future<List<Issue>> getIssuesByQuery(String cacheKey);

  Future<void> putRepos(List<Repository> repos);
  Future<Repository?> getRepo(String id);

  Future<void> clearExpired();
}
