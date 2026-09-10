import '../core/network/api_config.dart';

enum MediaType { movie, tv }

class MediaItem {
  final int id;
  final String title;
  final String overview;
  final String? posterPath;
  final double voteAverage;
  final MediaType type;

  const MediaItem({
    required this.id,
    required this.title,
    required this.overview,
    required this.posterPath,
    required this.voteAverage,
    required this.type,
  });

  factory MediaItem.fromJson(Map<String, dynamic> json, MediaType type) {
    return MediaItem(
      id: json['id'] as int,
      title: (json['title'] ?? json['name'] ?? '') as String,
      overview: (json['overview'] ?? '') as String,
      posterPath: json['poster_path'] as String?,
      voteAverage: (json['vote_average'] as num?)?.toDouble() ?? 0,
      type: type,
    );
  }

  String? get posterUrl =>
      posterPath == null ? null : '${ApiConfig.imageBaseUrl}$posterPath';
}
