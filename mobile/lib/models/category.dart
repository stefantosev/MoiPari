import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';

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
      return _getIconFromString(icon);
    } catch (e) {
      return Icons.category;
    }
  }

  IconData _getIconFromString(String iconName) {
    final iconMap = {
      'shopping_cart': Icons.shopping_cart,
      'restaurant': Icons.restaurant,
      'directions_car': Icons.directions_car,
      'local_gas_station': Icons.local_gas_station,
      'movie': Icons.movie,
      'sports_esports': Icons.sports_esports,
      'fitness_center': Icons.fitness_center,
      'local_hospital': Icons.local_hospital,
      'school': Icons.school,
      'home': Icons.home,
      'work': Icons.work,
      'flight': Icons.flight,
      'card_giftcard': Icons.card_giftcard,
      'attach_money': Icons.attach_money,
      'savings': Icons.savings,
      'pets': Icons.pets,
      'wifi': Icons.wifi,
      'phone': Icons.phone,
      'lightbulb': Icons.lightbulb,
      'music_note': Icons.music_note,
      'category': Icons.category,
    };

    return iconMap[iconName.toLowerCase()] ?? Icons.category;
  }

  String get iconString {
    return icon;
  }
}
