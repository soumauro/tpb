class RotaModel {
  int id;
  DateTime createdAt;
  int available;
  String uuid;
  String inicio;
  String finalRota; // 'final' é uma palavra reservada em Dart, por isso usei 'finalRota'
  String via;
  int total;
  int activated;

  // Construtor
  RotaModel({
    required this.id,
    required this.createdAt,
    required this.available,
    required this.uuid,
    required this.inicio,
    required this.finalRota,
    required this.via,
    required this.total,
    required this.activated,
  });

  // Método para criar uma instância de RotaModel a partir de um mapa (por exemplo, dados JSON)
  factory RotaModel.fromMap(Map<String, dynamic> map) {
    return RotaModel(
      id: map['id'] ?? 0,
      createdAt: DateTime.parse(map['createdAt']),
      available: map['available'] ?? 0,
      uuid: map['uuid'] ?? '',
      inicio: map['inicio'] ?? '',
      finalRota: map['final'] ?? '', // final é mapeado para finalRota
      via: map['via'] ?? '',
      total: map['total'] ?? 0,
      activated: map['activated'] ?? 0,
    );
  }

  // Método para converter a instância de RotaModel em um mapa (para ser usado em inserções, por exemplo)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'createdAt': createdAt.toIso8601String(),
      'available': available,
      'uuid': uuid,
      'inicio': inicio,
      'final': finalRota,
      'via': via,
      'total': total,
      'activated': activated,
    };
  }

  // Método para atualizar a rota (exemplo de lógica de atualização)
  void updateRota({
    String? newInicio,
    String? newFinalRota,
    String? newVia,
    int? newTotal,
    int? newActivated,
    int? newAvailable,
  }) {
    inicio = newInicio ?? inicio;
    finalRota = newFinalRota ?? finalRota;
    via = newVia ?? via;
    total = newTotal ?? total;
    activated = newActivated ?? activated;
    available = newAvailable ?? available;
  }

  // Método para exibir informações da rota (útil para debug)
  @override
  String toString() {
    return 'RotaModel(id: $id, inicio: $inicio, finalRota: $finalRota, via: $via, total: $total, activated: $activated, available: $available)';
  }
}
