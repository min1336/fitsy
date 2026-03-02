import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fitsy/features/closet/domain/entities/cloth.dart';

class ClothModel extends Cloth {
  const ClothModel({
    required super.id,
    required super.imageUrl,
    super.cutoutUrl,
    required super.category,
    required super.subcategory,
    required super.color,
    required super.season,
    required super.tags,
    required super.createdAt,
    super.isActive,
  });

  factory ClothModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ClothModel(
      id: doc.id,
      imageUrl: data['imageUrl'] as String? ?? '',
      cutoutUrl: data['cutoutUrl'] as String?,
      category: data['category'] as String? ?? '미분류',
      subcategory: data['subcategory'] as String? ?? '',
      color: List<String>.from(data['color'] ?? []),
      season: List<String>.from(data['season'] ?? []),
      tags: List<String>.from(data['tags'] ?? []),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isActive: data['isActive'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'imageUrl': imageUrl,
      if (cutoutUrl != null) 'cutoutUrl': cutoutUrl,
      'category': category,
      'subcategory': subcategory,
      'color': color,
      'season': season,
      'tags': tags,
      'createdAt': Timestamp.fromDate(createdAt),
      'isActive': isActive,
    };
  }
}
