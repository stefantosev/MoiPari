import 'package:json_annotation/json_annotation.dart';


part 'category.g.dart';

@JsonSerializable()
class Category{
  late int id;
  late final String name, icon, color;
  late int userId;
  late List<int> expenseIds;


  Category(this.id, this.name, this.icon, this.color, this.userId, this.expenseIds);

  factory Category.fromJson(Map<String, dynamic> json) => _$CategoryFromJson(json);

  Map<String, dynamic> toJson() => _$CategoryToJson(this);
}