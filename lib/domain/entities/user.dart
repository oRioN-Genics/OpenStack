import 'package:open_stack/domain/enums/auth_provider.dart';

class User {
  final String id;
  final String? email;
  final String? displayName;
  final AuthProvider provider;
  final DateTime createdAt;

  const User({
    required this.id,
    this.email,
    this.displayName,
    required this.provider,
    required this.createdAt,
  });
}
