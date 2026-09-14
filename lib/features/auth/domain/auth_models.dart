class LoginResponse {
  const LoginResponse(this.accessToken);
  final String accessToken;
  factory LoginResponse.fromJson(Map<String, dynamic> json) =>
      LoginResponse(json['access_token'] as String);
}
