import 'package:flutter_test/flutter_test.dart';
import 'package:fitsy/features/closet/data/models/cloth_model.dart';

void main() {
  group('ClothModel', () {
    test('toFirestore should return correct map', () {
      final model = ClothModel(
        id: 'test-id',
        imageUrl: 'https://example.com/image.jpg',
        category: '상의',
        subcategory: '반팔티',
        color: ['검정', '흰색'],
        season: ['여름'],
        tags: ['캐주얼'],
        createdAt: DateTime(2026, 3, 2),
      );

      final map = model.toFirestore();
      expect(map['imageUrl'], 'https://example.com/image.jpg');
      expect(map['category'], '상의');
      expect(map['subcategory'], '반팔티');
      expect(map['color'], ['검정', '흰색']);
      expect(map['season'], ['여름']);
      expect(map['tags'], ['캐주얼']);
      expect(map['isActive'], true);
      expect(map.containsKey('cutoutUrl'), false);
    });

    test('toFirestore should include cutoutUrl when present', () {
      final model = ClothModel(
        id: 'test-id',
        imageUrl: 'https://example.com/image.jpg',
        cutoutUrl: 'https://example.com/cutout.png',
        category: '하의',
        subcategory: '청바지',
        color: ['파랑'],
        season: ['봄', '가을'],
        tags: ['데일리'],
        createdAt: DateTime(2026, 3, 2),
      );

      final map = model.toFirestore();
      expect(map['cutoutUrl'], 'https://example.com/cutout.png');
    });

    test('ClothModel should be equal to Cloth with same props', () {
      final model1 = ClothModel(
        id: 'id',
        imageUrl: 'url',
        category: '상의',
        subcategory: '티셔츠',
        color: ['흰색'],
        season: ['여름'],
        tags: [],
        createdAt: DateTime(2026, 1, 1),
      );
      final model2 = ClothModel(
        id: 'id',
        imageUrl: 'url',
        category: '상의',
        subcategory: '티셔츠',
        color: ['흰색'],
        season: ['여름'],
        tags: [],
        createdAt: DateTime(2026, 1, 1),
      );
      expect(model1, equals(model2));
    });
  });
}
