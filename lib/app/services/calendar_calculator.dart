import 'package:ship_track_flutter/app/models/calendarday_model.dart';
import 'package:ship_track_flutter/app/models/day_segment_model.dart';

import '../models/ais_point_model.dart';
import '../services/ais_classifier.dart';

/// Calculate calendar days from AIS data
class CalendarDayCalculator {
  static CalendarDayResult calculateDays({
    required List<AISPoint> points,
    DateTime? signOnDate,
    DateTime? signOffDate,
  }) {
    if (points.isEmpty) {
      return CalendarDayResult(
        totalCalendarDays: 0,
        totalAtSeaDays: 0,
        totalInPortDays: 0,
        segments: [],
      );
    }

    // Sort points by timestamp
    final sortedPoints = List<AISPoint>.from(points)
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));

    final firstTimestamp = sortedPoints.first.timestamp;
    final lastTimestamp = sortedPoints.last.timestamp;

    // Use provided dates or default to first/last timestamp
    final effectiveSignOn = signOnDate ?? firstTimestamp;
    final effectiveSignOff = signOffDate ?? lastTimestamp;

    // Calculate total calendar days (inclusive)
    final totalCalendarDays =
        effectiveSignOff.difference(effectiveSignOn).inDays + 1;

    // Group points by calendar day
    final Map<DateTime, List<AISPoint>> pointsByDay = {};
    for (final point in sortedPoints) {
      // Only consider points within sign-on/sign-off range
      if (point.timestamp.isBefore(effectiveSignOn) ||
          point.timestamp.isAfter(effectiveSignOff)) {
        continue;
      }

      final day = DateTime(
        point.timestamp.year,
        point.timestamp.month,
        point.timestamp.day,
      );

      pointsByDay.putIfAbsent(day, () => []).add(point);
    }

    // Classify each day
    int atSeaDays = 0;
    int inPortDays = 0;
    final List<DaySegment> segments = [];

    for (final entry in pointsByDay.entries) {
      final day = entry.key;
      final dayPoints = entry.value;

      // Classify all points for this day
      final classifications = dayPoints
          .map((p) => AISClassifier.classify(p))
          .toList();

      // Day is AT_SEA if at least one point is AT_SEA
      final hasAtSea = classifications.contains(VesselStatus.atSea);

      if (hasAtSea) {
        atSeaDays++;
      } else {
        inPortDays++;
      }

      segments.add(
        DaySegment(
          date: day,
          status: hasAtSea ? VesselStatus.atSea : VesselStatus.inPort,
          pointCount: dayPoints.length,
        ),
      );
    }

    // Sort segments by date
    segments.sort((a, b) => a.date.compareTo(b.date));

    return CalendarDayResult(
      totalCalendarDays: totalCalendarDays,
      totalAtSeaDays: atSeaDays,
      totalInPortDays: inPortDays,
      firstTimestamp: firstTimestamp,
      lastTimestamp: lastTimestamp,
      segments: segments,
    );
  }
}
