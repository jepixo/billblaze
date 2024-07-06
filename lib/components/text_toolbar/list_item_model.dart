import 'package:flutter/material.dart';

class ListItemModel {
  final String title;
  final Color color;
  final IconData icon;
  final VoidCallback onTap;
  final bool isTapped;

  ListItemModel({
    required this.onTap,
    required this.title,
    required this.color,
    required this.icon,
    required this.isTapped,
  });
}
