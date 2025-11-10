// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'expense.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Expense _$ExpenseFromJson(Map<String, dynamic> json) => Expense(
  id: (json['id'] as num).toInt(),
  amount: (json['amount'] as num).toDouble(),
  description: json['description'] as String,
  date: json['date'] == null ? null : DateTime.parse(json['date'] as String),
  paymentMethod: json['paymentMethod'] as String?,
  categoryIds: (json['categoryIds'] as List<dynamic>)
      .map((e) => (e as num).toInt())
      .toList(),
)..userId = (json['userId'] as num).toInt();

Map<String, dynamic> _$ExpenseToJson(Expense instance) => <String, dynamic>{
  'id': instance.id,
  'amount': instance.amount,
  'description': instance.description,
  'date': instance.date?.toIso8601String(),
  'paymentMethod': instance.paymentMethod,
  'categoryIds': instance.categoryIds,
  'userId': instance.userId,
};
