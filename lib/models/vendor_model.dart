import 'package:flutter/material.dart';

/// A local wedding shop / vendor tied to a specific governorate.
class Vendor {
  final String id;
  final String name;
  final String category;
  final IconData categoryIcon;
  final String governorate;
  final String address;
  final double rating;
  final String phone;
  final String imagePath;

  const Vendor({
    required this.id,
    required this.name,
    required this.category,
    required this.categoryIcon,
    required this.governorate,
    required this.address,
    required this.rating,
    required this.phone,
    required this.imagePath,
  });
}
