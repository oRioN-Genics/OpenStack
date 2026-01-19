import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:open_stack/core/backend_config.dart';
import 'package:open_stack/domain/entities/issue.dart';
import 'package:open_stack/domain/entities/issue_summary.dart';
import 'package:open_stack/domain/entities/recommendation.dart';
import 'package:open_stack/domain/entities/repository.dart';

class PersonalizationService {
  PersonalizationService({required this.baseUrl, http.Client? client})
    : _client = client ?? http.Client();

  final String baseUrl;
  final http.Client _client;

  Future<List<String>> suggestLanguages(List<String> domains) async {
    final uri = Uri.parse('$baseUrl/ai/languages');
    final res = await _client.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'domains': domains}),
    );

    if (res.statusCode != 200) {
      throw Exception('Language suggestion failed: ${res.body}');
    }

    final json = jsonDecode(res.body) as Map<String, dynamic>;
    final list = (json['languages'] as List<dynamic>? ?? [])
        .map((e) => e.toString())
        .toList();
    return list;
  }

  Future<Map<String, List<String>>> suggestTechnologies({
    required List<String> domains,
    required List<String> languages,
  }) async {
    final uri = Uri.parse('$baseUrl/ai/tools');
    final res = await _client.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'domains': domains, 'languages': languages}),
    );

    if (res.statusCode != 200) {
      throw Exception('Tool suggestion failed: ${res.body}');
    }

    final json = jsonDecode(res.body) as Map<String, dynamic>;
    final groups = json['groups'] as Map<String, dynamic>? ?? {};
    return groups.map((key, value) {
      final items = (value as List<dynamic>).map((e) => e.toString()).toList();
      return MapEntry(key, items);
    });
  }

  Future<List<Recommendation>> searchRecommendations({
    required List<String> domains,
    required List<String> languages,
    required List<String> technologies,
    required String? confidence,
    required String? contributionStyle,
    required String difficultyPref,
    required int activityDays,
  }) async {
    final uri = Uri.parse('$baseUrl/ai/search');
    final res = await _client.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'domains': domains,
        'languages': languages,
        'technologies': technologies,
        'confidence': confidence,
        'contributionStyle': contributionStyle,
        'difficultyPref': difficultyPref,
        'activityDays': activityDays,
      }),
    );

    if (res.statusCode != 200) {
      throw Exception('Search failed: ${res.body}');
    }

    final json = jsonDecode(res.body) as Map<String, dynamic>;
    final results = (json['results'] as List<dynamic>? ?? []);
    return results.map((raw) {
      final m = raw as Map<String, dynamic>;
      final issue = _parseIssue(m['issue'] as Map<String, dynamic>);
      final repo = _parseRepo(m['repo'] as Map<String, dynamic>);
      final summary = _parseSummary(m['summary'] as Map<String, dynamic>);
      final score = (m['score'] as num?)?.toDouble() ?? 0.0;
      return Recommendation(
        issue: issue,
        repo: repo,
        summary: summary,
        score: score,
      );
    }).toList();
  }

  Issue _parseIssue(Map<String, dynamic> json) {
    return Issue(
      id: json['id'] as String,
      title: json['title'] as String,
      body: json['body'] as String? ?? '',
      repoId: json['repoId'] as String,
      labels: (json['labels'] as List<dynamic>? ?? [])
          .map((e) => e.toString())
          .toList(),
      htmlUrl: json['htmlUrl'] as String? ?? '',
      goodFirstIssue: json['goodFirstIssue'] == true,
      helpWanted: json['helpWanted'] == true,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Repository _parseRepo(Map<String, dynamic> json) {
    return Repository(
      id: json['id'] as String,
      name: json['name'] as String,
      owner: json['owner'] as String,
      stars: json['stars'] as int? ?? 0,
      license: json['license'] as String? ?? '',
      archived: json['archived'] == true,
      lastCommitAt: DateTime.parse(json['lastCommitAt'] as String),
      htmlUrl: json['htmlUrl'] as String? ?? '',
    );
  }

  IssueSummary _parseSummary(Map<String, dynamic> json) {
    return IssueSummary(
      tldr: json['tldr'] as String? ?? '',
      firstPrChecklist: (json['firstPrChecklist'] as List<dynamic>? ?? [])
          .map((e) => e.toString())
          .toList(),
      difficultyScore: json['difficultyScore'] as int? ?? 3,
    );
  }
}

final personalizationServiceProvider = Provider<PersonalizationService>((ref) {
  final baseUrl = ref.read(backendBaseUrlProvider);
  return PersonalizationService(baseUrl: baseUrl);
});
