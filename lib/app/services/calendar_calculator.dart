import 'package:ship_track_flutter/app/models/calendar_day_model.dart';
import 'package:ship_track_flutter/app/models/day_segment_model.dart';
import 'package:ship_track_flutter/app/models/historical_model.dart';
import '../constant/enums.dart';
import '../services/ais_classifier.dart';

/// Calculate calendar days from AIS data
class CalendarDayCalculator {
  static CalendarDaysResult calculateDays({
    required List<Positions> points,
    DateTime? signOnDate,
    DateTime? signOffDate,
  }) {
    if (points.isEmpty && signOnDate == null && signOffDate == null) {
      return CalendarDaysResult(
        totalCalendarDays: 0,
        totalAtSeaDays: 0,
        totalInPortDays: 0,
        segments: [],
        totalActualSeaDays: 0,
        totalStandByDays: 0,
        totalYardDays: 0,
        totalUnknownDays: 0,
      );
    }

    // Sort points
    final sortedPointsList = List<Positions>.from(points)
      ..sort((a, b) => a.lastPositionUTC!.compareTo(b.lastPositionUTC!));

    final effectiveSignOn =
        signOnDate ?? DateTime.now().subtract(Duration(days: 15));
    final effectiveSignOff = signOffDate ?? DateTime.now();

    final totalCalendarDays =
        effectiveSignOff.difference(effectiveSignOn).inDays + 1;

    // -------------------------------
    // 🔹 Group AIS points by day
    // -------------------------------
    final Map<DateTime, List<Positions>> pointsByDay = {};
    // add points to the map according to date (day){2025-11-05 00:00:00.000:[{Position1},{Position2},...]}
    for (final point in sortedPointsList) {
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
    int actualSeaDays = 0;
    int standByDays = 0;
    int yardDays = 0;
    int unknownDays = 0;

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
            .map((p) => AISClassifier.classifyType(p))
            .toList();
        isAtSea = classifications.contains(VesselStatus.atSea);
      }

      if (isAtSea) {
        atSeaDays++;
      } else {
        inPortDays++;
      }

      /////check reason code for day
      DayReasonCode reasonCode = AISClassifier.getReasonCode(dayPoints);
      StcwDayResult stcwDayResult = AISClassifier.stcwCalculations(dayPoints);

      if (stcwDayResult == StcwDayResult.actual_sea) {
        actualSeaDays++;
      } else if (stcwDayResult == StcwDayResult.stand_by) {
        standByDays++;
      } else if (stcwDayResult == StcwDayResult.yard) {
        yardDays++;
      } else if (stcwDayResult == StcwDayResult.unknown) {
        unknownDays++;
      }

      segments.add(
        DaySegment(
          date: day,
          status: isAtSea
              ? VesselStatus.atSea
              : VesselStatus.inPort,
          pointCount: dayPoints.length,
          reasonCode: reasonCode,
          stcwDayResult: stcwDayResult,
        ),
      );
    }

    return CalendarDaysResult(
      totalCalendarDays: totalCalendarDays,
      totalAtSeaDays: atSeaDays,
      totalInPortDays: inPortDays,
      segments: segments,
      totalActualSeaDays: actualSeaDays,
      totalStandByDays: standByDays,
      totalYardDays: yardDays,
      totalUnknownDays: unknownDays,
    );
  }
}
