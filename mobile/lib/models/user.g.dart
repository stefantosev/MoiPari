// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

User _$UserFromJson(Map<String, dynamic> json) => User(
  json['email'] as String,
  json['password'] as String,
  json['name'] as String,
  json['currency'] as String,
  DateTime.parse(json['createdAt'] as String),
);

Map<String, dynamic> _$UserToJson(User instance) => <String, dynamic>{
  'email': instance.email,
  'password': instance.password,
  'name': instance.name,
  'currency': instance.currency,
  'createdAt': instance.createdAt.toIso8601String(),
};
