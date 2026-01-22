class VesselDataModel {
  Data? data;
  Meta? meta;

  VesselDataModel({this.data, this.meta});

  VesselDataModel.fromJson(Map<String, dynamic> json) {
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
  String? nameAis;
  String? mmsi;
  String? imo;
  // Null? eni;
  String? countryIso;
  String? countryName;
  String? callsign;
  String? type;
  String? typeSpecific;
  int? grossTonnage;
  int? deadweight;
  String? teu;
  Null? liquidGas;
  double? length;
  double? breadth;
  double? draughtAvg;
  double? draughtMax;
  double? speedAvg;
  int? speedMax;
  String? yearBuilt;
  bool? isNavaid;
  String? homePort;

  Data(
      {this.uuid,
        this.name,
        this.nameAis,
        this.mmsi,
        this.imo,
        // this.eni,
        this.countryIso,
        this.countryName,
        this.callsign,
        this.type,
        this.typeSpecific,
        this.grossTonnage,
        this.deadweight,
        this.teu,
        this.liquidGas,
        this.length,
        this.breadth,
        this.draughtAvg,
        this.draughtMax,
        this.speedAvg,
        this.speedMax,
        this.yearBuilt,
        this.isNavaid,
        this.homePort});

  Data.fromJson(Map<String, dynamic> json) {
    uuid = json['uuid'];
    name = json['name'];
    nameAis = json['name_ais'];
    mmsi = json['mmsi'];
    imo = json['imo'];
    // eni = json['eni'];
    countryIso = json['country_iso'];
    countryName = json['country_name'];
    callsign = json['callsign'];
    type = json['type'];
    typeSpecific = json['type_specific'];
    grossTonnage = json['gross_tonnage'];
    deadweight = json['deadweight'];
    teu = json['teu'];
    liquidGas = json['liquid_gas'];
    length = double.parse(json['length'].toString());
    breadth = double.parse(json['breadth'].toString());
    draughtAvg = json['draught_avg'];
    draughtMax = json['draught_max'];
    speedAvg = json['speed_avg'];
    speedMax = json['speed_max'];
    yearBuilt = json['year_built'];
    isNavaid = json['is_navaid'];
    homePort = json['home_port'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['uuid'] = uuid;
    data['name'] = name;
    data['name_ais'] = nameAis;
    data['mmsi'] = mmsi;
    data['imo'] = imo;
    // data['eni'] = eni;
    data['country_iso'] = countryIso;
    data['country_name'] = countryName;
    data['callsign'] = callsign;
    data['type'] = type;
    data['type_specific'] = typeSpecific;
    data['gross_tonnage'] = grossTonnage;
    data['deadweight'] = deadweight;
    data['teu'] = teu;
    data['liquid_gas'] = liquidGas;
    data['length'] = length;
    data['breadth'] = breadth;
    data['draught_avg'] = draughtAvg;
    data['draught_max'] = draughtMax;
    data['speed_avg'] = speedAvg;
    data['speed_max'] = speedMax;
    data['year_built'] = yearBuilt;
    data['is_navaid'] = isNavaid;
    data['home_port'] = homePort;
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
