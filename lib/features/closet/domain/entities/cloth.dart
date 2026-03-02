import 'package:equatable/equatable.dart';

class Cloth extends Equatable {
  final String id;
  final String imageUrl;
  final String? cutoutUrl;
  final String category;
  final String subcategory;
  final List<String> color;
  final List<String> season;
  final List<String> tags;
  final DateTime createdAt;
  final bool isActive;

  const Cloth({
    required this.id,
    required this.imageUrl,
    this.cutoutUrl,
    required this.category,
    required this.subcategory,
    required this.color,
    required this.season,
    required this.tags,
    required this.createdAt,
    this.isActive = true,
  });

  @override
  List<Object?> get props => [id, imageUrl, cutoutUrl, category, subcategory, color, season, tags, createdAt, isActive];
}
