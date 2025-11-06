// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'expense.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Expense _$ExpenseFromJson(Map<String, dynamic> json) => Expense(
  amount: (json['amount'] as num).toDouble(),
  description: json['description'] as String,
  date: json['date'] == null ? null : DateTime.parse(json['date'] as String),
  paymentMethod: json['paymentMethod'] as String?,
);

Map<String, dynamic> _$ExpenseToJson(Expense instance) => <String, dynamic>{
  'amount': instance.amount,
  'description': instance.description,
  'date': instance.date?.toIso8601String(),
  'paymentMethod': instance.paymentMethod,
};
