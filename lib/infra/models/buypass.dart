class BuyPass {
  int? id;
  int available;
  DateTime createdAt;
  String uuid;
  String userUuid;
  DateTime endAt;
  int passType;
  int trajectory;
  double amount;
  String passName;

  BuyPass({
    this.id,
    required this.available,
    required this.createdAt,
    required this.uuid,
    required this.userUuid,
    required this.endAt,
    required this.passType,
    required this.trajectory,
    required this.amount,
    required this.passName,
  });

  // Converte de Map (usado pelo banco de dados) para um objeto Dart
  factory BuyPass.fromMap(Map<String, dynamic> map) {
    return BuyPass(
      id: map['id'],
      available: map['available'],
      createdAt: DateTime.parse(map['createdAt']),
      uuid: map['uuid'],
      userUuid: map['userUuid'],
      endAt: DateTime.parse(map['endAt']),
      passType: map['passType'],
      trajectory: map['trajectory'],
      amount: double.parse(map['amount'].toString()),
      passName: map['passName'],
    );
  }

  // Converte um objeto Dart para Map (usado para enviar dados ao banco)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'available': available,
      'createdAt': createdAt.toIso8601String(),
      'uuid': uuid,
      'userUuid': userUuid,
      'endAt': endAt.toIso8601String(),
      'passType': passType,
      'trajectory': trajectory,
      'amount': amount,
      'passName': passName,
    };
  }
}
