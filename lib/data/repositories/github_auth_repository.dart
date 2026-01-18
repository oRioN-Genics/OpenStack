import 'dart:async';
import 'dart:convert';

import 'package:flutter_appauth/flutter_appauth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:open_stack/data/repositories/auth_repository.dart';
import 'package:open_stack/domain/entities/user.dart';
import 'package:open_stack/domain/enums/auth_provider.dart';

class GitHubAuthRepository implements AuthRepository {
  GitHubAuthRepository({
    required String clientId,
    FlutterAppAuth? appAuth,
    FlutterSecureStorage? storage,
    http.Client? httpClient,
  }) : _clientId = clientId,
       _appAuth = appAuth ?? const FlutterAppAuth(),
       _storage = storage ?? const FlutterSecureStorage(),
       _http = httpClient ?? http.Client();

  static const _tokenKey = 'github_access_token';
  static const _redirectUrl = 'openstack://oauth/callback';
  static const _authorizeEndpoint = 'https://github.com/login/oauth/authorize';
  static const _tokenEndpoint = 'https://github.com/login/oauth/access_token';

  final String _clientId;
  final FlutterAppAuth _appAuth;
  final FlutterSecureStorage _storage;
  final http.Client _http;

  final _userController = StreamController<User?>.broadcast();
  User? _currentUser;

  @override
  Future<User?> getCurrentUser() async {
    final token = await getGitHubAccessToken();
    if (token == null || token.isEmpty) return null;
    final user = await _fetchGitHubUser(token);
    _currentUser = user;
    return user;
  }

  @override
  Stream<User?> userStream() => _userController.stream;

  @override
  Future<User> signInGitHub() async {
    final request = AuthorizationTokenRequest(
      _clientId,
      _redirectUrl,
      serviceConfiguration: const AuthorizationServiceConfiguration(
        authorizationEndpoint: _authorizeEndpoint,
        tokenEndpoint: _tokenEndpoint,
      ),
      scopes: const ['read:user'],
    );

    final result = await _appAuth.authorizeAndExchangeCode(request);
    final token = result?.accessToken;
    if (token == null || token.isEmpty) {
      throw Exception('GitHub OAuth failed to return access token.');
    }

    await _storage.write(key: _tokenKey, value: token);
    final user = await _fetchGitHubUser(token);
    _currentUser = user;
    _userController.add(user);
    return user;
  }

  @override
  Future<void> signOut() async {
    await _storage.delete(key: _tokenKey);
    _currentUser = null;
    _userController.add(null);
  }

  @override
  Future<String?> getGitHubAccessToken() async {
    return _storage.read(key: _tokenKey);
  }

  Future<User> _fetchGitHubUser(String token) async {
    final uri = Uri.https('api.github.com', '/user');
    final res = await _http.get(
      uri,
      headers: {
        'Accept': 'application/vnd.github+json',
        'Authorization': 'Bearer $token',
        'User-Agent': 'open-stack-mvp',
      },
    );

    if (res.statusCode != 200) {
      throw Exception(
        'GitHub user fetch failed: ${res.statusCode} ${res.body}',
      );
    }

    final json = jsonDecode(res.body) as Map<String, dynamic>;
    return User(
      id: (json['id'] as int).toString(),
      displayName: json['login'] as String?,
      email: json['email'] as String?,
      provider: AuthProvider.gitHub,
      createdAt: DateTime.now(),
    );
  }

  @override
  Future<User> signInEmail({required String email, required String password}) {
    throw UnimplementedError('Email sign-in not implemented.');
  }

  @override
  Future<User> signInGoogle() {
    throw UnimplementedError('Google sign-in not implemented.');
  }
}
