// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'expense_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ExpenseRequest _$ExpenseRequestFromJson(Map<String, dynamic> json) =>
    ExpenseRequest(
      amount: (json['amount'] as num).toDouble(),
      description: json['description'] as String,
      date: json['date'] == null
          ? null
          : DateTime.parse(json['date'] as String),
      paymentMethod: json['paymentMethod'] as String?,
      categoryIds: (json['categoryIds'] as List<dynamic>)
          .map((e) => (e as num).toInt())
          .toList(),
    );

Map<String, dynamic> _$ExpenseRequestToJson(ExpenseRequest instance) =>
    <String, dynamic>{
      'amount': instance.amount,
      'description': instance.description,
      'date': instance.date?.toIso8601String(),
      'paymentMethod': instance.paymentMethod,
      'categoryIds': instance.categoryIds,
    };
