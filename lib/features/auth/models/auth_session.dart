class AuthSession {
  const AuthSession({
    required this.token,
    this.name,
    this.email,
  });

  final String token;
  final String? name;
  final String? email;

  factory AuthSession.fromJson(Map<String, dynamic> json) {
    final token = _readString(
      json,
      const ['token', 'access_token', 'bearer_token'],
    );

    return AuthSession(
      token: token,
      name: _readString(json, const ['name', 'user_name', 'full_name']),
      email: _readString(json, const ['email', 'user_email']),
    );
  }

  static String _readString(Map<String, dynamic> json, List<String> keys) {
    for (final key in keys) {
      final value = json[key];
      if (value != null && value.toString().trim().isNotEmpty) {
        return value.toString();
      }
    }
    return '';
  }
}
