import 'package:ship_track_flutter/app/models/day_segment_model.dart';

class CalendarDaysResult {
  final int totalCalendarDays;
  final int totalAtSeaDays;
  final int totalInPortDays;
  final int totalActualSeaDays;
  final int totalStandByDays;
  final int totalYardDays;
  final int totalUnknownDays;
  final int totalCountableDay;
  final int totalUnCountableDay;
  final List<DaySegment> segments;

  CalendarDaysResult({
    required this.totalCalendarDays,
    required this.totalAtSeaDays,
    required this.totalInPortDays,
    required this.segments,
    required this.totalActualSeaDays,
    required this.totalStandByDays,
    required this.totalYardDays,
    required this.totalUnknownDays,
    required this.totalCountableDay,
    required this.totalUnCountableDay,
  });

  Map<String, dynamic> toJson() {
    return {
      'total_calendar_days': totalCalendarDays,
      'total_at_sea_days': totalAtSeaDays,
      'total_in_port_days': totalInPortDays,
      'segments': segments.map((s) => s.toJson()).toList(),
      'total_actual_sea_days': totalActualSeaDays,
      'total_stand_by_days': totalStandByDays,
      'total_yard_days': totalYardDays,
      'total_unknown_days': totalUnknownDays,
      'total_countable_day': totalCountableDay,
      'total_un_countable_day': totalUnCountableDay,
    };
  }
}
