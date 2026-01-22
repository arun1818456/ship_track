import 'package:ship_track_flutter/app/models/day_segment_model.dart';

class CalendarDayResult {
  final int totalCalendarDays;
  final int totalAtSeaDays;
  final int totalInPortDays;
  final DateTime? firstTimestamp;
  final DateTime? lastTimestamp;
  final List<DaySegment> segments;

  CalendarDayResult({
    required this.totalCalendarDays,
    required this.totalAtSeaDays,
    required this.totalInPortDays,
    this.firstTimestamp,
    this.lastTimestamp,
    required this.segments,
  });

  Map<String, dynamic> toJson() {
    return {
      'total_calendar_days': totalCalendarDays,
      'total_at_sea_days': totalAtSeaDays,
      'total_in_port_days': totalInPortDays,
      'first_timestamp': firstTimestamp?.toIso8601String(),
      'last_timestamp': lastTimestamp?.toIso8601String(),
      'segments': segments.map((s) => s.toJson()).toList(),
    };
  }
}
