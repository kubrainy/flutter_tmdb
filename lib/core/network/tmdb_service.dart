
import 'package:dio/dio.dart';
import 'api_config.dart';
import '../../models/media_item.dart';

class TmdbService {
    TmdbService()
      : _dio = Dio(
          BaseOptions(
            baseUrl: ApiConfig.baseUrl,
            queryParameters: {'language': 'tr-TR'},
            headers: {
              'Authorization': 'Bearer ${ApiConfig.accessToken}',
              'accept': 'application/json',
            },
          ),
        );

  final Dio _dio;

  Future<List<MediaItem>> getTrendingAll({String timeWindow = 'week'}) async {
    final response = await _dio.get('/trending/all/$timeWindow');
    final results = response.data['results'] as List<dynamic>;
    return results 
        .where((json) => json['media_type'] != 'person')
        .map((json) {
          final map =json as Map<String, dynamic>;
          final type = map['media_type'] == 'tv' ? MediaType.tv : MediaType.movie;
          return MediaItem.fromJson(map, type);
        })
        .toList();
  }

  Future<List<MediaItem>> discoverMovies({Map<String, dynamic>? extra}) async {
    final response = await _dio.get(
      '/discover/movie',
      queryParameters: {
        'sort_by': 'popularity.desc',
        'include_adult': false,
        ...?extra,
      },
    );
    final results = response.data['results'] as List<dynamic>;
    return results
        .map((json) =>
            MediaItem.fromJson(json as Map<String, dynamic>, MediaType.movie))
        .toList();
  }

  Future<List<MediaItem>> discoverTvShows({Map<String, dynamic>? extra}) async {
    final response = await _dio.get(
      '/discover/tv',
      queryParameters: {
        'sort_by': 'popularity.desc',
        'include_adult': false,
        ...?extra,
      },
    );
    final results = response.data['results'] as List<dynamic>;
    return results
        .map((json) =>
            MediaItem.fromJson(json as Map<String, dynamic>, MediaType.tv))
        .toList();
  }

  Future<List<MediaItem>> searchMulti(String query) async {
    final response = await _dio.get(
      '/search/multi',
      queryParameters: {'query': query , 'include_adult': false},
    );
    final results = response.data['results'] as List<dynamic>;
    return results
        .where((json) => json['media_type'] != 'person')
        .map((json){
          final map = json as Map<String, dynamic>;
          final type = map['media_type'] == 'tv' ? MediaType.tv : MediaType.movie;
          return MediaItem.fromJson(map, type);
        })
        .toList();
  }

  static Map<int, String>? _genreCache;

  Future<Map<int, String>> getGenreMap() async {
    if (_genreCache != null) return _genreCache!;

    final responses = await Future.wait([
      _dio.get('/genre/movie/list'),
      _dio.get('/genre/tv/list'),
    ]);

    final genres = <int, String>{};
    for (final response in responses) {
      final list = response.data['genres'] as List<dynamic>;
      for (final g in list) {
        final map = g as Map<String, dynamic>;
        genres[map['id'] as int] = map['name'] as String;
      }
    }
    _genreCache = genres;
    return genres;
  }

    Future<Map<String, dynamic>> getMediaDetail(int id, MediaType type) async {
    final path = type == MediaType.tv ? '/tv/$id' : '/movie/$id';
    final response = await _dio.get(path);
    return response.data as Map<String, dynamic>;
  }

}
