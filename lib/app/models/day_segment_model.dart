import 'package:ship_track_flutter/app/models/ais_point_model.dart';

class DaySegment {
  final DateTime date;
  final VesselStatus status;
  final int pointCount;

  DaySegment({
    required this.date,
    required this.status,
    required this.pointCount,
  });

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String().split('T')[0],
      'status': status == VesselStatus.atSea ? 'AT_SEA' : 'IN_PORT',
      'point_count': pointCount,
    };
  }
}
