// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'budget.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Budget _$BudgetFromJson(Map<String, dynamic> json) => Budget(
  (json['id'] as num).toInt(),
  (json['month'] as num).toInt(),
  (json['year'] as num).toInt(),
  (json['monthlyLimit'] as num).toDouble(),
);

Map<String, dynamic> _$BudgetToJson(Budget instance) => <String, dynamic>{
  'id': instance.id,
  'month': instance.month,
  'year': instance.year,
  'monthlyLimit': instance.monthlyLimit,
};
