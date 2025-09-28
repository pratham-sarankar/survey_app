import 'package:json_annotation/json_annotation.dart';

part 'user.g.dart';

enum UserRole { admin, surveyor }

@JsonSerializable()
class User {
  @JsonKey(name: 'user_id')
  final String id;
  final String username;
  final UserRole role;
  @JsonKey(name: 'access_token')
  final String? token;
  @JsonKey(name: 'token_type')
  final String? tokenType;
  @JsonKey(name: 'expires_in')
  final int? expiresIn;

  const User({
    required this.id,
    required this.username,
    required this.role,
    this.token,
    this.tokenType,
    this.expiresIn,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    // Convert role string to enum
    final roleStr = json['role'] as String;
    final role = UserRole.values.firstWhere(
      (e) => e.toString().split('.').last == roleStr,
      orElse: () => UserRole.surveyor,
    );

    // Convert user_id to string if it's an integer
    final userId = json['user_id']?.toString() ?? '';

    return _$UserFromJson({
      ...json,
      'user_id': userId,
      'role': role.toString().split('.').last,
    });
  }

  Map<String, dynamic> toJson() => _$UserToJson(this);

  User copyWith({
    String? id,
    String? username,
    UserRole? role,
    String? token,
    String? tokenType,
    int? expiresIn,
  }) {
    return User(
      id: id ?? this.id,
      username: username ?? this.username,
      role: role ?? this.role,
      token: token ?? this.token,
      tokenType: tokenType ?? this.tokenType,
      expiresIn: expiresIn ?? this.expiresIn,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is User &&
        other.id == id &&
        other.username == username &&
        other.role == role &&
        other.token == token &&
        other.tokenType == tokenType &&
        other.expiresIn == expiresIn;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        username.hashCode ^
        role.hashCode ^
        token.hashCode ^
        tokenType.hashCode ^
        expiresIn.hashCode;
  }

  @override
  String toString() {
    return 'User(id: $id, username: $username, role: $role, token: $token, tokenType: $tokenType, expiresIn: $expiresIn)';
  }
}
