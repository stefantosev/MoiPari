import 'package:json_annotation/json_annotation.dart';
import 'package:mobile/models/user.dart';

import 'expense.dart';

part 'category.g.dart';

@JsonSerializable()
class Category{
  late int id;
  late final String name, icon, color;

  // late final User user;
  // late final List<Expense> expenses;

  Category(this.id, this.name, this.icon, this.color);

  factory Category.fromJson(Map<String, dynamic> json) => _$CategoryFromJson(json);

  Map<String, dynamic> toJson() => _$CategoryToJson(this);
}