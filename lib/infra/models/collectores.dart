class CollectorsModel {
  final int? id;
  final DateTime? createdAt;
  final int? available;
  final String? collectorUuid;
  final String? name;

  CollectorsModel(
      {this.id, this.createdAt, this.available, this.collectorUuid, this.name});

  factory CollectorsModel.fromJson(Map<String, dynamic> json) {
    return CollectorsModel(
        id: json['id'] ?? 0,
        createdAt: DateTime.parse(json['createdAt']),
        available: json['available'] ?? 0,
        collectorUuid: json['collectorUuid'],
        name: json['name']);
  }

  Map <String, dynamic> toJson ()=>{
    'id': id,
  'createdAt': createdAt?.toIso8601String(), // Converte DateTime para string
  'available': available,
  'collectorUuid': collectorUuid,
  'name': name,
  };
}
