import 'package:json_annotation/json_annotation.dart';

part 'budget.g.dart';

@JsonSerializable()
class Budget{
  late int id, month, year;
  late double monthlyLimit;

  Budget(this.id, this.month, this.year, this.monthlyLimit);

  factory Budget.fromJson(Map<String, dynamic> json) => _$BudgetFromJson(json);

  Map<String, dynamic> toJson() => _$BudgetToJson(this);
}