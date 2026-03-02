import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:fitsy/features/closet/domain/entities/cloth.dart';

class ClothGridItem extends StatelessWidget {
  final Cloth cloth;
  const ClothGridItem({super.key, required this.cloth});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: CachedNetworkImage(
              imageUrl: cloth.imageUrl,
              fit: BoxFit.cover,
              width: double.infinity,
              placeholder: (_, url) => Container(
                color: colorScheme.surfaceContainerHighest,
                child: const Center(
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
              errorWidget: (_, url, error) => Container(
                color: colorScheme.surfaceContainerHighest,
                child: const Center(child: Icon(Icons.broken_image)),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  cloth.subcategory,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 4),
                Wrap(
                  spacing: 4,
                  children: cloth.color
                      .take(3)
                      .map(
                        (c) => Chip(
                          label: Text(c, style: const TextStyle(fontSize: 10)),
                          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          visualDensity: VisualDensity.compact,
                        ),
                      )
                      .toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
