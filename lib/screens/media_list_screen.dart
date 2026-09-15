import 'package:flutter/material.dart';
import '../core/network/tmdb_service.dart';
import '../core/theme/app_colors.dart';
import '../models/media_item.dart';

class MediaListScreen extends StatefulWidget {
  const MediaListScreen({super.key, required this.title, required this.mediaType});

  final String title;
  final MediaType mediaType;

  @override
  State<MediaListScreen> createState() => _MediaListScreenState();
}

class _MediaListScreenState extends State<MediaListScreen> {
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
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: FutureBuilder<List<MediaItem>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final items = snapshot.data ?? [];
          if (items.isEmpty) {
            return const Center(
              child: Text('Sonuç bulunamadı', style: TextStyle(color: AppColors.textMuted)),
            );
          }
          return GridView.builder(
            padding: const EdgeInsets.all(16),
            clipBehavior: Clip.none,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 12,
              mainAxisSpacing: 16,
              childAspectRatio: 2 / 3,
            ),
            itemCount: items.length,
            itemBuilder: (context, i) => _MediaListCard(item: items[i]),
          );
        },
      ),
    );
  }
}

class _MediaListCard extends StatefulWidget {
  const _MediaListCard({required this.item});

  final MediaItem item;

  @override
  State<_MediaListCard> createState() => _MediaListCardState();
}

class _MediaListCardState extends State<_MediaListCard> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: AnimatedScale(
        scale: _hovering ? 1.12 : 1.0,
        alignment: Alignment.bottomCenter,
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOut,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Stack(
            fit: StackFit.expand,
            children: [
              widget.item.posterUrl != null
                  ? Image.network(widget.item.posterUrl!, fit: BoxFit.cover)
                  : Container(
                      color: AppColors.surfaceHigh,
                      child: const Icon(Icons.movie_outlined, color: AppColors.textMuted),
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
                left: 6,
                right: 6,
                bottom: 6,
                child: AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 150),
                  style: TextStyle(
                    fontSize: 11,
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
    );
  }
}
