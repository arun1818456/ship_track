import 'package:ship_track_flutter/app/constant/enums.dart';

class LocalSavedDataModel {
  String? vesselIMO;
  DateTime? date;
  StcwDayResult? status;
  bool? confirm;

  LocalSavedDataModel({this.vesselIMO, this.date, this.status, this.confirm});

  LocalSavedDataModel.fromJson(Map<String, dynamic> json) {
    vesselIMO = json['vesselIMO'];
    date = json['date'];
    status = json['status'];
    confirm = json['confirm'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['vesselIMO'] = vesselIMO;
    data['date'] = date;
    data['status'] = status;
    data['confirm'] = confirm;
    return data;
  }
}
