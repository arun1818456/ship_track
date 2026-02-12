import 'dart:math';

import 'package:ship_track_flutter/app/models/historical_model.dart';
import '../../exports.dart';
import '../models/day_segment_model.dart';

/// Classification logic for AT_SEA / IN_PORT
class AISClassifier {
  static VesselStatus classifyType(Positions point) {
    if ((point.speed ?? 0) >= 2) {
      return VesselStatus.atSea;
    } else {
      return VesselStatus.inPort;
    }
  }

  static DayReasonCode getReasonCode(List<Positions> classifications) {
    if (classifications.isEmpty) return DayReasonCode.NO_DATA;

    // 3️⃣ Insufficient points
    if (classifications.length <= 3) return DayReasonCode.INSUFFICIENT_DATA;

    double maxSpeed = 0;
    double totalDistanceKm = 0;
    bool allZeroSpeed = true;
    List<int> timeGaps = [];

    for (int i = 0; i < classifications.length; i++) {
      final p = classifications[i];
      final speed = p.speed ?? 0;

      if (speed > maxSpeed) maxSpeed = speed;
      if (speed > 0) allZeroSpeed = false;

      // Calculate gaps
      if (i > 0 &&
          p.lastPositionUTC != null &&
          classifications[i - 1].lastPositionUTC != null) {
        final gap = p.lastPositionUTC!
            .difference(classifications[i - 1].lastPositionUTC!)
            .inHours;
        timeGaps.add(gap);
      }

      // Calculate distance from previous point
      if (i > 0 &&
          p.lat != null &&
          p.lon != null &&
          classifications[i - 1].lat != null &&
          classifications[i - 1].lon != null) {
        totalDistanceKm += haversineDistance(
          classifications[i - 1].lat!,
          classifications[i - 1].lon!,
          p.lat!,
          p.lon!,
        );
      }
    }

    // 5️⃣ Partial data gaps
    if (timeGaps.any((gap) => gap > 6)) return DayReasonCode.PARTIAL_DATA_GAPS;

    // 6️⃣ Outlier filtered (example: impossible speeds > 60 knots)
    if (maxSpeed > 60) return DayReasonCode.OUTLIER_FILTERED;

    // 7️⃣ AT SEA logic
    if (maxSpeed > 2.0) return DayReasonCode.AT_SEA_SPEED_THRESHOLD;
    if (totalDistanceKm > 10) return DayReasonCode.AT_SEA_DISTANCE_THRESHOLD;
    if (!allZeroSpeed && maxSpeed <= 2.0) {
      return DayReasonCode.AT_SEA_UNDERWAY_STATUS;
    }

    // 8️⃣ IN PORT logic
    if (allZeroSpeed && totalDistanceKm < 1) {
      return DayReasonCode.IN_PORT_STATIONARY;
    }

    // 9️⃣ Anchored (example: stationary but not in port)
    if (allZeroSpeed && totalDistanceKm >= 1) {
      return DayReasonCode.ANCHORED_STATUS;
    }

    // 10️⃣ Mixed / fallback
    return DayReasonCode.MIXED_BEHAVIOR;
  }

  ///  Calculations of STCW Data

  static StcwDayResult stcwCalculations(List<Positions> classifications) {
    // 2️⃣ No data → UNKNOWN
    if (classifications.isEmpty) return StcwDayResult.unknown;

    // 3️⃣ Calculate total "at sea" duration (speed > 2 knots)
    classifications.sort(
      (a, b) => a.lastPositionUTC!.compareTo(b.lastPositionUTC!),
    );

    Duration atSeaDuration = Duration.zero;

    for (int i = 0; i < classifications.length - 1; i++) {
      final curr = classifications[i];
      final next = classifications[i + 1];

      if (curr.lastPositionUTC == null || next.lastPositionUTC == null) {
        continue;
      }

      final diff = next.lastPositionUTC!.difference(curr.lastPositionUTC!);

      if ((curr.speed ?? 0) > 2.0) {
        atSeaDuration += diff;
      }
    }

    // 4️⃣ Assign status based on 4-hour rule
    if (atSeaDuration.inHours >= 4) {
      return StcwDayResult.actual_sea;
    } else {
      return StcwDayResult.stand_by;
    }
  }

  /// ///// material for  Classifications

  static double haversineDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const R = 6371; // Radius of Earth in km
    double deg2rad(double deg) => deg * pi / 180;
    final dLat = deg2rad(lat2 - lat1);
    final dLon = deg2rad(lon2 - lon1);

