import 'package:flutter/material.dart';
import '../core/network/tmdb_service.dart';
import '../core/theme/app_colors.dart';
import '../core/utils/date_utils.dart';
import '../core/widgets/media_poster_card.dart';
import '../models/media_item.dart';

class PersonDetailScreen extends StatefulWidget {
  const PersonDetailScreen({super.key, required this.personId});

  final int personId;

  @override
  State<PersonDetailScreen> createState() => _PersonDetailScreenState();
}

class _PersonDetailScreenState extends State<PersonDetailScreen> {
  final TmdbService _service = TmdbService();
  Map<String, dynamic>? _person;
  List<MediaItem> _credits = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final person = await _service.getPersonDetail(widget.personId);
    final credits = await _service.getPersonCredits(widget.personId);
    if (!mounted) return;
    setState(() {
      _person = person;
      _credits = credits;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading || _person == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final person = _person!;
    final name = person['name'] as String? ?? '';
    final birthday = person['birthday'] as String?;
    final placeOfBirth = person['place_of_birth'] as String?;
    final profilePath = person['profile_path'] as String?;

    return Scaffold(
      appBar: AppBar(title: Text(name)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(80),
                child: profilePath != null
                    ? Image.network(
                        'https://image.tmdb.org/t/p/w300$profilePath',
                        width: 140,
                        height: 140,
                        fit: BoxFit.cover,
                      )
                    : Container(
                        width: 140,
                        height: 140,
                        color: AppColors.surfaceHigh,
                        child: const Icon(Icons.person,
                            size: 48, color: AppColors.textMuted),
                      ),
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: Text(
                name,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                textAlign: TextAlign.center,
              ),
            ),
            if (birthday != null || placeOfBirth != null) ...[
              const SizedBox(height: 8),
              Center(
                child: Text(
                  [
                    if (birthday != null) formatDateTr(birthday),
                    placeOfBirth,
                  ].nonNulls.join(' · '),
                  style: TextStyle(color: AppColors.textMuted, fontSize: 13),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
            const SizedBox(height: 24),
            if (_credits.isNotEmpty) ...[
              const Text(
                'Bilinen Yapımlar',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                clipBehavior: Clip.none,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 16,
                  childAspectRatio: 2 / 3,
                ),
                itemCount: _credits.length,
                itemBuilder: (context, i) => MediaPosterCard(item: _credits[i]),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
