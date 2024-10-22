
class ClientUserMOdel {
  final int? id;
  final DateTime? createdAt;
  final int? available;
  final String? uuid;
  final String? name;
  final int? hasPass;

  ClientUserMOdel({this.id, this.createdAt, this.available, this.uuid, this.name,
      this.hasPass});

factory ClientUserMOdel.fromJson(Map<String, dynamic> json) {
    return ClientUserMOdel(
        id: json['id'] ?? 0,
        createdAt: DateTime.parse(json['createdAt']),
        available: json['available'] ?? 0,
        uuid: json['uuid'],
        name: json['name']);
  }

  Map <String, dynamic> toJson ()=>{
    'id': id,
  'createdAt': createdAt?.toIso8601String(), // Converte DateTime para string
  'available': available,
  'uuid': uuid,
  'name': name,
  };

}
