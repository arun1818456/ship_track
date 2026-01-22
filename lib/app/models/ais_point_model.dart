// class AISPoint {
//   final DateTime timestamp;
//   final double speed;
//   final double lat;
//   final double lon;
//
//   AISPoint({
//     required this.timestamp,
//     required this.speed,
//     required this.lat,
//     required this.lon,
//   });
//
//   factory AISPoint.fromJson(Map<String, dynamic> json) {
//     return AISPoint(
//       timestamp: DateTime.parse(json['last_position_UTC']),
//       speed: (json['speed'] ?? 0).toDouble(),
//       lat: (json['lat'] ?? 0).toDouble(),
//       lon: (json['lon'] ?? 0).toDouble(),
//     );
//   }
// }