    final a =
        sin(dLat / 2) * sin(dLat / 2) +
        cos(deg2rad(lat1)) * cos(deg2rad(lat2)) * sin(dLon / 2) * sin(dLon / 2);

    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return R * c;
  }

  //// Countable day calculations
  DaySegment countAbleDays(List<DaySegment> segments, DaySegment daySegment) {
    // print("\n================ STCW COUNT DEBUG START ================");
    // print("Target Day => ${daySegment.date}");
    // print("Target Status => ${daySegment.stcwDayResult}");

    int seaCount = 0;
    int standbyCount = 0;
    int unknownCount = 0;
    int yardCount = 0;
    bool countedDay = false;
    String errorMessage = "";

    for (DaySegment segment in segments) {
      // print("\n---- Processing Segment ----");
      // print("Date => ${segment.date}");
      // print("Status => ${segment.stcwDayResult}");
      // print(
      //   "Before Count => SEA:$seaCount | STANDBY:$standbyCount | UNKNOWN:$unknownCount",
      // );

      if (segment.stcwDayResult == StcwDayResult.actual_sea) {
        if (standbyCount != 0 || unknownCount != 0) {
          standbyCount = 0;
          unknownCount = 0;
          yardCount = 0;
          errorMessage = "";
          seaCount = 1;
        } else {
          seaCount++;
        }
        countedDay = true;
      } else if (segment.stcwDayResult == StcwDayResult.stand_by) {
        if (seaCount > standbyCount) {
          standbyCount++;
          countedDay = true;
          //print("Standby counted (within sea balance)");
        } else if (seaCount <= standbyCount && standbyCount <= 14) {
          standbyCount++;
          countedDay = false;
          // print("Standby exists but exceeds sea balance");
        } else if (standbyCount > seaCount && standbyCount > 14) {
          standbyCount++;
          countedDay = false;
          errorMessage = "Exceeds 14-day standby cap";
          //print("ERROR => $errorMessage");
        }
        // lastDay = StcwDayResult.stand_by;
      } else if (segment.stcwDayResult == StcwDayResult.yard) {
        if (90 > yardCount) {
          yardCount++;
          countedDay = true;
          // print("Yard counted (within sea balance)");
        } else {
          yardCount++;
          countedDay = false;
          // errorMessage = "Exceeds Limit  yard Day  cap";
          // print("ERROR => $errorMessage");
          // print("Yard exists but exceeds sea balance");
        }
        // lastDay = StcwDayResult.yard;
        // print("Yard Day => Always Counted");
      } else if (segment.stcwDayResult == StcwDayResult.unknown) {
        if (seaCount > unknownCount &&
            countedDay == true &&
            seaCount > standbyCount) {
          unknownCount++;
          standbyCount++;
          countedDay = true;
          // print("Unknown counted within sea balance");
        } else {
          unknownCount++;
          countedDay = false;
          errorMessage = "";
          // print("Unknown NOT counted");
        }
        // lastDay= StcwDayResult.unknown;
      }

      // print(
      //   "After Count => SEA:$seaCount | STANDBY:$standbyCount | UNKNOWN:$unknownCount | YARD:$yardCount | ERROR:$errorMessage",
      // );
      // print("Counted Decision => $countedDay");

      // 🔥 Target Day Found
      if (segment.date == daySegment.date) {
        final data = DaySegment(
          date: daySegment.date,
          status: daySegment.status,
          pointCount: daySegment.pointCount,
          reasonCode: daySegment.reasonCode,
          stcwDayResult: daySegment.stcwDayResult,
          isCountedDay: countedDay,
          showError: errorMessage,
          confirm: false,
        );

        // print("\n***** FINAL RESULT FOR TARGET DAY *****");
        // print(data.toJson());
        // print("================ STCW COUNT DEBUG END ================\n");

        return data;
      }
    }

    // print("Target day not found in segment list");
    // print("================ STCW COUNT DEBUG END ================\n");

    return DaySegment(
      date: daySegment.date,
      status: daySegment.status,
      pointCount: daySegment.pointCount,
      reasonCode: daySegment.reasonCode,
      stcwDayResult: daySegment.stcwDayResult,
      isCountedDay: daySegment.isCountedDay,
      showError: daySegment.showError,
      confirm: false,
    );
  }
}
