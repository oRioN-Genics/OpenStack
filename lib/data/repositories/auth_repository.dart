import 'package:open_stack/domain/entities/user.dart';

abstract class AuthRepository {
  Future<User?> getCurrentUser();
  Stream<User?> userStream();
  Future<User> signInEmail({required String email, required String password});
  Future<User> signInGitHub();
  Future<User> signInGoogle();
  Future<void> signOut();
  Future<String?> getGitHubAccessToken();
}
