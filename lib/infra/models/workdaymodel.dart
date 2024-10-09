class WorkdayModel {
  final int id;
  final DateTime? createdAt;         
  final int available;               
  final String? collectorUuid;       // 'text'
  final String? busUuid;             // 'text'
  final double ? balance;              // 'decimal(10,0)' no banco de dados mapeado como double
  final int ? direction;               // 'int'
  final DateTime? mouthDay;          // 'date' no banco de dados mapeado como DateTime
  final int? collectorPosition;      // 'tinyint'
  final String? startedAt;           // 'time' no banco de dados, pode ser string ou Duration
  final String? scheduleUuid;        // 'varchar(250)'
  final String? endedAt;     
  late final int status;                  
  WorkdayModel({
    required this.id,
    this.createdAt,
    required this.available,
    this.collectorUuid,
    this.busUuid,
    this.balance,
     this.direction,
    this.mouthDay,
    this.collectorPosition,
    this.startedAt,
    this.scheduleUuid,
    this.endedAt,
    required this.status,
  });

  // Método para converter JSON em um modelo WorkdayModel
  factory WorkdayModel.fromJson(Map<String, dynamic> json) {
    return WorkdayModel(
      id: json['id'],
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      available: json['available'],
      collectorUuid: json['collectorUuid'],
      busUuid: json['busUuid'],
      balance: double.tryParse(json['balance']),
      direction: json['direction'],
      mouthDay: json['mouthDay'] != null ? DateTime.parse(json['mouthDay']) : null,
      collectorPosition: json['collectorPosition'],
      startedAt: json['startedAt'],
      scheduleUuid: json['scheduleUuid'],
      endedAt: json['endedAt'],
      status: json['status'],
    );
  }

  // Método para converter o modelo WorkdayModel em JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'createdAt': createdAt?.toIso8601String(),
      'available': available,
      'collectorUuid': collectorUuid,
      'busUuid': busUuid,
      'balance': balance,
      'direction': direction,
      'mouthDay': mouthDay?.toIso8601String(),
      'collectorPosition': collectorPosition,
      'startedAt': startedAt,
      'scheduleUuid': scheduleUuid,
      'endedAt': endedAt,
      'status': status,
    };
  }
}
