import 'package:flutter/material.dart';
import '../../models/media_item.dart';
import '../network/tmdb_service.dart';
import '../../screens/movie_tv_detail.dart';

class MovieTvCard extends StatefulWidget {
  const MovieTvCard({super.key, required this.item});

  final MediaItem item;

  @override
  State<MovieTvCard> createState() => _MovieTvCardState();
}

class _MovieTvCardState extends State<MovieTvCard> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: (){
        // bağlanıcak
      },
      child: MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: AnimatedScale(
        scale: _hovering ? 1.2 : 1.0,
        alignment: Alignment.bottomCenter,
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOut,
        child: SizedBox(
          width: 130,
          height: 190,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Stack(
              fit: StackFit.expand,
              children: [
                widget.item.posterUrl != null
                    ? Image.network(
                        widget.item.posterUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          color: colorScheme.surfaceContainerHighest,
                          child: Icon(Icons.movie_outlined,
                              color: colorScheme.onSurfaceVariant),
                        ),
                      )
                    : Container(
                        color: colorScheme.surfaceContainerHighest,
                        child: Icon(Icons.movie_outlined,
                            color: colorScheme.onSurfaceVariant),
                      ),
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        Colors.black.withValues(alpha: _hovering ? 0.75 : 0.55),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
                Positioned(
                  left: 8,
                  right: 8,
                  bottom: 8,
                  child: AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 150),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: _hovering ? Colors.white : Colors.white70,
                    ),
                    child: Text(
                      widget.item.title ?? widget.item.name ?? '',
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ],
            ),
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
        GestureDetector(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const MovieTvDetail()),
            );
          },
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
            child: Text(
            widget.title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          )
          ),
        ),
        FutureBuilder<List<MediaItem>>(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            final items = snapshot.data ?? [];
            if (items.isEmpty) return const SizedBox.shrink();

            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              clipBehavior: Clip.none,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  for (int i = 0; i < items.length; i++) ...[
                    if (i > 0) const SizedBox(width: 12),
                    MovieTvCard(item: items[i]),
                  ],
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}
