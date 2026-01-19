import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:open_stack/core/pagination.dart';
import 'package:open_stack/data/sources/github_source.dart';
import 'package:open_stack/domain/entities/contribution_event.dart';
import 'package:open_stack/domain/entities/issue.dart';
import 'package:open_stack/domain/entities/repository.dart';
import 'package:open_stack/domain/entities/skill_profile.dart';
import 'package:open_stack/domain/enums/difficulty_preference.dart';

class GitHubRestSource implements GitHubSource {
  GitHubRestSource({
    http.Client? client,
    Future<String?> Function()? accessToken,
  }) : _client = client ?? http.Client(),
       _accessToken = accessToken;

  final http.Client _client;
  final Future<String?> Function()? _accessToken;

  static const _baseHeaders = {
    'Accept': 'application/vnd.github+json',
    'User-Agent': 'open-stack-mvp',
  };

  Future<Map<String, String>> _headers() async {
    final headers = Map<String, String>.from(_baseHeaders);
    if (_accessToken != null) {
      final token = await _accessToken!();
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }
    }
    return headers;
  }

  @override
  Future<List<Issue>> searchIssues({
    required SkillProfile profile,
    required Pagination page,
  }) async {
    final query = _buildSearchQuery(profile);
    final uri = Uri.https('api.github.com', '/search/issues', {
      'q': query,
      'page': page.page.toString(),
      'per_page': page.perPage.toString(),
    });

    final res = await _client.get(uri, headers: await _headers());

    if (res.statusCode != 200) {
      throw Exception('GitHub search failed: ${res.statusCode} ${res.body}');
    }

    final Map<String, dynamic> body =
        jsonDecode(res.body) as Map<String, dynamic>;
    final items = (body['items'] as List<dynamic>? ?? const []);
    return items.map((e) => _parseIssue(e as Map<String, dynamic>)).toList();
  }

  @override
  Future<Map<String, Repository>> fetchReposByIds(List<String> ids) async {
    final out = <String, Repository>{};
    await Future.wait(
      ids.map((id) async {
        final parts = id.split('/');
        if (parts.length != 2) return;
        final repo = await _fetchRepo(owner: parts[0], name: parts[1]);
        out[id] = repo;
      }),
    );
    return out;
  }

  @override
  Future<List<ContributionEvent>> getUserContributions(
    String ghUsername,
  ) async {
    final uri = Uri.https('api.github.com', '/users/$ghUsername/events/public');
    final res = await _client.get(uri, headers: await _headers());
    if (res.statusCode != 200) {
      throw Exception('GitHub events failed: ${res.statusCode} ${res.body}');
    }

    final items = jsonDecode(res.body) as List<dynamic>;
    final out = <ContributionEvent>[];

    for (final raw in items) {
      final e = raw as Map<String, dynamic>;
      final type = e['type'] as String?;
      final createdAt = DateTime.parse(e['created_at'] as String);
      final repo = e['repo'] as Map<String, dynamic>?;
      final repoId = repo?['name'] as String? ?? '';

      if (type == 'PullRequestEvent') {
        final payload = e['payload'] as Map<String, dynamic>? ?? const {};
        final action = payload['action'] as String? ?? '';
        final pr = payload['pull_request'] as Map<String, dynamic>? ?? const {};
        final prUrl = pr['html_url'] as String? ?? '';

        if (action == 'opened') {
          out.add(
            ContributionEvent(
              id: e['id'] as String,
              type: 'PR_OPENED',
              repoId: repoId,
              prUrl: prUrl,
              at: createdAt,
            ),
          );
        } else if (action == 'closed' && (pr['merged'] == true)) {
          out.add(
            ContributionEvent(
              id: e['id'] as String,
              type: 'PR_MERGED',
              repoId: repoId,
              prUrl: prUrl,
              at: createdAt,
            ),
          );
        }
      } else if (type == 'IssueCommentEvent') {
        out.add(
          ContributionEvent(
            id: e['id'] as String,
            type: 'COMMENT',
            repoId: repoId,
            prUrl: '',
            at: createdAt,
          ),
        );
      }
    }

    return out;
  }

  @override
  Future<DateTime> getRepoLastCommit({
    required String owner,
    required String name,
  }) async {
    final repo = await _fetchRepo(owner: owner, name: name);
    return repo.lastCommitAt;
  }

  @override
  Future<int> getRepoStars({
    required String owner,
    required String name,
  }) async {
    final repo = await _fetchRepo(owner: owner, name: name);
    return repo.stars;
  }

  Future<Repository> _fetchRepo({
    required String owner,
    required String name,
  }) async {
    final uri = Uri.https('api.github.com', '/repos/$owner/$name');
    final res = await _client.get(uri, headers: await _headers());
    if (res.statusCode != 200) {
      throw Exception('Repo fetch failed: ${res.statusCode} ${res.body}');
    }

    final json = jsonDecode(res.body) as Map<String, dynamic>;
    final license = json['license'] as Map<String, dynamic>?;

    return Repository(
      id: json['full_name'] as String,
      name: json['name'] as String,
      owner: (json['owner'] as Map<String, dynamic>)['login'] as String,
      stars: json['stargazers_count'] as int? ?? 0,
      license: license?['spdx_id'] as String? ?? '',
      archived: json['archived'] as bool? ?? false,
      lastCommitAt: DateTime.parse(json['pushed_at'] as String),
      htmlUrl: json['html_url'] as String,
    );
  }

  String _buildSearchQuery(SkillProfile profile) {
    final parts = <String>['type:issue', 'state:open'];

    if (profile.languages.isNotEmpty) {
      final languagePart = profile.languages
          .map((l) => 'language:${l.trim()}')
          .where((l) => l != 'language:')
          .toList();
      if (languagePart.isNotEmpty) {
        final joined = languagePart.join(' OR ');
        parts.add('($joined)');
      }
    }

    if (profile.difficultyPref == DifficultyPreference.goodFirst) {
      parts.add('label:"good first issue"');
    } else if (profile.difficultyPref == DifficultyPreference.helpWanted) {
      parts.add('label:"help wanted"');
    }

    final cutoff = DateTime.now().subtract(
      Duration(days: profile.lastCommitWithinDays),
    );
    final date = cutoff.toIso8601String().substring(0, 10);
    parts.add('updated:>=$date');

    return parts.join(' ');
  }

  Issue _parseIssue(Map<String, dynamic> json) {
    final labelsRaw = json['labels'] as List<dynamic>? ?? const [];
    final labelNames = labelsRaw
        .map((l) => (l as Map<String, dynamic>)['name'] as String? ?? '')
        .where((l) => l.isNotEmpty)
        .toList();
    final normalized = labelNames.map((l) => l.toLowerCase()).toSet();
    final repoId = _extractRepoId(json);

    return Issue(
      id: '$repoId#${json['number']}',
      title: json['title'] as String? ?? '',
      body: json['body'] as String? ?? '',
      repoId: repoId,
      labels: labelNames,
      htmlUrl: json['html_url'] as String? ?? '',
      goodFirstIssue: normalized.contains('good first issue'),
      helpWanted: normalized.contains('help wanted'),
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  String _extractRepoId(Map<String, dynamic> json) {
    final repoUrl = json['repository_url'] as String?;
    if (repoUrl != null && repoUrl.isNotEmpty) {
      final uri = Uri.parse(repoUrl);
      final segs = uri.pathSegments;
      if (segs.length >= 3 && segs[0] == 'repos') {
        return '${segs[1]}/${segs[2]}';
      }
    }

    final htmlUrl = json['html_url'] as String? ?? '';
    if (htmlUrl.isNotEmpty) {
      final uri = Uri.parse(htmlUrl);
      final segs = uri.pathSegments;
      if (segs.length >= 2) {
        return '${segs[0]}/${segs[1]}';
      }
    }

    return 'unknown/unknown';
  }
}
