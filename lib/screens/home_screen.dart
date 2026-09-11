import 'package:flutter/material.dart';
import '../core/network/tmdb_service.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_theme.dart';
import '../core/widgets/brand_logo.dart';
import '../core/widgets/movie_tv_card.dart';
import '../core/widgets/populer_hero.dart';
import '../models/media_item.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TmdbService _service = TmdbService();

  late Future<List<MediaItem>> _trendingFuture;
  late Future<List<MediaItem>> _popularMoviesFuture;

  @override
  void initState() {
    super.initState();
    _trendingFuture = _service.getTrendingAll();
    _popularMoviesFuture = _service.discoverMovies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const BrandLogo(),
        actions: [
          ValueListenableBuilder<ThemeMode>(
            valueListenable: AppTheme.mode,
            builder: (context, mode, _) {
              return IconButton(
                icon: Icon(
                  mode == ThemeMode.dark ? Icons.nightlight_round : Icons.sunny,
                  color: AppColors.primary,
                ),
                onPressed: AppTheme.toggleTheme,
              );
            },
          ),
        ],
      ),
      body: ListView(
        children: [
          PopulerHero(future: _trendingFuture),
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 20, 16, 12),
            child: Text(
              'Popüler Filmler',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
          ),
          SizedBox(
            height: 190,
            child: FutureBuilder<List<MediaItem>>(
              future: _popularMoviesFuture,
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
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
