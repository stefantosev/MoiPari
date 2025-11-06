

import 'package:json_annotation/json_annotation.dart';

part 'expense.g.dart';

@JsonSerializable()
class Expense{
  late final double amount;
  late final String description;
  late final DateTime? date;
  late final String? paymentMethod;

  Expense({required this.amount, required this.description, this.date, this.paymentMethod});


  factory Expense.fromJson(Map<String, dynamic> json) => _$ExpenseFromJson(json);

  Map<String, dynamic> toJson() => _$ExpenseToJson(this);

}