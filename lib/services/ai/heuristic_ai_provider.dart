import 'package:open_stack/domain/entities/issue.dart';
import 'package:open_stack/domain/entities/issue_summary.dart';
import 'package:open_stack/services/ai/ai_provider.dart';

/// Simple placeholder AI that fabricates a tiny summary.
/// todo: plug a real LLM (OpenAI/Gemini/etc.).
class HeuristicAIProvider implements AIProvider {
  @override
  Future<IssueSummary> summarize(Issue issue) async {
    final tldr =
        "This issue is about: ${issue.title}. Start by reading the README and CONTRIBUTING.";
    return IssueSummary(
      tldr: tldr,
      firstPrChecklist: const [
        "Clone repo & run locally",
        "Read CONTRIBUTING.md",
        "Discuss approach on the issue thread",
        "Open a small draft PR",
      ],
      difficultyScore: 2,
    );
  }
}
