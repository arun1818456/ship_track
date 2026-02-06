class HistoricalModelData {
  Data? data;
  Meta? meta;

  HistoricalModelData({this.data, this.meta});

  HistoricalModelData.fromJson(Map<String, dynamic> json) {
    data = json['data'] != null ? Data.fromJson(json['data']) : null;
    meta = json['meta'] != null ? Meta.fromJson(json['meta']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    if (meta != null) {
      data['meta'] = meta!.toJson();
    }
    return data;
  }
}

class Data {
  String? uuid;
  String? name;
  String? mmsi;
  String? imo;

  // Null? eni;
  String? countryIso;
  String? type;
  String? typeSpecific;
  List<Positions>? positions;

  Data({
    this.uuid,
    this.name,
    this.mmsi,
    this.imo,
    // this.eni,
    this.countryIso,
    this.type,
    this.typeSpecific,
    this.positions,
  });

  Data.fromJson(Map<String, dynamic> json) {
    uuid = json['uuid'];
    name = json['name'];
    mmsi = json['mmsi'];
    imo = json['imo'];
    // eni = json['eni'];
    countryIso = json['country_iso'];
    type = json['type'];
    typeSpecific = json['type_specific'];
    if (json['positions'] != null) {
      positions = <Positions>[];
      json['positions'].forEach((v) {
        positions!.add(Positions.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['uuid'] = uuid;
    data['name'] = name;
    data['mmsi'] = mmsi;
    data['imo'] = imo;
    // data['eni'] = eni;
    data['country_iso'] = countryIso;
    data['type'] = type;
    data['type_specific'] = typeSpecific;
    if (positions != null) {
      data['positions'] = positions!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Positions {
  double? lat;
  double? lon;
  double? speed;
  double? course;
  int? heading;
  String? destination;
  int? lastPositionEpoch;
  DateTime? lastPositionUTC;

  Positions({
    this.lat,
    this.lon,
    this.speed,
    this.course,
    this.heading,
    this.destination,
    this.lastPositionEpoch,
    this.lastPositionUTC,
  });

  Positions.fromJson(Map<String, dynamic> json) {
    lat = (json['lat'] ?? 0).toDouble();
    lon = (json['lon'] ?? 0).toDouble();
    speed = double.parse((json['speed'] ?? 0.0).toString());
    course = double.parse((json['course'] ?? 0.0).toString());
    heading = json['heading'];
    destination = json['destination'];
    lastPositionEpoch = json['last_position_epoch'];
    lastPositionUTC = DateTime.parse(json['last_position_UTC'].toString());
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['lat'] = lat;
    data['lon'] = lon;
    data['speed'] = speed;
    data['course'] = course;
    data['heading'] = heading;
    data['destination'] = destination;
    data['last_position_epoch'] = lastPositionEpoch;
    data['last_position_UTC'] = lastPositionUTC;
    return data;
  }
}

class Meta {
  double? duration;
  String? endpoint;
  bool? success;

  Meta({this.duration, this.endpoint, this.success});

  Meta.fromJson(Map<String, dynamic> json) {
    duration = json['duration'];
    endpoint = json['endpoint'];
    success = json['success'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['duration'] = duration;
    data['endpoint'] = endpoint;
    data['success'] = success;
    return data;
  }
}
