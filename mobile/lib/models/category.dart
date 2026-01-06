import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:mobile/utils/icon_utils.dart';

part 'category.g.dart';

@JsonSerializable()
class Category {
  late int id;
  late final String name, icon, color;
  late int userId;
  late List<int> expenseIds;

  Category(
    this.id,
    this.name,
    this.icon,
    this.color,
    this.userId,
    this.expenseIds,
  );

  factory Category.fromJson(Map<String, dynamic> json) =>
      _$CategoryFromJson(json);
  Map<String, dynamic> toJson() => _$CategoryToJson(this);

  Color get colorValue {
    try {
      return Color(int.parse(color.replaceFirst('#', '0xFF')));
    } catch (e) {
      return Colors.deepPurpleAccent;
    }
  }

  IconData get iconData {
    try {
      return IconUtils.getIconFromString(icon);
    } catch (e) {
      return Icons.category;
    }
  }


}
