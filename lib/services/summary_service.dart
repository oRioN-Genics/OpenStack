import 'package:open_stack/domain/entities/issue.dart';
import 'package:open_stack/domain/entities/issue_summary.dart';
import 'package:open_stack/services/ai/ai_provider.dart';

class SummaryService {
  AIProvider _provider;
  SummaryService(this._provider);

  Future<IssueSummary> summarize(Issue issue) => _provider.summarize(issue);

  void setProvider(AIProvider p) {
    _provider = p;
  }
}
