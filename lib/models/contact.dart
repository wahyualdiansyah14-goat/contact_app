class Contact {
  int? id;
  String name;
  String phone;

  Contact({this.id, required this.name, required this.phone});

  // Contact -> Map (untuk disimpan ke SQLite)
  Map<String, dynamic> toMap() {
    return {'id': id, 'name': name, 'phone': phone};
  }

  // Map -> Contact (untuk dibaca dari SQLite)
  factory Contact.fromMap(Map<String, dynamic> map) {
    return Contact(
      id: map['id'] as int?,
      name: map['name'] as String,
      phone: map['phone'] as String,
    );
  }
}
