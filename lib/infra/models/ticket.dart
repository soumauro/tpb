class TicketModel {
  int id;
  DateTime createdAt;
  int available;
  String uuid;
  String startAt;
  String endAt;
  String busUuid;
  String userClientUuid;
  String scheduleUuid;
  String collectorUuid;
  double price;
  int collectorCheck;
  int fiscalCheck;
  int pessoas;

  TicketModel({
    required this.id,
    required this.createdAt,
    required this.available,
    required this.uuid,
    required this.startAt,
    required this.endAt,
    required this.busUuid,
    required this.userClientUuid,
    required this.collectorUuid,
    required this.price,
    required this.collectorCheck,
    required this.fiscalCheck,
    required this.pessoas,
    required this.scheduleUuid
  });

  // Método para converter de JSON para um objeto TicketModel
  factory TicketModel.fromJson(Map<String, dynamic> json) {
    return TicketModel(
      id: json['id'],
      createdAt: DateTime.parse(json['createdAt']),
      available: json['available'],
      uuid: json['uuid'],
      startAt: json['startAt'],
      endAt: json['endAt'],
      busUuid: json['busUuid'],
      userClientUuid: json['userclientUuid'],
      collectorUuid: json['collectorUuid'],
      price: double.parse(json['price'].toString()),
      collectorCheck: json['collectorCheck'],
      fiscalCheck: json['fiscalCheck'],
      pessoas: json['pessoas'],
      scheduleUuid: json['scheduleUuid'],
    );
  }

  // Método para converter de um objeto TicketModel para JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'createdAt': createdAt.toIso8601String(),
      'available': available,
      'uuid': uuid,
      'startAt': startAt,
      'endAt': endAt,
      'busUuid': busUuid,
      'userclientUuid': userClientUuid,
      'collectorUuid': collectorUuid,
      'price': price,
      'collectorCheck': collectorCheck,
      'fiscalCheck': fiscalCheck,
      'pessoas': pessoas,
      'scheduleUuid': scheduleUuid,
    };
  }
}
