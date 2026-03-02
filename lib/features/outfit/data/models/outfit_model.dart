import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fitsy/features/outfit/domain/entities/outfit.dart';

class OutfitModel extends Outfit {
  const OutfitModel({
    required super.id,
    required super.clothIds,
    super.generatedImageUrl,
    super.liked,
    required super.prompt,
    required super.createdAt,
  });

  factory OutfitModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return OutfitModel(
      id: doc.id,
      clothIds: List<String>.from(data['clothIds'] ?? []),
      generatedImageUrl: data['generatedImageUrl'] as String?,
      liked: data['liked'] as bool?,
      prompt: data['prompt'] as String? ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'clothIds': clothIds,
      if (generatedImageUrl != null) 'generatedImageUrl': generatedImageUrl,
      if (liked != null) 'liked': liked,
      'prompt': prompt,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
