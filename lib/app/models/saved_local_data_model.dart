import '../constant/enums.dart';

class LocalSavedDataModel {
  String? vesselIMO;
  DateTime? date;
  StcwDayResult? status;
  bool? confirm;

  LocalSavedDataModel({
    this.vesselIMO,
    this.date,
    this.status,
    this.confirm,
  });

  LocalSavedDataModel.fromJson(Map<String, dynamic> json) {
    vesselIMO = json['vesselIMO'];

    // Convert String → DateTime
    date = json['date'] != null ? DateTime.parse(json['date']) : null;

    // Convert String → Enum
    status = json['status'] != null
        ? StcwDayResult.values.firstWhere(
          (e) => e.name == json['status'],
    )
        : null;

    confirm = json['confirm'];
  }

  Map<String, dynamic> toJson() {
    return {
      'vesselIMO': vesselIMO,

      // Convert DateTime → String
      'date': date?.toIso8601String(),

      // Convert Enum → String
      'status': status?.name,

      'confirm': confirm,
    };
  }
}