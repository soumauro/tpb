import 'package:cobradortpb/infra/models/locationsuser.dart';


class BusModel {
  int? id;
  DateTime? createdAt;
  int? available;
  int? direction;
  String? busUuid;
  String? collectorUid;
  String? registration;
  int? activated;
  List<LocationModel>? location; // Alterado para lista de LocationModel
  String? rotaUuid;
  List<LocationModel>? paragem; // Alterado para lista de LocationModel

  BusModel({
    this.id,
    this.createdAt,
    this.available,
    this.direction,
    this.busUuid,
    this.collectorUid,
    this.registration,
    this.activated,
    this.location,
    this.rotaUuid,
    this.paragem
  });

  // Método para converter JSON em um objeto BusModel
  factory BusModel.fromJson(Map<String, dynamic> json) {
    return BusModel(
      id: json['id'],
      createdAt: DateTime.tryParse(json['createdAt'] ?? ''),
      available: json['available'],
      direction: json['direction'],
      busUuid: json['busUuid'],
      collectorUid: json['collectorUid'],
      registration: json['registration'],
      activated: json['activated'],
      location: (json['location'] as List<dynamic>?)
          ?.map((loc) => LocationModel.fromJson(loc))
          .toList(), // Mapeia a lista de localização
      rotaUuid: json['rotaUuid'],
      paragem: (json['paragem'] as List<dynamic>?)
          ?.map((loc) => LocationModel.fromJson(loc))
          .toList(), // Mapeia a lista de localização
      
    );
  }

  // Método para converter um objeto BusModel em JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'createdAt': createdAt?.toIso8601String(),
      'available': available,
      'direction': direction,
      'busUuid': busUuid,
      'collectorUid': collectorUid,
      'registration': registration,
      'activated': activated,
      'location': location?.map((loc) => loc.toJson()).toList(), // Converte a lista de LocationModel para JSON
      'rotaUuid': rotaUuid,
      'paragem': paragem?.map((loc) => loc.toJson()).toList(), // Converte a lista de LocationModel para JSON
    };
  }
}
