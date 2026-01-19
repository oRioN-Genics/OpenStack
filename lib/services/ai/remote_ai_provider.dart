import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:open_stack/domain/entities/issue.dart';
import 'package:open_stack/domain/entities/issue_summary.dart';
import 'package:open_stack/services/ai/ai_provider.dart';

class RemoteAIProvider implements AIProvider {
  RemoteAIProvider({required this.baseUrl, http.Client? client})
    : _client = client ?? http.Client();

  final String baseUrl;
  final http.Client _client;

  @override
  Future<IssueSummary> summarize(Issue issue) async {
    final uri = Uri.parse('$baseUrl/ai/summary');
    final res = await _client.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'issue': {'title': issue.title, 'body': issue.body},
      }),
    );

    if (res.statusCode != 200) {
      throw Exception('Summary failed: ${res.body}');
    }

    final json = jsonDecode(res.body) as Map<String, dynamic>;
    final summary = json['summary'] as Map<String, dynamic>;
    return IssueSummary(
      tldr: summary['tldr'] as String? ?? '',
      firstPrChecklist: (summary['firstPrChecklist'] as List<dynamic>? ?? [])
          .map((e) => e.toString())
          .toList(),
      difficultyScore: summary['difficultyScore'] as int? ?? 3,
    );
  }
}
