
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

  static Map<int, String>? _movieGenreCache;
  static Map<int, String>? _tvGenreCache;

  Future<Map<int, String>> getMovieGenreMap() async {
    if (_movieGenreCache != null) return _movieGenreCache!;
    final response = await _dio.get('/genre/movie/list');
    final list = response.data['genres'] as List<dynamic>;
    final genres = <int, String>{
      for (final g in list) (g as Map<String, dynamic>)['id'] as int: g['name'] as String,
    };
    _movieGenreCache = genres;
    return genres;
  }

  Future<Map<int, String>> getTvGenreMap() async {
    if (_tvGenreCache != null) return _tvGenreCache!;
    final response = await _dio.get('/genre/tv/list');
    final list = response.data['genres'] as List<dynamic>;
    final genres = <int, String>{
      for (final g in list) (g as Map<String, dynamic>)['id'] as int: g['name'] as String,
    };
    _tvGenreCache = genres;
    return genres;
  }

    Future<Map<String, dynamic>> getMediaDetail(int id, MediaType type) async {
    final path = type == MediaType.tv ? '/tv/$id' : '/movie/$id';
    final response = await _dio.get(path);
    return response.data as Map<String, dynamic>;
  }

  Future<List<Map<String, dynamic>>> getCredits(int id, MediaType type) async {
    final path = type == MediaType.tv ? '/tv/$id/credits' : '/movie/$id/credits';
    final response = await _dio.get(path);
    final cast = response.data['cast'] as List<dynamic>;
    return cast.cast<Map<String , dynamic>>();
  }

  Future<Map<String, dynamic>> getPersonDetail(int personId) async {
    final response = await _dio.get('/person/$personId');
    return response.data as Map<String, dynamic>;
  }

  Future<List<MediaItem>> getPersonCredits(int personId) async {
    final response = await _dio.get('/person/$personId/combined_credits');
    final cast = response.data['cast'] as List<dynamic>;
    return cast
        .where((json) =>
            json['media_type'] == 'movie' || json['media_type'] == 'tv')
        .map((json) {
          final map = json as Map<String, dynamic>;
          final type = map['media_type'] == 'tv' ? MediaType.tv : MediaType.movie;
          return MediaItem.fromJson(map, type);
        })
        .toList();
  }

  Future<List<Map<String, dynamic>>> getReviews(int id, MediaType type) async {
    final path = type == MediaType.tv ? '/tv/$id/reviews' : '/movie/$id/reviews';
    final response = await _dio.get(
      path,
      queryParameters: {'language': 'en-US'},
    );
    final results = response.data['results'] as List<dynamic>;
    return results.cast<Map<String, dynamic>>();
  }

  Future<List<Map<String, dynamic>>> getVideos(int id, MediaType type) async {
    final path = type == MediaType.tv ? '/tv/$id/videos' : '/movie/$id/videos';
    final response = await _dio.get(path);
    final results = response.data['results'] as List<dynamic>;
    return results
        .cast<Map<String, dynamic>>()
        .where((v) => v['site'] == 'YouTube')
        .toList();
  }

  Future<List<MediaItem>> getSimilar(int id, MediaType type) async {
    final path = type == MediaType.tv ? '/tv/$id/similar' : '/movie/$id/similar';
    final response = await _dio.get(path);
    final results = response.data['results'] as List<dynamic>;
    return results
        .map((json) => MediaItem.fromJson(json as Map<String, dynamic>, type))
        .toList();
  }
}
