class PassagemModel {
  final int? id;
  final DateTime? createdAt;
  final int? available;
  final String? uuid;
  final String? startAt;
  final String? endAt;
  final String? rotaUuid;
  final double? price;
  final String? registration;
  final String? collectorUid;

  PassagemModel(
      {this.id,
      this.createdAt,
      this.available,
      this.uuid,
      this.startAt,
      this.endAt,
      this.rotaUuid,
      this.price,
      this.registration,
      this.collectorUid});

  factory PassagemModel.fromJson(Map<String, dynamic> json) {
    return PassagemModel(
        id: json['id'] ?? 0,
        createdAt: DateTime.parse(json['createdAt']),
        available: json['available'] ?? 0,
        uuid: json['uuid'],
        startAt: json['startAt'],
        endAt: json['endAt'],
        registration: json['registration'],
        rotaUuid: json['rotaUuid'],
        price: double.tryParse(json['price']),
        collectorUid: json['collectorUid']);
  }
}
