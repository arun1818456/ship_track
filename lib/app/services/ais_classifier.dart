import '../models/ais_point_model.dart';

/// Classification logic for AT_SEA / IN_PORT
class AISClassifier {
  static VesselStatus classify(AISPoint point) {
    if (point.speed >= 6) {
      return VesselStatus.atSea;
    } else {
      return VesselStatus.inPort;
    }

    // Rule 2: AT_SEA if nav_status == "Under way using engine" and sog >= 2
    // if (point.navStatus == "Under way using engine" && point.sog >= 2) {
    //   return VesselStatus.atSea;
    // }

    // Rule 3: IN_PORT if nav_status == "Moored" or "At anchor" and sog <= 1
    // if ((point.navStatus == "Moored" || point.navStatus == "At anchor") &&
    //     point.sog <= 1) {
    //   return VesselStatus.inPort;
    // }

    // Default fallback = IN_PORT
    return VesselStatus.inPort;
  }

  /// Classify a list of AIS points
  static List<VesselStatus> classifyAll(List<AISPoint> points) {
    return points.map((point) => classify(point)).toList();
  }
}
