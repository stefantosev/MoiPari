import 'package:flutter/material.dart';

class IconUtils {
  static final Map<String, IconData> stringToIcon = {
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

  static final Map<IconData, String> iconToString = {
    Icons.shopping_cart: 'shopping_cart',
    Icons.restaurant: 'restaurant',
    Icons.directions_car: 'directions_car',
    Icons.local_gas_station: 'local_gas_station',
    Icons.movie: 'movie',
    Icons.sports_esports: 'sports_esports',
    Icons.fitness_center: 'fitness_center',
    Icons.local_hospital: 'local_hospital',
    Icons.school: 'school',
    Icons.home: 'home',
    Icons.work: 'work',
    Icons.flight: 'flight',
    Icons.card_giftcard: 'card_giftcard',
    Icons.attach_money: 'attach_money',
    Icons.savings: 'savings',
    Icons.pets: 'pets',
    Icons.wifi: 'wifi',
    Icons.phone: 'phone',
    Icons.lightbulb: 'lightbulb',
    Icons.music_note: 'music_note',
    Icons.category: 'category',
  };

  static IconData getIconFromString(String iconName) {
    return stringToIcon[iconName.toLowerCase()] ?? Icons.category;
  }

  static String getStringFromIcon(IconData icon) {
    return iconToString[icon] ?? 'category';
  }

  static final List<IconData> commonIcons = [
  Icons.shopping_cart,
  Icons.restaurant,
  Icons.directions_car,
  Icons.movie,
  Icons.fitness_center,
  Icons.home,
  Icons.work,
  Icons.flight,
  Icons.local_gas_station,
  Icons.school,
  Icons.phone,
  Icons.wifi,
  Icons.lightbulb,
  Icons.attach_money,
  Icons.savings,
  Icons.card_giftcard,
  Icons.pets,
  Icons.music_note,
  Icons.local_hospital,
  Icons.category,
];
}