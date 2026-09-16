import 'package:flutter/material.dart';
import '../../models/media_item.dart';
import '../../screens/media_detail_screen.dart';
import '../theme/app_colors.dart';

class MediaPosterCard extends StatefulWidget {
  const MediaPosterCard({super.key, required this.item});

  final MediaItem item;

  @override
  State<MediaPosterCard> createState() => _MediaPosterCardState();
}

class _MediaPosterCardState extends State<MediaPosterCard> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => MediaDetailScreen(item: widget.item)),
        );
      },
      child: MouseRegion(
        onEnter: (_) => setState(() => _hovering = true),
        onExit: (_) => setState(() => _hovering = false),
        child: AnimatedScale(
          scale: _hovering ? 1.12 : 1.0,
          alignment: Alignment.bottomCenter,
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeOut,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Stack(
              fit: StackFit.expand,
              children: [
                widget.item.posterUrl != null
                    ? Image.network(widget.item.posterUrl!, fit: BoxFit.cover)
                    : Container(
                        color: AppColors.surfaceHigh,
                        child: const Icon(Icons.movie_outlined, color: AppColors.textMuted),
                      ),
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        Colors.black.withValues(alpha: _hovering ? 0.75 : 0.6),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
                Positioned(
                  left: 6,
                  right: 6,
                  bottom: 6,
                  child: AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 150),
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: _hovering ? Colors.white : Colors.white70,
                    ),
                    child: Text(
                      widget.item.title ?? widget.item.name ?? '',
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
