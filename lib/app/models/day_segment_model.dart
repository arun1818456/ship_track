import '../../exports.dart';

class DaySegment {
   DateTime date;
   VesselStatus status;
   int pointCount;
   DayReasonCode reasonCode;
   StcwDayResult stcwDayResult;
   bool isCountedDay;
   bool confirm;
   String showError;

  DaySegment({
    required this.date,
    required this.status,
    required this.pointCount,
    required this.reasonCode,
    required this.stcwDayResult,
    required this.isCountedDay,
    required this.showError,
    required this.confirm,
  });

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String().split('T')[0],
      'status': status == VesselStatus.atSea ? 'AT_SEA' : 'IN_PORT',
      'point_count': pointCount,
      'reason_code': reasonCode,
      'stcw_day_result': stcwDayResult,
      'is_counted_day': isCountedDay,
      'show_error': showError,
      'confirm': confirm,
    };
  }
}
