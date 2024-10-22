class Pass {
  int? id;
  int? available;
  DateTime? createdAt;
  String? name;
  String? userUuid;
  String? photoUrl;
  DateTime? lastUpdate;
  DateTime? endAt;
  int? passType;
  int? trajectory;
  String? passName;

  Pass({
    this.id,
    this.available,
    this.createdAt,
    this.name,
    this.userUuid,
    this.photoUrl,
    this.lastUpdate,
    this.endAt,
    this.passType,
    this.trajectory,
    this.passName,
  });

  // Função para converter de JSON para o modelo
  factory Pass.fromJson(Map<String, dynamic> json) {
    return Pass(
      id: json['id'] as int?,
      available: json['available'] as int?,
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      name: json['name'] as String?,
      userUuid: json['userUuid'] as String?,
      photoUrl: json['photoUrl'] as String?,
      lastUpdate: json['lastUpdate'] != null ? DateTime.parse(json['lastUpdate']) : null,
      endAt: json['endAt'] != null ? DateTime.parse(json['endAt']) : null,
      passType: json['passType'] as int?,
      trajectory: json['trajectory'] as int?,
      passName: json['passName'] as String?,
    );
  }

  // Função para converter o modelo para JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'available': available,
      'createdAt': createdAt?.toIso8601String(),
      'name': name,
      'userUuid': userUuid,
      'photoUrl': photoUrl,
      'lastUpdate': lastUpdate?.toIso8601String(),
      'endAt': endAt?.toIso8601String(),
      'passType': passType,
      'trajectory': trajectory,
      'passName': passName,
    };
  }
}
