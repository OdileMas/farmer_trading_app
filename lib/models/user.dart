class User {
  final int id;
  final String name;
  final String role;

  User({
    required this.id,
    required this.name,
    required this.role,
  });

  // Create User from a map (e.g. from SQLite)
  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'] is int ? map['id'] : int.tryParse(map['id'].toString()) ?? 0,
      name: map['name'] as String,
      role: map['role'] as String,
    );
  }

  // Convert User to a map (e.g. for SQLite)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'role': role,
    };
  }

  // Optional: JSON serialization for APIs
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      name: json['name'] as String,
      role: json['role'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'role': role,
    };
  }

  @override
  String toString() {
    return 'User(id: $id, name: $name, role: $role)';
  }
}
