import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fitsy/features/outfit/data/models/outfit_model.dart';
import 'package:flutter_test/flutter_test.dart';

// ignore: subtype_of_sealed_class
// Minimal DocumentSnapshot stub for testing fromFirestore
class _FakeDocumentSnapshot implements DocumentSnapshot<Map<String, dynamic>> {
  final String _id;
  final Map<String, dynamic> _data;

  _FakeDocumentSnapshot(this._id, this._data);

  @override
  String get id => _id;

  @override
  Map<String, dynamic>? data() => _data;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  final tCreatedAt = DateTime(2024, 1, 15, 10, 0, 0);

  final tOutfitModelFull = OutfitModel(
    id: 'outfit-1',
    clothIds: ['cloth-1', 'cloth-2'],
    generatedImageUrl: 'https://example.com/image.png',
    liked: true,
    prompt: 'casual summer look',
    createdAt: tCreatedAt,
  );

  final tOutfitModelMinimal = OutfitModel(
    id: 'outfit-2',
    clothIds: ['cloth-3'],
    prompt: 'winter coat',
    createdAt: tCreatedAt,
  );

  group('OutfitModel.toFirestore', () {
    test('returns correct map with all fields when non-null', () {
      final result = tOutfitModelFull.toFirestore();

      expect(result['clothIds'], ['cloth-1', 'cloth-2']);
      expect(result['generatedImageUrl'], 'https://example.com/image.png');
      expect(result['liked'], true);
      expect(result['prompt'], 'casual summer look');
      expect(result['createdAt'], isA<Timestamp>());
    });

    test('excludes generatedImageUrl and liked when null', () {
      final result = tOutfitModelMinimal.toFirestore();

      expect(result.containsKey('generatedImageUrl'), isFalse);
      expect(result.containsKey('liked'), isFalse);
      expect(result['clothIds'], ['cloth-3']);
      expect(result['prompt'], 'winter coat');
    });

    test('createdAt Timestamp round-trips correctly', () {
      final result = tOutfitModelFull.toFirestore();
      final ts = result['createdAt'] as Timestamp;
      expect(ts.toDate(), tCreatedAt);
    });
  });

  group('OutfitModel.fromFirestore', () {
    test('parses all fields correctly', () {
      final doc = _FakeDocumentSnapshot('outfit-1', {
        'clothIds': ['cloth-1', 'cloth-2'],
        'generatedImageUrl': 'https://example.com/image.png',
        'liked': true,
        'prompt': 'casual summer look',
        'createdAt': Timestamp.fromDate(tCreatedAt),
      });

      final model = OutfitModel.fromFirestore(doc);

      expect(model.id, 'outfit-1');
      expect(model.clothIds, ['cloth-1', 'cloth-2']);
      expect(model.generatedImageUrl, 'https://example.com/image.png');
      expect(model.liked, true);
      expect(model.prompt, 'casual summer look');
      expect(model.createdAt, tCreatedAt);
    });

    test('handles missing optional fields', () {
      final doc = _FakeDocumentSnapshot('outfit-2', {
        'clothIds': ['cloth-3'],
        'prompt': 'winter coat',
        'createdAt': Timestamp.fromDate(tCreatedAt),
      });

      final model = OutfitModel.fromFirestore(doc);

      expect(model.generatedImageUrl, isNull);
      expect(model.liked, isNull);
    });

    test('handles missing clothIds and prompt gracefully', () {
      final doc = _FakeDocumentSnapshot('outfit-3', {
        'createdAt': Timestamp.fromDate(tCreatedAt),
      });

      final model = OutfitModel.fromFirestore(doc);

      expect(model.clothIds, isEmpty);
      expect(model.prompt, '');
    });
  });

  group('OutfitModel equality', () {
    test('two models with same data are equal', () {
      final a = OutfitModel(
        id: 'outfit-1',
        clothIds: ['cloth-1', 'cloth-2'],
        generatedImageUrl: 'https://example.com/image.png',
        liked: true,
        prompt: 'casual summer look',
        createdAt: tCreatedAt,
      );
      final b = OutfitModel(
        id: 'outfit-1',
        clothIds: ['cloth-1', 'cloth-2'],
        generatedImageUrl: 'https://example.com/image.png',
        liked: true,
        prompt: 'casual summer look',
        createdAt: tCreatedAt,
      );

      expect(a, equals(b));
    });

    test('models with different ids are not equal', () {
      final a = OutfitModel(
        id: 'outfit-1',
        clothIds: [],
        prompt: 'test',
        createdAt: tCreatedAt,
      );
      final b = OutfitModel(
        id: 'outfit-2',
        clothIds: [],
        prompt: 'test',
        createdAt: tCreatedAt,
      );

      expect(a, isNot(equals(b)));
    });
  });
}
