

// Classe para representar a localização
class LocationModel {
  final double x;
  final double y;

  LocationModel({required this.x, required this.y});

  // Método para converter JSON em um objeto LocationModel
  factory LocationModel.fromJson(Map<String, dynamic> json) {
    return LocationModel(
      x: json['x']?.toDouble() ?? 0.0,
      y: json['y']?.toDouble() ?? 0.0,
    );
  }

  // Método para converter um objeto LocationModel em JSON
  Map<String, dynamic> toJson() {
    return {
      'x': x,
      'y': y,
    };
  }
}

// Classe BusModel
class BusModel {
  int? id;
  DateTime? createdAt;
  int? available;
  int? direction;
  String? busUuid;
  String? collectorUid;
  String? registration;
  int? activated;
  List<LocationModel>? location; // Usando a classe LocationModel
  String? rotaUuid;

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
    };
  }
}
