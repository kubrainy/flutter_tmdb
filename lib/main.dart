import 'package:flutter/material.dart';
import 'package:flutter_tmdb/screens/splash_page.dart';
import 'core/network/tmdb_service.dart';
import 'core/widgets/brand_logo.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/app_colors.dart';
import 'models/media_item.dart';
import 'core/widgets/populer_hero.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: AppTheme.mode,
      builder: (context, mode, _) {
        return MaterialApp(
          title: 'TMDB',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: mode,
          home: const SplashPage(),
        );
      },
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

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
        ],
      ),
    );
  }
}
