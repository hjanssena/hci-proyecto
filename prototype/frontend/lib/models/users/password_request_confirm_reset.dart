class PasswordResetConfirmRequest {
  final String code;
  final String newPassword;

  PasswordResetConfirmRequest({required this.code, required this.newPassword});

  Map<String, dynamic> toJson() => {'code': code, 'new_password': newPassword};
}
