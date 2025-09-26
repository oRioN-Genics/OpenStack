import 'package:open_stack/domain/entities/issue.dart';
import 'package:open_stack/domain/entities/issue_summary.dart';

abstract class AIProvider {
  Future<IssueSummary> summarize(Issue issue);
}
