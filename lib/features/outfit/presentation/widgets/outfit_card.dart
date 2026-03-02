import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:fitsy/features/outfit/domain/entities/outfit.dart';

class OutfitCard extends StatelessWidget {
  final Outfit outfit;
  const OutfitCard({super.key, required this.outfit});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              outfit.prompt,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              '${outfit.clothIds.length}개 아이템',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            if (outfit.generatedImageUrl != null) ...[
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: CachedNetworkImage(
                  imageUrl: outfit.generatedImageUrl!,
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  placeholder: (_, url) => Container(
                    height: 200,
                    color: colorScheme.surfaceContainerHighest,
                    child: const Center(
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                ),
              ),
            ],
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (outfit.generatedImageUrl == null)
                  FilledButton.icon(
                    onPressed: () {
                      // TODO: GenerateImage event
                    },
                    icon: const Icon(Icons.image, size: 18),
                    label: const Text('이미지 생성'),
                  ),
                const SizedBox(width: 8),
                IconButton(
                  icon: Icon(
                    outfit.liked == true ? Icons.favorite : Icons.favorite_border,
                    color: outfit.liked == true ? Colors.red : null,
                  ),
                  onPressed: () {
                    // TODO: like/dislike
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
