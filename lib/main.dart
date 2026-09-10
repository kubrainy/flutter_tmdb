import 'package:flutter/material.dart';
import 'package:flutter_tmdb/screens/splash_page.dart';
import 'core/network/tmdb_service.dart';
import 'core/widgets/brand_logo.dart';
import 'core/widgets/media_section.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/app_colors.dart';
import 'models/media_item.dart';


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

  // "Birazdan gelecek liste" sözleri. initState'te bir kez başlatılır.
  late Future<List<MediaItem>> _moviesFuture;
  late Future<List<MediaItem>> _tvFuture;

  @override
  void initState() {
    super.initState();
    _moviesFuture = _service.discoverMovies();
    _tvFuture = _service.discoverTvShows();
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
          MediaSection(title: 'Popüler Filmler', future: _moviesFuture),
          MediaSection(title: 'Popüler Diziler', future: _tvFuture),
        ],
      ),
    );
  }
}
