import '../../exports.dart';

class DaySegment {
  final DateTime date;
  final VesselStatus status;
  final int pointCount;
  final DayReasonCode reasonCode;
  final StcwDayResult stcwDayResult;

  DaySegment({
    required this.date,
    required this.status,
    required this.pointCount,
    required this.reasonCode,
    required this.stcwDayResult,
  });

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String().split('T')[0],
      'status': status == VesselStatus.atSea ? 'AT_SEA' : 'IN_PORT',
      'point_count': pointCount,
      'reason_code': reasonCode,
      'stcw_day_result': stcwDayResult,
    };
  }
}
