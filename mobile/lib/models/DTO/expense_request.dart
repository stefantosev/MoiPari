import 'package:json_annotation/json_annotation.dart';

part 'expense_request.g.dart';

@JsonSerializable()
class ExpenseRequest {
  final double amount;
  final String description;
  final DateTime? date;
  final String? paymentMethod;
  final List<int> categoryIds;

  ExpenseRequest({
    required this.amount,
    required this.description,
    this.date,
    this.paymentMethod,
    required this.categoryIds,
  });

  factory ExpenseRequest.fromJson(Map<String, dynamic> json) => _$ExpenseRequestFromJson(json);
  Map<String, dynamic> toJson() => _$ExpenseRequestToJson(this);
}