import '../core/network/api_config.dart';

enum MediaType { movie, tv }

class MediaItem {
  final int id;
  final String? title;
  final String? name;
  final String overview;
  final String? posterPath;
  final double voteAverage;
  final MediaType type;
  final String? backdropPath;
  final String? releaseDate;

  const MediaItem({
    required this.id,
    required this.title,
    required this.name,
    required this.overview,
    required this.posterPath,
    required this.voteAverage,
    required this.type,
    required this.backdropPath,
    required this.releaseDate,
  });

  factory MediaItem.fromJson(Map<String, dynamic> json, MediaType type) {
    return MediaItem(
      id: json['id'] as int,
      title: json['title'] as String?,
      name: json['name'] as String?,
      overview: (json['overview'] ?? '') as String,
      posterPath: json['poster_path'] as String?,
      backdropPath: json['backdrop_path'] as String?,
      voteAverage: (json['vote_average'] as num?)?.toDouble() ?? 0,
      releaseDate: (json['release_date'] ?? json['first_air_date'] as String),
      type: type,
    );
  }

  String? get posterUrl =>
      posterPath == null ? null : '${ApiConfig.imageBaseUrl}$posterPath';

  String? get backdropUrl =>
      backdropPath == null ? null : '${ApiConfig.backdropBaseUrl}$backdropPath';   
}
