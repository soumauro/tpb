class PassPrice {
  final int id;
  final DateTime? createdAt;
  final int passType;
  final int trajectory;
  final String? name;  // Pode ser nulo
  final double? price; // Pode ser nulo

  PassPrice({
    required this.id,
    this.createdAt,
    required this.passType,
    required this.trajectory,
    this.name,           // Permite valor nulo
    this.price,          // Permite valor nulo
  });

  // Factory method para criar um objeto PassPrice a partir de um Map (como um JSON)
  factory PassPrice.fromJson(Map<String, dynamic> json) {
    return PassPrice(
      id: json['id'] as int,
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      passType: json['passType'] as int,
      trajectory: json['trajectory'] as int,
      name: json['name'] as String?,  // Pode ser null
      price: json['price'] != null ? double.tryParse(json['price'].toString()) : null,
    );
  }

  // Método para converter o objeto PassPrice em um Map (para enviar como JSON, por exemplo)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'createdAt': createdAt?.toIso8601String(),
      'passType': passType,
      'trajectory': trajectory,
      'name': name,  // Pode ser null
      'price': price,
    };
  }
}
