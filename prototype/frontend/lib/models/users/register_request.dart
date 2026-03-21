class RegisterRequest {
  final String email;
  final String password;
  final String name;
  final String lastName;
  final bool hasAcceptedTerms;
  final DateTime timeTermsAccepted;

  RegisterRequest({
    required this.email,
    required this.password,
    required this.name,
    required this.lastName,
    required this.hasAcceptedTerms,
    required this.timeTermsAccepted,
  });

  Map<String, dynamic> toJson() => {
    'email': email,
    'password': password,
    'name': name,
    'last_name': lastName,
    'has_accepted_terms': hasAcceptedTerms,
    'time_terms_accepted': timeTermsAccepted.toUtc().toIso8601String(),
  };
}
