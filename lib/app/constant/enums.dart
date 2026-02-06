
/// Vessel status classification
enum VesselStatus { atSea, inPort }
enum DayReasonCode {
  AT_SEA_SPEED_THRESHOLD,
  AT_SEA_DISTANCE_THRESHOLD,
  AT_SEA_UNDERWAY_STATUS,

  IN_PORT_GEOFENCE,
  IN_PORT_STATIONARY,
  IN_PORT_MOORED_STATUS,

  ANCHORED_STATUS,
  ANCHORED_GEOFENCE,

  NO_DATA,
  INSUFFICIENT_DATA,
  PARTIAL_DATA_GAPS,
  OUTLIER_FILTERED,

  MIXED_BEHAVIOR,
  MANUAL_OVERRIDE,
}

enum StcwDayResult {
  actual_sea,
  stand_by,
  yard,
  unknown,
}