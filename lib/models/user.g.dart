// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

User _$UserFromJson(Map<String, dynamic> json) => User(
      id: json['user_id'] as String,
      username: json['username'] as String,
      role: $enumDecode(_$UserRoleEnumMap, json['role']),
      email: json['email'] as String?,
      mobile: json['mobile'] as String?,
      loginId: json['login_id'] as String?,
      token: json['access_token'] as String?,
      tokenType: json['token_type'] as String?,
      expiresIn: (json['expires_in'] as num?)?.toInt(),
    );

Map<String, dynamic> _$UserToJson(User instance) => <String, dynamic>{
      'user_id': instance.id,
      'username': instance.username,
      'role': _$UserRoleEnumMap[instance.role]!,
      'email': instance.email,
      'mobile': instance.mobile,
      'login_id': instance.loginId,
      'access_token': instance.token,
      'token_type': instance.tokenType,
      'expires_in': instance.expiresIn,
    };

const _$UserRoleEnumMap = {
  UserRole.admin: 'admin',
  UserRole.surveyor: 'surveyor',
};
