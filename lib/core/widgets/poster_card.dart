import 'package:flutter/material.dart';
import '../../models/media_item.dart';

class PosterCard extends StatelessWidget {
  const PosterCard({super.key, required this.item});

  final MediaItem item;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 120,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: item.posterUrl == null
                ? Container(
                    height: 170,
                    width: 120,
                    color: Colors.grey.shade800,
                    child: const Icon(Icons.movie, color: Colors.white54),
                  )
                : Image.network(
                    item.posterUrl!,
                    height: 170,
                    width: 120,
                    fit: BoxFit.cover,
                  ),
          ),
          const SizedBox(height: 6),
          Text(
            item.title ?? item.name ?? '',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
