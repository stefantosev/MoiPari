import 'package:json_annotation/json_annotation.dart';

@JsonSerializable()
class Budget{
  late int id, month, year;
  late double monthlyLimit;

  Budget(this.id, this.month, this.year, this.monthlyLimit);

  // factory Budget.fromJson(Map<String, dynamic> json) => _$BudgetFromJson(json);
}