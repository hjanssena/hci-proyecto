class User {
  final String? id;
  final String email;
  final String name;
  final String lastName;
  final String? logoUrl;
  final String roleLevel;
  final bool hasVerifiedEmail;

  User({
    this.id,
    required this.email,
    required this.name,
    required this.lastName,
    this.logoUrl,
    required this.roleLevel,
    required this.hasVerifiedEmail,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['user_id']?.toString(),
      email: json['email'] ?? '',
      name: json['name'] ?? '',
      lastName: json['last_name'] ?? '',
      logoUrl: json['logo_url'],
      roleLevel: json['role_level'] ?? 'usuario_publico',
      hasVerifiedEmail: json['has_verified_email'] ?? false,
    );
  }

  factory User.fromJwt(Map<String, dynamic> payload) {
    return User(
      id: payload['user_id']?.toString(),
      email: payload['email'] ?? '',
      name: payload['name'] ?? '',
      lastName: payload['last_name'] ?? '',
      roleLevel: payload['role_level'] ?? 'usuario_publico',
      hasVerifiedEmail: payload['has_verified_email'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'name': name,
      'last_name': lastName,
      'logo_url': logoUrl,
    };
  }

  User copyWith({
    String? id,
    String? email,
    String? name,
    String? lastName,
    String? logoUrl,
    String? roleLevel,
    bool? hasVerifiedEmail,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      lastName: lastName ?? this.lastName,
      logoUrl: logoUrl ?? this.logoUrl,
      roleLevel: roleLevel ?? this.roleLevel,
      hasVerifiedEmail: hasVerifiedEmail ?? this.hasVerifiedEmail,
    );
  }
}
