import 'dart:math';

import 'package:ship_track_flutter/app/models/historical_model.dart';
import '../../exports.dart';

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
}
