import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import '../core/network/tmdb_service.dart';
import '../core/theme/app_colors.dart';
import '../core/utils/date_utils.dart';
import '../core/widgets/media_poster_card.dart';
import '../models/media_item.dart';
import 'media_list_screen.dart';
import 'person_detail_screen.dart';
import 'video_player_screen.dart';

class MediaDetailScreen extends StatefulWidget {
  const MediaDetailScreen({super.key, required this.item});

  final MediaItem item;

  @override
  State<MediaDetailScreen> createState() => _MediaDetailScreenState();
}

class _MediaDetailScreenState extends State<MediaDetailScreen> {
  final TmdbService _service = TmdbService();
  Map<String, dynamic>? _detail;
  List<Map<String, dynamic>> _cast = [];
  List<Map<String, dynamic>> _reviews = [];
  List<Map<String, dynamic>> _videos = [];
  List<MediaItem> _similar = [];
  bool _loading = true;
  bool _showAllReviews = false;
  final List<TapGestureRecognizer> _genreRecognizers = [];

  static const _sections = ['Özet', 'Oyuncular', 'Videolar', 'Reviews', 'Similar Movies'];

  @override
  void initState() {
    super.initState();
    _loadDetail();
  }

  @override
  void dispose() {
    for (final r in _genreRecognizers) {
      r.dispose();
    }
    super.dispose();
  }

