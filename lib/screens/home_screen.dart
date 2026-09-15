import 'package:flutter/material.dart';
import '../core/network/tmdb_service.dart';
import '../core/widgets/brand_logo.dart';
import '../core/widgets/movie_tv_card.dart';
import '../core/widgets/populer_hero.dart';
import '../models/media_item.dart';
import 'search_screen.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, this.onNavigateToTab});

  final ValueChanged<int>? onNavigateToTab;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TmdbService _service = TmdbService();
  late Future<List<MediaItem>> _trendingFuture;

  @override
  void initState() {
    super.initState();
    _trendingFuture = _service.getTrendingAll();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const BrandLogo(),
        scrolledUnderElevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const SearchScreen()),
              );
            },
          )
        ],
      ),
      body: ListView(
        children: [
          PopulerHero(future: _trendingFuture),
          MovieTvSection(
            title: 'Filmler',
            mediaType: MediaType.movie,
            onSeeAll: () => widget.onNavigateToTab?.call(1),
          ),
          MovieTvSection(
            title: 'Diziler',
            mediaType: MediaType.tv,
            onSeeAll: () => widget.onNavigateToTab?.call(2),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
