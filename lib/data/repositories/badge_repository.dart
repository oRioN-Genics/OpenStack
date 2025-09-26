import 'package:open_stack/domain/entities/badge.dart';

abstract class BadgeRepository {
  Future<void> award(Badge b);
  Stream<List<Badge>> watchAll();
}
