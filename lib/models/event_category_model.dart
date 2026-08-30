import 'package:flutter/material.dart';

class EventCategory {
  final String id;
  final String title;
  final String description;
  final String imagePath;
  final IconData icon;

  const EventCategory({
    required this.id,
    required this.title,
    required this.imagePath,
    required this.icon,
    this.description = '',
  });
}