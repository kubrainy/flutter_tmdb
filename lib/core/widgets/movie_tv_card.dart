import 'dart:ui';
import 'package:flutter/material.dart';
import '../../models/media_item.dart';

class MovieTvCard extends StatelessWidget {
  const MovieTvCard({super.key, required this.item});

  final MediaItem item;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: 330,
      height: 190,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.16),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isDark
                    ? [
                        Colors.white.withValues(alpha: 0.22),
                        Colors.white.withValues(alpha: 0.04),
                      ]
                    : [
                        Colors.white.withValues(alpha: 0.55),
                        Colors.white.withValues(alpha: 0.18),
                      ],
              ),
              border: Border.all(
                color: Colors.white.withValues(alpha: isDark ? 0.25 : 0.6),
                width: 1.2,
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: item.posterUrl != null
                      ? Image.network(
                          item.posterUrl!,
                          width: 120,
                          height: 162,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Container(
                            width: 120,
                            height: 162,
                            color: colorScheme.surfaceContainerHighest,
                            child: Icon(Icons.movie_outlined,
                                color: colorScheme.onSurfaceVariant),
                          ),
                        )
                      : Container(
                          width: 120,
                          height: 162,
                          color: colorScheme.surfaceContainerHighest,
                          child: Icon(Icons.movie_outlined,
                              color: colorScheme.onSurfaceVariant),
                        ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      item.title,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
