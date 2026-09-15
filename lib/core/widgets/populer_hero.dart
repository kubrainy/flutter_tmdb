import 'package:flutter/material.dart';
import '../../models/media_item.dart';
import '../../screens/media_detail_screen.dart';
import '../theme/app_colors.dart';

class PopulerHero extends StatefulWidget {
  const PopulerHero({super.key, required this.future, this.onNavigateToTab});
  final Future<List<MediaItem>> future;
  final ValueChanged<int>? onNavigateToTab;

  @override
  State<PopulerHero> createState() => _PopularHeroState();
}

class _PopularHeroState extends State<PopulerHero> {
  final PageController _controller = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<MediaItem>>(
      future: widget.future,
      builder: (context, snapShot) {
        if (snapShot.connectionState == ConnectionState.waiting) {
          return const SizedBox(
            height: 200,
            child: Center(child: CircularProgressIndicator()),
          );
        }
        final items = (snapShot.data ?? [])
            .where((e) => e.backdropUrl != null)
            .toList();
        if (items.isEmpty) return const SizedBox.shrink();

        const maxDots = 5;
        final total = items.length;
        final visibleCount = total < maxDots ? total : maxDots;
        int dotsStart = _currentPage - (maxDots ~/ 2);
        dotsStart = dotsStart.clamp(0, (total - visibleCount).clamp(0, total));

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Flexible(
                    child: Text(
                      'Bu Hafta Popüler',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Row(
                    children: [
                      _filterChip('Film', active: true, onTap: () => widget.onNavigateToTab?.call(1)),
                      const SizedBox(width: 8),
                      _filterChip('Dizi', onTap: () => widget.onNavigateToTab?.call(2)),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 190,
              child: PageView.builder(
                controller: _controller,
                itemCount: items.length,
                onPageChanged: (i) => setState(() => _currentPage = i),
                itemBuilder: (context, i) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => MediaDetailScreen(item: items[i])),
                      );
                    },
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          Image.network(
                            items[i].backdropUrl!,
                            fit: BoxFit.cover,
                          ),
                          Container(
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter,
                                colors: [Colors.black87, Colors.transparent],
                              ),
                            ),
                          ),
                          Positioned(
                            left: 12,
                            right: 12,
                            bottom: 10,
                            child: Text(
                              items[i].title ?? items[i].name ?? '',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.white70,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(visibleCount, (i) {
                final index = dotsStart + i;
                final active = index == _currentPage;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: active ? 18 : 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: active ? AppColors.textPrimary : AppColors.primary,
                    borderRadius: BorderRadius.circular(3),
                  ),
                );
              }),
            ),
          ],
        );
      },
    );
  }

  Widget _filterChip(String label, {bool active = false, VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: active ? AppColors.primary : Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: active ? Colors.white : AppColors.textMuted,
        ),
      ),
    ),
    );
  }
}
