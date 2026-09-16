import 'package:flutter/material.dart';
import '../core/network/tmdb_service.dart';
import '../core/theme/app_colors.dart';
import '../models/media_item.dart';

class MediaDetailScreen extends StatefulWidget {
  const MediaDetailScreen({super.key, required this.item});

  final MediaItem item;

  @override
  State<MediaDetailScreen> createState() => _MediaDetailScreenState();
}

class _MediaDetailScreenState extends State<MediaDetailScreen> {
  final TmdbService _service = TmdbService();
  Map<String, dynamic>? _detail;
  bool _loading = true;
  int _selectedTab = 0;

  static const _tabs = ['Overview', 'Cast & Crew', 'Reviews', 'Similar Movies'];

  @override
  void initState() {
    super.initState();
    _loadDetail();
  }

  Future<void> _loadDetail() async {
    final data = await _service.getMediaDetail(widget.item.id, widget.item.type);
    if (!mounted) return;
    setState(() {
      _detail = data;
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
            ?.map((g) => (g as Map<String, dynamic>)['name'] as String)
            .toList() ??
        const <String>[];

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
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
                Positioned(
                  top: 12,
                  left: 12,
                  child: GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.45),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.arrow_back, color: Colors.white, size: 18),
                    ),
                  ),
                ),
                Positioned(
                  top: 140,
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
                              releaseDate,
                              style: TextStyle(color: AppColors.textMuted, fontSize: 13),
                            ),
                          ],
                        ),
                      ],
                      if (genres.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(
                          'Tür: ${genres.join(', ')}',
                          style: TextStyle(color: AppColors.textMuted, fontSize: 13),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 170),
            _loading
                ? const Padding(
                    padding: EdgeInsets.symmetric(vertical: 40),
                    child: Center(child: CircularProgressIndicator()),
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildTabs(),
                      const SizedBox(height: 16),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: _buildTabContent(overview),
                      ),
                    ],
                  ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildTabs() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          for (int i = 0; i < _tabs.length; i++)
            GestureDetector(
              onTap: () => setState(() => _selectedTab = i),
              child: Container(
                margin: const EdgeInsets.only(right: 20),
                padding: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: _selectedTab == i ? AppColors.primary : Colors.transparent,
                      width: 2,
                    ),
                  ),
                ),
                child: Text(
                  _tabs[i],
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: _selectedTab == i ? AppColors.textPrimary : AppColors.textMuted,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTabContent(String overview) {
    if (_selectedTab == 0) {
      return Text(
        overview.isEmpty ? 'Açıklama bulunamadı.' : overview,
        style: const TextStyle(fontSize: 14, height: 1.5),
      );
    }
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Center(
        child: Text(
          'Yakında eklenecek',
          style: TextStyle(color: AppColors.textMuted),
        ),
      ),
    );
  }
}
