import 'dart:async';
import 'package:flutter/material.dart';
import '../core/network/tmdb_service.dart';
import '../core/theme/app_colors.dart';
import '../models/media_item.dart';
import 'media_detail_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();

}

class _SearchScreenState extends State<SearchScreen> {
  final TmdbService _service =TmdbService();
  final TextEditingController _controller = TextEditingController();
  Timer? _debounce;

  List<MediaItem> _results = [];
  bool _loading = false;
  bool _searched = false;

  void _onQueryChanged(String query){
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500),(){
       _runSearch(query.trim());
    });
  }

  Future<void> _runSearch(String query) async {
    if(query.isEmpty){
      setState(() {
        _results = [];
        _searched = false;
        _loading = false;
      });
      return;
    }
    setState(() {
      _loading = true;
      _searched = true;
    });
    final results = await _service.searchMulti(query);
    if(!mounted) return;
    setState(() {
      _results = results;
      _loading = false;
    });
  }

  @override
  void dispose(){
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(child: _buildBody()),
            _buildSearchField(),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchField() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      child: TextField(
        controller: _controller,
        autofocus: true,
        onChanged: _onQueryChanged,
        style: const TextStyle(color: AppColors.textPrimary),
        cursorColor: AppColors.textMuted,
        decoration: InputDecoration(
          hintText: 'Film veya dizi ara...',
          hintStyle: const TextStyle(color: AppColors.textMuted),
          suffixIcon: const Icon(Icons.search, color: AppColors.textMuted),
          filled: true,
          fillColor: AppColors.surface,
          contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(24),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _buildBody(){
    if(_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if(!_searched){
      return const Center(
        child: Text(
          'Aramak için yazmaya başla',
          style: TextStyle(color: AppColors.textMuted),
        ),
      );
    }
    if(_results.isEmpty){
      return const Center(
        child: Text(
          'Sonuç bulunamadı',
          style: TextStyle(color: AppColors.textMuted),
        ),
      );
    }
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      clipBehavior: Clip.hardEdge,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 12,
        mainAxisSpacing: 16,
        childAspectRatio: 2 / 3,
      ),
      itemCount: _results.length,
      itemBuilder: (context, i) => _SearchResultCard(item: _results[i]),
    );
  }
}

class _SearchResultCard extends StatefulWidget {
  const _SearchResultCard({required this.item});

  final MediaItem item;

  @override
  State<_SearchResultCard> createState() => _SearchResultCardState();
}

class _SearchResultCardState extends State<_SearchResultCard> {
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
                      child: const Icon(Icons.movie_outlined,
                          color: AppColors.textMuted),
                    ),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Colors.black.withValues(alpha: _hovering ? 0.75 : 0.55),
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