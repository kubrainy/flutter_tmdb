import 'package:flutter/material.dart';
import '../core/network/tmdb_service.dart';
import '../core/theme/app_colors.dart';
import '../core/widgets/brand_logo.dart';
import '../core/widgets/movie_tv_card.dart';
import '../core/widgets/populer_hero.dart';
import '../models/media_item.dart';
import 'search_screen.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TmdbService _service = TmdbService();
  int _selectedIndex = 0; // 0: home, 1: grid


  late Future<List<MediaItem>> _trendingFuture;

  @override
  void initState() {
    super.initState();
    _trendingFuture = _service.getTrendingAll();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
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
          const MovieTvSection(title: 'Filmler', mediaType: MediaType.movie),
          const MovieTvSection(title: 'Diziler', mediaType: MediaType.tv),
          const SizedBox(height: 16),
        ],
      ),
      bottomNavigationBar: SizedBox(
        height: 78,
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            Positioned(
              bottom: -30,
              child: Container(
                width: 220,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      Colors.pinkAccent.withValues(alpha: 0.55),
                      Colors.purpleAccent.withValues(alpha: 0.0),
                    ],
                  ),
                ),
              ),
            ),
            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 70, vertical: 14),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(25),
                  child: Container(
                    height: 54,
                    decoration: const BoxDecoration(
                      gradient: AppColors.brandGradient,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        _navItem(
                          icon: Icons.home_rounded,
                          selected: _selectedIndex == 0,
                          onPressed: () {
                            setState(() => _selectedIndex = 0);
                            Navigator.of(context).popUntil((route) => route.isFirst);
                          },
                        ),
                        _navItem(
                          icon: Icons.grid_view,
                          selected: _selectedIndex == 1,
                          onPressed: () {
                            setState(() => _selectedIndex = 1);
                            // navigator eklencek
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _navItem({
    required IconData icon,
    required bool selected,
    required VoidCallback onPressed,
  }) {
    return IconButton(
      padding: EdgeInsets.zero,
      alignment: Alignment.center,
      onPressed: onPressed,
      icon: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.white, size: 26),
          const SizedBox(height: 4),
          Container(
            width: 5,
            height: 5,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: selected ? Colors.white : Colors.transparent,
            ),
          ),
        ],
      ),
    );
  }
}
