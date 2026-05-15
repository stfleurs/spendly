import 'package:freezed_annotation/freezed_annotation.dart';
import 'timestamp_converter.dart';

part 'allocation_event.freezed.dart';
part 'allocation_event.g.dart';

@freezed
abstract class AllocationEvent with _$AllocationEvent {
  const factory AllocationEvent({
    required String id,
    required String userId,
    required int amount, // Positive means added to category, negative means removed
    required String fromEntityId, // 'ReadyToAssign' or Category ID
    required String toEntityId, // Category ID or 'ReadyToAssign'
    required String monthId, // Format: yyyy_mm, tracks which period this belongs to
    @TimestampConverter() required DateTime timestamp,
  }) = _AllocationEvent;

  const AllocationEvent._();
  factory AllocationEvent.fromJson(Map<String, dynamic> json) =>
      _$AllocationEventFromJson(json);
}
