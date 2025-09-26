import 'package:open_stack/domain/entities/issue.dart';
import 'package:open_stack/domain/entities/repository.dart';
import 'package:open_stack/domain/entities/issue_summary.dart';

class Recommendation {
  final Issue issue;
  final Repository repo;
  final double score;
  final IssueSummary summary;

  const Recommendation({
    required this.issue,
    required this.repo,
    required this.score,
    required this.summary,
  });
}
