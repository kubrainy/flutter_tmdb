import 'package:flutter/material.dart';
import '../core/network/tmdb_service.dart';
import '../core/theme/app_colors.dart';
import '../core/widgets/brand_logo.dart';
import '../models/media_item.dart';
import 'media_detail_screen.dart';

class MediaListScreen extends StatefulWidget {
  const MediaListScreen({
    super.key,
    required this.title,
    required this.mediaType,
    this.genreId,
  });

  final String title;
  final MediaType mediaType;
  final int? genreId;

  @override
  State<MediaListScreen> createState() => _MediaListScreenState();
}

class _MediaListScreenState extends State<MediaListScreen> {
  final TmdbService _service = TmdbService();
  final ScrollController _scrollController = ScrollController();

  final List<MediaItem> _items = [];
  int _page = 1;
  bool _isLoading = false;
  bool _hasMore = true;

  @override
  void initState() {
    super.initState();
    _loadMore();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final nearBottom = _scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200;
    if (nearBottom) {
      _loadMore();
    }
  }

  Future<void> _loadMore() async {
    if (_isLoading || !_hasMore) return;
    setState(() => _isLoading = true);

    final extra = <String, dynamic>{
      'page': _page,
      if (widget.genreId != null) 'with_genres': widget.genreId,
    };
    final newItems = widget.mediaType == MediaType.movie
        ? await _service.discoverMovies(extra: extra)
        : await _service.discoverTvShows(extra: extra);

    if (!mounted) return;
    setState(() {
      _items.addAll(newItems);
      _page++;
      _isLoading = false;
      if (newItems.isEmpty) _hasMore = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: Text(
                widget.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
            ),
            const SizedBox(width: 10),
            const BrandLogo(fontSize: 14, showText: false),
          ],
        ),
      ),
      body: _items.isEmpty && _isLoading
          ? const Center(child: CircularProgressIndicator())
          : GridView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              clipBehavior: Clip.none,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 12,
                mainAxisSpacing: 16,
                childAspectRatio: 2 / 3,
              ),
              itemCount: _items.length + (_hasMore ? 1 : 0),
              itemBuilder: (context, i) {
                if (i >= _items.length) {
                  return const Center(
                    child: SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  );
                }
                return _MediaListCard(item: _items[i]);
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
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => MediaDetailScreen(item: widget.item)),
        );
      },
      child: MouseRegion(
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
      ),
    );
  }
}
