class PassInfo {
  final int? id;
  final DateTime? createdAt;
  final String? uuid;
  final String? name;
  final String? userUuid;
  final String? documentType;
  final String? documentNumber;
  final String? photoUrl;
  final DateTime? birthday; 
  final int? status;

  PassInfo({
    this.id,
    this.createdAt,
    this.uuid,
    this.name,
    this.userUuid,
    this.documentType,
    this.documentNumber,
    this.photoUrl,
    this.birthday,
    this.status,
  });

  // Método para converter um JSON em um objeto PassInfo
  factory PassInfo.fromJson(Map<String, dynamic> json) {
    return PassInfo(
      id: json['id'] as int?,
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      uuid: json['uuid'] as String?,
      name: json['name'] as String?,
      userUuid: json['userUuid'] as String?,
      documentType: json['documentType'] as String?,
      documentNumber: json['documentNumber'] as String?,
      photoUrl: json['photoUrl'] as String?,
      birthday: json['birthday'] != null ? DateTime.parse(json['birthday']) : null,
      status: json['status'] as int?,
    );
  }

  // Método para converter um objeto PassInfo em um JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'createdAt': createdAt?.toIso8601String(),
      'uuid': uuid,
      'name': name,
      'userUuid': userUuid,
      'documentType': documentType,
      'documentNumber': documentNumber,
      'photoUrl': photoUrl,
      'birthday': birthday?.toIso8601String(),
      'status': status,
    };
  }
}