  void _openGenre(String genreName, int genreId, MediaType type) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => MediaListScreen(
          title: '$genreName ${type == MediaType.movie ? 'Filmleri' : 'Dizileri'}',
          mediaType: type,
          genreId: genreId,
        ),
      ),
    );
  }

  Future<void> _loadDetail() async {
    final data = await _service.getMediaDetail(widget.item.id, widget.item.type);
    final cast = await _service.getCredits(widget.item.id, widget.item.type);
    final reviews = await _service.getReviews(widget.item.id, widget.item.type);
    final videos = await _service.getVideos(widget.item.id, widget.item.type);
    final similar = await _service.getSimilar(widget.item.id, widget.item.type);
    if (!mounted) return;
    setState(() {
      _detail = data;
      _cast = cast;
      _videos = videos;
      _reviews = reviews;
      _similar = similar;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    final detail = _detail;
    final title = (detail?['title'] as String?) ??
        (detail?['name'] as String?) ??
        item.title ??
        item.name ??
        '';
    final overview = (detail?['overview'] as String?)?.isNotEmpty == true
        ? detail!['overview'] as String
        : item.overview;
    final releaseDate = (detail?['release_date'] as String?) ??
        (detail?['first_air_date'] as String?) ??
        item.releaseDate;
    final genres = (detail?['genres'] as List<dynamic>?)
            ?.map((g) => g as Map<String, dynamic>)
            .toList() ??
        const <Map<String, dynamic>>[];

    for (final r in _genreRecognizers) {
      r.dispose();
    }
    _genreRecognizers
      ..clear()
      ..addAll(genres.map((g) => TapGestureRecognizer()
        ..onTap = () => _openGenre(g['name'] as String, g['id'] as int, item.type)));

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: double.infinity,
              height: 390,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                SizedBox(
                  height: 220,
                  width: double.infinity,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      item.backdropUrl != null
                          ? Image.network(item.backdropUrl!, fit: BoxFit.cover)
                          : Container(color: AppColors.surfaceHigh),
                      Container(color: Colors.black.withValues(alpha: 0.25)),
                    ],
                  ),
                ),
                const Positioned(
                  top: 4,
                  left: 4,
                  child: BackButton(color: AppColors.textPrimary),
                ),
                Positioned(
                  top: 160,
                  left: 16,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: item.posterUrl != null
                        ? Image.network(
                            item.posterUrl!,
                            width: 130,
                            height: 195,
                            fit: BoxFit.cover,
                          )
                        : Container(
                            width: 130,
                            height: 195,
                            color: AppColors.surfaceHigh,
                          ),
                  ),
                ),
                Positioned(
                  top: 235,
                  left: 162,
                  right: 16,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                      ),
                      if (releaseDate != null && releaseDate.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.calendar_today_outlined,
                                size: 14, color: AppColors.textMuted),
                            const SizedBox(width: 4),
                            Text(
                              formatDateTr(releaseDate),
                              style: TextStyle(color: AppColors.textMuted, fontSize: 13),
                            ),
                          ],
                        ),
                      ],
                      if (genres.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        RichText(
                          text: TextSpan(
                            style: TextStyle(color: AppColors.textMuted, fontSize: 13),
                            children: [
                              const TextSpan(text: 'Tür: '),
                              for (int i = 0; i < genres.length; i++) ...[
                                TextSpan(
                                  text: genres[i]['name'] as String,
                                  recognizer: _genreRecognizers[i],
                                ),
                                if (i != genres.length - 1) const TextSpan(text: ', '),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                ],
              ),
            ),
            _loading
                ? const Padding(
                    padding: EdgeInsets.symmetric(vertical: 40),
                    child: Center(child: CircularProgressIndicator()),
                  )
                : Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        for (final section in _sections)
                          _buildSection(section, overview),
                      ],
                    ),
                  ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, String overview) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 12),
          _buildSectionContent(title, overview),
        ],
      ),
    );
  }

  Widget _buildSectionContent(String title, String overview) {
    if (title == 'Özet') {
      return Text(
        overview.isEmpty ? 'Açıklama bulunamadı.' : overview,
        style: const TextStyle(fontSize: 14, height: 1.5),
      );
    }
    if (title == 'Oyuncular') {
      return _cast.isEmpty
          ? Text('Yakında eklenecek', style: TextStyle(color: AppColors.textMuted))
          : _buildCastRow();
    }
    if (title == 'Reviews') {
      return _reviews.isEmpty
          ? Text('Henüz yorum yok.', style: TextStyle(color: AppColors.textMuted))
          : _buildReviewsList();
    }
    if (title == 'Videolar') {
      return _videos.isEmpty
          ? Text('Yakında eklenecek', style: TextStyle(color: AppColors.textMuted))
          : _buildVideosRow();
    }
    if (title == 'Similar Movies') {
      return _similar.isEmpty
          ? Text('Benzer içerik bulunamadı.', style: TextStyle(color: AppColors.textMuted))
          : _buildSimilarGrid();
    }
    return Text(
      'Yakında eklenecek',
      style: TextStyle(color: AppColors.textMuted),
    );
  }

  Widget _buildReviewsList() {
    final visibleCount = _showAllReviews ? _reviews.length : 2;
    final visibleReviews = _reviews.take(visibleCount).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (int i = 0; i < visibleReviews.length; i++) ...[
          _buildReviewCard(visibleReviews[i]),
          const SizedBox(height: 16),
        ],
        if (_reviews.length > 2)
          GestureDetector(
            onTap: () => setState(() => _showAllReviews = !_showAllReviews),
            child: Text(
              _showAllReviews ? 'Daha az göster' : 'Daha fazla göster',
              style: const TextStyle(
                color: AppColors.primary,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildReviewCard(Map<String, dynamic> review) {
    final author = review['author'] as String? ?? 'Anonim';
    final content = review['content'] as String? ?? '';
    final authorDetails = review['author_details'] as Map<String, dynamic>?;
    final avatarPath = authorDetails?['avatar_path'] as String?;
    final rating = authorDetails?['rating'];
    final avatarUrl = avatarPath != null && avatarPath.startsWith('/https')
        ? avatarPath.substring(1)
        : avatarPath != null
            ? 'https://image.tmdb.org/t/p/w45$avatarPath'
            : null;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: AppColors.surfaceHigh,
                backgroundImage: avatarUrl != null ? NetworkImage(avatarUrl) : null,
                child: avatarUrl == null
                    ? const Icon(Icons.person, size: 16, color: AppColors.textMuted)
                    : null,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  author,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                    fontSize: 13,
                  ),
                ),
              ),
              if (rating != null) ...[
                const Icon(Icons.star, size: 14, color: AppColors.primary),
                const SizedBox(width: 2),
                Text(
                  '$rating',
                  style: const TextStyle(color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.w600),
                ),
              ],
            ],
          ),
          const SizedBox(height: 8),
          Text(
            content,
            maxLines: 5,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 13, height: 1.4, color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }

  Widget _buildCastRow() {
    if (_cast.isEmpty) return const SizedBox.shrink();
    return SizedBox(
      height: 90,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _cast.length,
        itemBuilder: (context, i) {
          final person = _cast[i];
          final profilePath = person['profile_path'] as String?;
          final name = person['name'] as String? ?? '';

          return GestureDetector(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => PersonDetailScreen(personId: person['id'] as int),
                ),
              );
            },
            child: Container(
              width: 64,
              margin: const EdgeInsets.only(right: 12),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: AppColors.surfaceHigh,
                    backgroundImage: profilePath != null
                        ? NetworkImage('https://image.tmdb.org/t/p/w185$profilePath')
                        : null,
                    child: profilePath == null
                        ? const Icon(Icons.person, color: AppColors.textMuted)
                        : null,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 11, color: AppColors.textPrimary),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildVideosRow() {
    return SizedBox(
      height: 136,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _videos.length,
        itemBuilder: (context, i) {
          final video = _videos[i];
          final key = video['key'] as String;
          final name = video['name'] as String? ?? '';

          return GestureDetector(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => VideoPlayerScreen(videoKey: key, title: name),
                ),
              );
            },
            child: Container(
              width: 160,
              margin: const EdgeInsets.only(right: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Image.network(
                          'https://img.youtube.com/vi/$key/hqdefault.jpg',
                          width: 160,
                          height: 90,
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => Container(
                            width: 160,
                            height: 90,
                            color: AppColors.surfaceHigh,
                          ),
                        ),
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.5),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.play_arrow, color: Colors.white, size: 20),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 12, color: AppColors.textPrimary),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSimilarGrid() {
    return SizedBox(
      height: 190,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        clipBehavior: Clip.none,
        itemCount: _similar.length,
        separatorBuilder: (_, _) => const SizedBox(width: 12),
        itemBuilder: (context, i) => SizedBox(
          width: 120,
          child: MediaPosterCard(item: _similar[i]),
        ),
      ),
    );
  }
}
