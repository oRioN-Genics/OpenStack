import 'package:open_stack/domain/entities/contribution_event.dart';

abstract class ContributionRepository {
  Future<void> upsertAll(List<ContributionEvent> events);
  Stream<List<ContributionEvent>> watchTimeline();
}
