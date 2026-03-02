import 'package:equatable/equatable.dart';

class Outfit extends Equatable {
  final String id;
  final List<String> clothIds;
  final String? generatedImageUrl;
  final bool? liked;
  final String prompt;
  final DateTime createdAt;

  const Outfit({
    required this.id,
    required this.clothIds,
    this.generatedImageUrl,
    this.liked,
    required this.prompt,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, clothIds, generatedImageUrl, liked, prompt, createdAt];
}
