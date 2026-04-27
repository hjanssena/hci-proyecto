class Professor {
  final int id;
  final String name;
  final String email;

  Professor({
    required this.id,
    required this.name,
    required this.email,
  });

  factory Professor.fromJson(Map<String, dynamic> json) {
    return Professor(
      id: json['id'],
      name: json['name'],
      email: json['email'],
    );
  }
}
