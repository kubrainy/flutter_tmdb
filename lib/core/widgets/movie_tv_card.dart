import 'dart:ui';
import 'package:flutter/material.dart';
import '../../models/media_item.dart';
import '../network/tmdb_service.dart';

class MovieTvCard extends StatelessWidget {
  const MovieTvCard({super.key, required this.item});

  final MediaItem item;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: 335,
      height: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.35),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(26),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(26),
              gradient: RadialGradient(
                center: const Alignment(-0.9, -0.9),
                radius: 1.3,
                colors: [
                  Colors.white.withValues(alpha: 0.26),
                  Colors.white.withValues(alpha: 0.03),
                ],
              ),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.4),
                width: 1.4,
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
                          width: 128,
                          height: 172,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Container(
                            width: 128,
                            height: 172,
                            color: colorScheme.surfaceContainerHighest,
                            child: Icon(Icons.movie_outlined,
                                color: colorScheme.onSurfaceVariant),
                          ),
                        )
                      : Container(
                          width: 128,
                          height: 172,
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

class MovieTvSection extends StatefulWidget {
  const MovieTvSection({
    super.key,
    required this.title,
    required this.mediaType,
  });

  final String title;
  final MediaType mediaType;

  @override
  State<MovieTvSection> createState() => _MovieTvSectionState();
}

class _MovieTvSectionState extends State<MovieTvSection> {
  final TmdbService _service = TmdbService();
  late Future<List<MediaItem>> _future;

  @override
  void initState() {
    super.initState();
    _future = widget.mediaType == MediaType.movie
        ? _service.discoverMovies()
        : _service.discoverTvShows();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
          child: Text(
            widget.title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
        ),
        SizedBox(
          height: 200,
          child: FutureBuilder<List<MediaItem>>(
            future: _future,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              final items = snapshot.data ?? [];
              if (items.isEmpty) return const SizedBox.shrink();

              return ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: items.length,
                separatorBuilder: (_, _) => const SizedBox(width: 12),
                itemBuilder: (context, i) => MovieTvCard(item: items[i]),
              );
            },
          ),
        ),
      ],
    );
  }
}
