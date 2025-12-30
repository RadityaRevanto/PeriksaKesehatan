/// User entity
class User {
  final String id;
  final String name;
  final String email;
  final String? phone;
  final String? avatar;

  const User({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.avatar,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is User &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          email == other.email;

  @override
  int get hashCode => id.hashCode ^ name.hashCode ^ email.hashCode;
}

