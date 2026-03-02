import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:fitsy/core/error/exceptions.dart';
import 'package:fitsy/features/outfit/data/models/outfit_model.dart';

abstract class OutfitRemoteDataSource {
  Future<List<OutfitModel>> getRecommendations({required String userId});
  Future<OutfitModel> generateOutfitImage({
    required String userId,
    required String outfitId,
  });
}

class OutfitRemoteDataSourceImpl implements OutfitRemoteDataSource {
  final FirebaseFirestore firestore;
  final FirebaseFunctions functions;

  OutfitRemoteDataSourceImpl({
    required this.firestore,
    required this.functions,
  });

  @override
  Future<List<OutfitModel>> getRecommendations({required String userId}) async {
    try {
      final callable = functions.httpsCallable('getRecommendations');
      final result =
          await callable.call<Map<String, dynamic>>({'userId': userId});
      final outfitsData = result.data['outfits'] as List<dynamic>;

      return outfitsData.map((data) {
        final map = data as Map<String, dynamic>;
        return OutfitModel(
          id: map['id'] as String,
          clothIds: List<String>.from(map['clothIds'] ?? []),
          prompt: map['prompt'] as String? ?? '',
          createdAt: DateTime.now(),
        );
      }).toList();
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<OutfitModel> generateOutfitImage({
    required String userId,
    required String outfitId,
  }) async {
    try {
      final callable = functions.httpsCallable('generateOutfitImage');
      await callable.call<Map<String, dynamic>>({
        'userId': userId,
        'outfitId': outfitId,
      });

      final doc = await firestore
          .collection('users')
          .doc(userId)
          .collection('outfits')
          .doc(outfitId)
          .get();
      return OutfitModel.fromFirestore(doc);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
}
