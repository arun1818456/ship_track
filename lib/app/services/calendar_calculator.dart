import 'package:ship_track_flutter/app/models/calendarday_model.dart';
import 'package:ship_track_flutter/app/models/day_segment_model.dart';
import 'package:ship_track_flutter/app/models/historical_model.dart';
import '../services/ais_classifier.dart';

/// Calculate calendar days from AIS data
class CalendarDayCalculator {
  static CalendarDayResult calculateDays({
    required List<Positions> points,
    DateTime? signOnDate,
    DateTime? signOffDate,
  }) {
    if (points.isEmpty && signOnDate == null && signOffDate == null) {
      return CalendarDayResult(
        totalCalendarDays: 0,
        totalAtSeaDays: 0,
        totalInPortDays: 0,
        segments: [],
      );
    }

    // Sort points
    final sortedPoints = List<Positions>.from(points)
      ..sort((a, b) =>
          a.lastPositionUTC!.compareTo(b.lastPositionUTC!));

    final firstTimestamp = sortedPoints.isNotEmpty
        ? sortedPoints.first.lastPositionUTC
        : signOnDate;

    final lastTimestamp = sortedPoints.isNotEmpty
        ? sortedPoints.last.lastPositionUTC
        : signOffDate;

    final effectiveSignOn = signOnDate ?? firstTimestamp!;
    final effectiveSignOff = signOffDate ?? lastTimestamp!;

    final totalCalendarDays =
        effectiveSignOff.difference(effectiveSignOn).inDays + 1;

    // -------------------------------
    // 🔹 Group AIS points by day
    // -------------------------------
    final Map<DateTime, List<Positions>> pointsByDay = {};

    for (final point in sortedPoints) {
      if (point.lastPositionUTC!.isBefore(effectiveSignOn) ||
          point.lastPositionUTC!.isAfter(effectiveSignOff)) {
        continue;
      }

      final day = DateTime(
        point.lastPositionUTC!.year,
        point.lastPositionUTC!.month,
        point.lastPositionUTC!.day,
      );

      pointsByDay.putIfAbsent(day, () => []).add(point);
    }

    // -------------------------------
    // 🔹 Iterate ALL calendar days
    // -------------------------------
    int atSeaDays = 0;
    int inPortDays = 0;
    final List<DaySegment> segments = [];

    for (int i = 0; i < totalCalendarDays; i++) {
      final day = DateTime(
        effectiveSignOn.year,
        effectiveSignOn.month,
        effectiveSignOn.day + i,
      );

      final dayPoints = pointsByDay[day] ?? [];

      bool isAtSea = false;

      if (dayPoints.isNotEmpty) {
        final classifications = dayPoints
            .map((p) => AISClassifier.classify(p))
            .toList();

        isAtSea = classifications.contains(VesselStatus.atSea);
      }

      if (isAtSea) {
        atSeaDays++;
      } else {
        inPortDays++;
      }

      segments.add(
        DaySegment(
          date: day,
          status: isAtSea
              ? VesselStatus.atSea
              : VesselStatus.inPort, // default when no data
          pointCount: dayPoints.length, // 👈 0 if missing
        ),
      );
    }

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
