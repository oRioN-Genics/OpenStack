import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:open_stack/data/repositories/auth_repository.dart';
import 'package:open_stack/domain/entities/user.dart';

class ProfileController extends Notifier<User?> {
  late final AuthRepository _auth;

  @override
  User? build() {
    _auth = ref.read(authRepositoryProvider);
    // listen to user stream
    _auth.userStream().listen((u) => state = u);
    return null;
  }

  Stream<User?> userStream() => _auth.userStream();

  Future<void> signInGitHub() async {
    await _auth.signInGitHub();
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }
}

final profileControllerProvider = NotifierProvider<ProfileController, User?>(
  ProfileController.new,
);

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  throw UnimplementedError('AuthRepository not provided yet.');
});
