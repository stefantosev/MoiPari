

import 'package:json_annotation/json_annotation.dart';

part 'expense.g.dart';

@JsonSerializable()
class Expense{
  late final int id;
  late final double amount;
  late final String description;
  late final DateTime? date;
  late final String? paymentMethod;
  late final List<int> categoryIds;
  late final int userId;

  Expense({required this.id, required this.amount, required this.description, this.date, this.paymentMethod, required this.categoryIds});


  factory Expense.fromJson(Map<String, dynamic> json) => _$ExpenseFromJson(json);

  Map<String, dynamic> toJson() => _$ExpenseToJson(this);

}