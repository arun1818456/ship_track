import 'package:ship_track_flutter/app/models/day_segment_model.dart';

class CalendarDaysResult {
  final int totalCalendarDays;
  final int totalAtSeaDays;
  final int totalInPortDays;
  final List<DaySegment> segments;

  CalendarDaysResult({
    required this.totalCalendarDays,
    required this.totalAtSeaDays,
    required this.totalInPortDays,
    required this.segments,
  });

  Map<String, dynamic> toJson() {
    return {
      'total_calendar_days': totalCalendarDays,
      'total_at_sea_days': totalAtSeaDays,
      'total_in_port_days': totalInPortDays,
      'segments': segments.map((s) => s.toJson()).toList(),
    };
  }
}
