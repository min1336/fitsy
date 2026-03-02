import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:fitsy/core/error/exceptions.dart';
import 'package:fitsy/features/closet/data/models/cloth_model.dart';

abstract class ClosetRemoteDataSource {
  Future<ClothModel> addCloth({required String imagePath, required String userId});
  Future<List<ClothModel>> getClothes({required String userId, String? category});
  Future<ClothModel> updateCloth({
    required String userId,
    required String clothId,
    String? category,
    String? subcategory,
    List<String>? color,
    List<String>? season,
    List<String>? tags,
    bool? isActive,
  });
}

class ClosetRemoteDataSourceImpl implements ClosetRemoteDataSource {
  final FirebaseFirestore firestore;
  final FirebaseStorage storage;

  ClosetRemoteDataSourceImpl({required this.firestore, required this.storage});

  @override
  Future<ClothModel> addCloth({required String imagePath, required String userId}) async {
    try {
      final clothRef = firestore.collection('users').doc(userId).collection('clothes').doc();
      final storageRef = storage.ref('users/$userId/clothes/${clothRef.id}/original.jpg');
      await storageRef.putFile(File(imagePath));
      final imageUrl = await storageRef.getDownloadURL();

      await clothRef.set({
        'imageUrl': imageUrl,
        'category': '미분류',
        'subcategory': '',
        'color': <String>[],
        'season': <String>[],
        'tags': <String>[],
        'createdAt': FieldValue.serverTimestamp(),
        'isActive': true,
      });

      final doc = await clothRef.get();
      return ClothModel.fromFirestore(doc);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<List<ClothModel>> getClothes({required String userId, String? category}) async {
    try {
      Query query = firestore
          .collection('users')
          .doc(userId)
          .collection('clothes')
          .where('isActive', isEqualTo: true);
      if (category != null) {
        query = query.where('category', isEqualTo: category);
      }
      query = query.orderBy('createdAt', descending: true);
      final snapshot = await query.get();
      return snapshot.docs.map((doc) => ClothModel.fromFirestore(doc)).toList();
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<ClothModel> updateCloth({
    required String userId,
    required String clothId,
    String? category,
    String? subcategory,
    List<String>? color,
    List<String>? season,
    List<String>? tags,
    bool? isActive,
  }) async {
    try {
      final docRef = firestore
          .collection('users')
          .doc(userId)
          .collection('clothes')
          .doc(clothId);
      final updates = <String, dynamic>{};
      if (category != null) updates['category'] = category;
      if (subcategory != null) updates['subcategory'] = subcategory;
      if (color != null) updates['color'] = color;
      if (season != null) updates['season'] = season;
      if (tags != null) updates['tags'] = tags;
      if (isActive != null) updates['isActive'] = isActive;
      await docRef.update(updates);
      final doc = await docRef.get();
      return ClothModel.fromFirestore(doc);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
}
