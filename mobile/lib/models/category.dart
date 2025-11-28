import 'package:flutter/material.dart';
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
    switch (iconName.toLowerCase()) {
      case 'restaurant': return Icons.restaurant;
      case 'directions_car': return Icons.directions_car;
      case 'movie': return Icons.movie;
      case 'bolt': return Icons.bolt;
      case 'shopping_bag': return Icons.shopping_bag;
      case 'favorite': return Icons.favorite;
      case 'flight': return Icons.flight;
      case 'home': return Icons.home;
      case 'local_cafe': return Icons.local_cafe;
      case 'fitness_center': return Icons.fitness_center;
      case 'school': return Icons.school;
      case 'local_gas_station': return Icons.local_gas_station;
      case 'wifi': return Icons.wifi;
      case 'phone_iphone': return Icons.phone_iphone;
      case 'attach_money': return Icons.attach_money;
      case 'euro_symbol': return Icons.euro_symbol;
      default: return Icons.category;
    }
  }
  
}

