class Supplier {
  final int? id;
  final String name;
  final String phone;

  Supplier({this.id, required this.name, required this.phone});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
    };
  }

  factory Supplier.fromMap(Map<String, dynamic> map) {
    return Supplier(
      id: map['id'],
      name: map['name'],
      phone: map['phone'],
    );
  }
}
