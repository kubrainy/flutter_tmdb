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
        ...?extra,
      },
    );
    final results = response.data['results'] as List<dynamic>;
    return results
        .map((json) =>
            MediaItem.fromJson(json as Map<String, dynamic>, MediaType.tv))
        .toList();
  }
}
